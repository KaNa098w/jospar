# Backend contract: offline sync and collaborative tasks

This document is the contract expected by the Flutter client. API prefix:
`https://jospar.kz/api/v1`. All HTTP calls require
`Authorization: Bearer <token>`. JSON timestamps are UTC ISO-8601.

## Core requirements

1. Every task and task list has a UUID `id`, `created_at`, `updated_at`,
   nullable `deleted_at`, and integer `version`.
2. The client-generated UUID is accepted as the entity ID when it is unique.
   If the backend replaces it, it returns `server_id`.
3. Every mutation has globally unique `operation_id`. Store processed operation
   IDs and return the previous result for duplicates (idempotency).
4. Every committed mutation appends one immutable row to `sync_events` in the
   same database transaction.
5. Access checks are applied both when mutating and when returning sync events.

Suggested tables:

- `tasks(id, owner_id, task_list_id, parent_task_id, name, note, date,
  urgency, position, is_completed, trashed, hash, version, created_at,
  updated_at, deleted_at)`
- `task_collaborators(task_id, user_id, role, joined_at, revoked_at)`; roles:
  `owner`, `editor`, `viewer`
- `task_invites(id, task_id, token_hash, role, expires_at, max_uses,
  uses_count, revoked_at, created_by)`
- `sync_operations(operation_id, user_id, device_id, response_json,
  processed_at)`
- `sync_events(sequence BIGSERIAL, entity, entity_id, action, version,
  payload_json, actor_id, created_at)`

`hash`/invite tokens must be random, unique and unguessable. Store only a
SHA-256 hash of an invite token where possible.

## 1. Push one offline operation

`POST /sync/operations`

Request:

```json
{
  "operation_id": "uuid-v7",
  "device_id": "device-uuid",
  "type": "createTask",
  "entity_id": "client-generated-uuid",
  "client_timestamp": "2026-07-28T08:00:00.000Z",
  "payload": {
    "id": "client-generated-uuid",
    "name": "Купить молоко",
    "date": "2026-07-28",
    "task_list_id": "uuid",
    "parent_task_id": null,
    "urgency": "medium",
    "is_completed": false,
    "updated_at": "2026-07-28T08:00:00.000Z"
  }
}
```

Supported `type` values:

- `createTask`, `updateTask`, `deleteTask`, `toggleTaskCompleted`,
  `restoreTask`, `clearTrash`
- `createTaskList`, `updateTaskList`, `deleteTaskList`
- `createShare`, `revokeShare`

Success (`200` or `201`):

```json
{
  "operation_id": "uuid-v7",
  "server_id": "uuid",
  "entity_version": 7
}
```

Rules:

- Run access check, entity mutation, `sync_events` insert and
  `sync_operations` insert in one transaction.
- Repeating the same `operation_id` must return the same response and must not
  apply the mutation twice.
- `deleteTask` is a soft delete (`trashed=true`) so it can be restored.
- `clearTrash` permanently deletes only the caller's already-trashed tasks.
- Parent task and subtasks must inherit the collaboration ACL.
- Return `401` for expired authentication, `403` for insufficient role,
  `404` for invisible entities, `409` for a non-mergeable version conflict,
  `422` for validation errors.

Conflict policy for the first version:

- Scalar fields use last-write-wins based on server receive time.
- Completion is also last-write-wins.
- Deletion wins over older updates.
- Never trust `client_timestamp` as authoritative; it is diagnostic only.
- Increment `version` for every accepted change and always return the resulting
  full entity through the changes feed.

## 2. Pull missed changes

`GET /sync/changes?device_id=<uuid>&cursor=<opaque>&limit=500`

Response:

```json
{
  "changes": [
    {
      "sequence": 9812,
      "entity": "task",
      "action": "updated",
      "version": 7,
      "data": {
        "id": "uuid",
        "name": "Купить молоко и хлеб",
        "task_list_id": "uuid",
        "is_completed": false,
        "is_shared": true,
        "collaboration_role": "editor",
        "collaborators": [
          {"user_id": "uuid", "name": "Айжан", "role": "owner"}
        ],
        "updated_at": "2026-07-28T08:01:10.000Z"
      }
    }
  ],
  "next_cursor": "opaque-signed-cursor",
  "has_more": false
}
```

The cursor is server-issued, opaque, monotonic and user-specific. The feed must
include:

- the user's own tasks/lists;
- tasks where the user has an active collaborator row;
- collaboration membership changes;
- tombstones for entities that became deleted or inaccessible.

For a purge use `entity=task`, `action=purged`, with `data.id`. Do not paginate
by `updated_at`; use the immutable event sequence so equal timestamps cannot
lose data. Keep events long enough for inactive mobile devices (recommended:
90+ days), then support a full snapshot endpoint or cursor reset.

## 3. Invite and accept collaboration

Create or reuse an invite:

`POST /tasks/{task_id}/shares`

```json
{"role":"editor","expires_in_seconds":604800}
```

Response:

```json
{
  "hash": "unguessable-token",
  "url": "https://jospar.kz/share/unguessable-token",
  "expires_at": "2026-08-04T08:00:00.000Z"
}
```

Preview (optional, may expose only task name and owner):

`GET /shares/{hash}`

Accept:

`POST /shares/{hash}/accept`

Response:

```json
{
  "task": {
    "id": "uuid",
    "name": "Совместная задача",
    "is_shared": true,
    "collaboration_role": "editor",
    "collaborators": []
  }
}
```

Accept is idempotent. If already a collaborator, return the current task.
Owner endpoints are also needed:

- `GET /tasks/{task_id}/collaborators`
- `PATCH /tasks/{task_id}/collaborators/{user_id}` with `{"role":"viewer"}`
- `DELETE /tasks/{task_id}/collaborators/{user_id}`
- `DELETE /tasks/{task_id}/shares/{invite_id}` to revoke an invite
- `DELETE /tasks/{task_id}/collaborators/me` to leave

Only owner can manage collaborators. Editor can edit/complete tasks and
subtasks. Viewer is read-only.

## 4. Realtime transport (Laravel Reverb)

The client connects to Laravel Reverb at `jospar.kz:443` with TLS and the
public `REVERB_APP_KEY`. Private-channel authorization uses:

`POST https://jospar.kz/api/broadcasting/auth`

The logical Laravel channel is `sync.user.{userId}` and its Pusher wire name is
`private-sync.user.{userId}`. The authorization endpoint must validate the
Bearer token and only authorize a user for their own channel.

When a visible entity changes, send only a lightweight invalidation:

```json
{"type":"sync.changed","latest_sequence":9812}
```

Realtime is not the source of truth. The client then calls `/sync/changes`
with its saved cursor. This guarantees recovery after disconnects and avoids
duplicating conflict logic in realtime handlers.

Production requirements:

- provide only `REVERB_APP_KEY` to the app, never `REVERB_APP_SECRET`;
- authorize private channels using the authenticated user;
- ping/pong heartbeat around 25–30 seconds;
- reconnects are expected;
- publish only after the database transaction commits;
- use Redis/NATS/Postgres LISTEN-NOTIFY between backend instances;
- never put task contents in broadcast topics not scoped to authorized users.

## 5. Initial and recovery sync

For a new installation or expired cursor, return `410 cursor_expired` from the
changes endpoint and provide:

`GET /sync/snapshot`

```json
{
  "task_lists": [],
  "tasks": [],
  "cursor": "new-opaque-cursor"
}
```

The snapshot must include shared tasks and tombstones are unnecessary because
the client replaces only clean local records. The client must preserve its
pending outbox records during snapshot recovery.

## PostgreSQL UUID fix for the latest invite

Do not use Laravel `latestOfMany()` for `TaskInvite` when `task_invites.id`
is a PostgreSQL UUID. Laravel adds `MAX(task_invites.id)` as a tie-breaker,
but PostgreSQL does not provide `MAX(uuid)` and sync/share requests fail with
SQLSTATE `42883`.

Replace the one-of-many relation with a regular `HasMany` relation:

```php
public function invites(): HasMany
{
    return $this->hasMany(TaskInvite::class);
}
```

Where the latest invite is needed, query it without an aggregate:

```php
$latestInvite = $task->invites()
    ->orderByDesc('created_at')
    ->orderByDesc('id')
    ->first();
```

Remove `latestInvite` from automatic eager-loading and API resources until it
uses this safe query. Do not call `latestOfMany()` or `ofMany()` on the UUID
primary key. Another valid long-term option is changing `task_invites` to use
a numeric primary key while keeping a separate unique public UUID. Add an API regression test for
`/sync/operations`, `/sync/snapshot`, `/sync/changes`, and
`/tasks/{task_id}/shares` with at least one existing invite.

## Acceptance checklist

- Creating/editing/completing/deleting while airplane mode is enabled works.
- After reconnect, operations arrive once and in original order.
- Retrying the same operation ID never duplicates a task.
- Two users see a shared-task update without manual refresh (normally under
  two seconds).
- Killing either app, making changes in the other, and reopening catches up
  through the cursor.
- A viewer receives `403` on mutation.
- A removed collaborator stops receiving events and loses task access.
- Parent/subtask permissions and deletion behavior are consistent.
- API tests cover duplicate operation IDs, reconnects, cursor pagination,
  simultaneous edits, revoked invites and expired cursors.
