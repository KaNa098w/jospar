import 'package:flutter/material.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/collaboration_service.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/app/screens/shared/share_delivery_sheet.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/task_share_message.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:provider/provider.dart';
import 'package:jospar/app/widgets/app_message_dialog.dart';

Future<void> showCollaboratorsSheet(
  BuildContext context,
  TaskItems task,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CollaboratorsSheet(task: task),
  );
}

class _CollaboratorsSheet extends StatefulWidget {
  const _CollaboratorsSheet({required this.task});

  final TaskItems task;

  @override
  State<_CollaboratorsSheet> createState() => _CollaboratorsSheetState();
}

class _CollaboratorsSheetState extends State<_CollaboratorsSheet> {
  final CollaborationService _service = CollaborationService();
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  bool _sharing = false;

  bool get _isOwner => widget.task.collaborationRole == 'owner';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.collaborators(widget.task.id!);
      final currentUserId = await AuthStorage().getUserId();
      if (!mounted) return;
      setState(() {
        _items = items
            .where((item) =>
                currentUserId == null ||
                (item['user_id'] ?? item['id'])?.toString() != currentUserId)
            .toList(growable: false);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      await _showError(error);
    }
  }

  Future<void> _invite() async {
    if (_sharing) return;
    try {
      final mode = await _selectDeliveryMode();
      if (mode == null || !mounted) return;
      setState(() => _sharing = true);
      final syncEngine = OfflineRuntime.syncEngine;
      if (syncEngine == null) {
        throw StateError(S.of(context).syncNotReady);
      }
      await syncEngine.synchronize();
      if (syncEngine.lastError != null) {
        throw StateError(S.of(context).syncFailed(syncEngine.lastError!));
      }
      final invite = await _service.createInvite(
        widget.task.id!,
        mode: mode,
      );
      final url = invite['url']?.toString();
      final hash = invite['hash']?.toString();
      if ((url == null || url.isEmpty) && (hash == null || hash.isEmpty)) {
        throw StateError(S.of(context).inviteLinkMissing);
      }
      final accountId = await AuthStorage().getAccountId();
      await OfflineRuntime.store.recordSuccessfulShare(
        accountId: accountId,
        taskId: widget.task.id!,
        collaborative: mode == ShareDeliveryMode.collaborate,
        inviteHash: hash,
      );
      if (mounted) {
        await context.read<GlobalProvider>().refreshTasks(
              context,
              silent: true,
            );
      }
      final baseShareUrl =
          url != null && url.isNotEmpty ? url : 'https://jospar.kz/s/$hash';
      final responseMode = ShareDeliveryMode.fromValue(
        invite['mode']?.toString(),
      );
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          text: buildTaskShareMessage(
            task: widget.task,
            shareUrl: baseShareUrl,
            mode: responseMode,
          ),
          title: widget.task.name,
          sharePositionOrigin: _sharePositionOrigin(),
        ),
      );
    } catch (error) {
      if (mounted) await _showError(error);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Rect? _sharePositionOrigin() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        renderObject.size.isEmpty) {
      return null;
    }
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  Future<ShareDeliveryMode?> _selectDeliveryMode() {
    return showShareDeliverySheet(context);
  }

  Future<void> _changeRole(String userId, String role) async {
    try {
      await _service.updateRole(widget.task.id!, userId, role);
      await _load();
    } catch (error) {
      if (mounted) await _showError(error);
    }
  }

  Future<void> _remove(String userId) async {
    try {
      await _service.removeCollaborator(widget.task.id!, userId);
      await _load();
    } catch (error) {
      if (mounted) await _showError(error);
    }
  }

  Future<void> _leave() async {
    try {
      await _service.leave(widget.task.id!);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) await _showError(error);
    }
  }

  Future<void> _showError(Object error) {
    final message = error is CollaborationException
        ? error.message
        : error.toString().replaceFirst('Bad state: ', '');
    return showAppMessageDialog(
      context,
      title: S.of(context).error,
      message: message,
      buttonText: S.of(context).done,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    S.of(context).participants,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                if (_isOwner)
                  IconButton(
                    onPressed: _sharing ? null : _invite,
                    tooltip: S.of(context).invite,
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(S.of(context).emptyParticipants),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final userId =
                        (item['user_id'] ?? item['id'])?.toString() ?? '';
                    final role = item['role']?.toString() ?? 'viewer';
                    final name =
                        (item['name'] ?? item['display_name'] ?? item['email'])
                            ?.toString()
                            .trim();
                    final online = item['is_online'] == true ||
                        item['online'] == true ||
                        item['presence'] == 'online';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.person_outline),
                          ),
                          if (online)
                            Positioned(
                              right: -1,
                              bottom: -1,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759),
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        name == null || name.isEmpty
                            ? S.of(context).participant
                            : name,
                      ),
                      subtitle: Text(
                        [
                          _roleLabel(role),
                          if (online) S.of(context).onlineNow,
                          if (item['email'] != null &&
                              item['email'].toString() != name)
                            item['email'].toString(),
                        ].join(' · '),
                      ),
                      trailing: _isOwner && role != 'owner'
                          ? PopupMenuButton<String>(
                              onSelected: (action) {
                                if (action == 'remove') {
                                  _remove(userId);
                                } else {
                                  _changeRole(userId, action);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'editor',
                                  child: Text(S.of(context).canEdit),
                                ),
                                PopupMenuItem(
                                  value: 'viewer',
                                  child: Text(S.of(context).viewOnly),
                                ),
                                PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'remove',
                                  child: Text(S.of(context).removeParticipant),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                ),
              ),
            if (!_isOwner)
              TextButton.icon(
                onPressed: _leave,
                icon: const Icon(Icons.logout),
                label: Text(S.of(context).leaveSharedTask),
              ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return S.of(context).owner;
      case 'editor':
        return S.of(context).canEdit;
      default:
        return S.of(context).viewOnly;
    }
  }
}
