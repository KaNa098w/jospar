import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:jospar/core/services/offline/sync_engine.dart';

class SynchronizationScreen extends StatefulWidget {
  const SynchronizationScreen({super.key});

  @override
  State<SynchronizationScreen> createState() => _SynchronizationScreenState();
}

class _SynchronizationScreenState extends State<SynchronizationScreen> {
  StreamSubscription<SyncLogEntry>? _subscription;
  List<SyncLogEntry> _logs = const [];
  List<OutboxOp> _queued = const [];
  bool _syncing = false;

  SyncEngine? get _engine => OfflineRuntime.syncEngine;

  @override
  void initState() {
    super.initState();
    _logs = _engine?.logs.reversed.toList(growable: false) ?? const [];
    _subscription = _engine?.logStream.listen((_) {
      if (!mounted) return;
      setState(() {
        _logs = _engine?.logs.reversed.toList(growable: false) ?? const [];
      });
      _loadQueue();
    });
    _loadQueue();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadQueue() async {
    final accountId = await AuthStorage().getAccountId();
    final queued = await OfflineRuntime.outbox.queued(accountId);
    if (mounted) setState(() => _queued = queued);
  }

  Future<void> _synchronize() async {
    final engine = _engine;
    if (engine == null || _syncing) return;
    setState(() => _syncing = true);
    await engine.synchronize(ignoreStopped: true);
    await _loadQueue();
    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lastError = _engine?.lastError;
    final hasCompleted = _logs.any(
      (entry) =>
          entry.kind == SyncLogKind.success || entry.kind == SyncLogKind.error,
    );
    final statusText = _syncing
        ? S.of(context).syncInProgress
        : lastError != null
            ? S.of(context).syncFailedStatus
            : hasCompleted
                ? S.of(context).syncSuccessful
                : S.of(context).syncNotRun;
    final statusColor = _syncing
        ? colors.primary
        : lastError != null
            ? colors.error
            : hasCompleted
                ? const Color(0xFF16835B)
                : colors.onSurfaceVariant;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: Text(
          S.of(context).synchronization,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF6F8F9),
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _synchronize,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _StatusCard(
              text: statusText,
              color: statusColor,
              error: lastError?.toString(),
              syncing: _syncing,
              onSync: _synchronize,
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: S.of(context).syncQueue,
              count: _queued.length,
            ),
            const SizedBox(height: 10),
            if (_queued.isEmpty)
              _EmptyCard(
                icon: Icons.cloud_done_outlined,
                text: S.of(context).syncQueueEmpty,
              )
            else
              ..._queued.map((operation) => _QueueTile(operation: operation)),
            const SizedBox(height: 22),
            _SectionTitle(
              title: S.of(context).syncHistory,
              count: _logs.length,
            ),
            const SizedBox(height: 10),
            if (_logs.isEmpty)
              _EmptyCard(
                icon: Icons.history_rounded,
                text: S.of(context).syncHistoryEmpty,
              )
            else
              ..._logs.map((entry) => _LogTile(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.text,
    required this.color,
    required this.error,
    required this.syncing,
    required this.onSync,
  });

  final String text;
  final Color color;
  final String? error;
  final bool syncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .22)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: syncing
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: color,
                        ),
                      )
                    : Icon(
                        error == null
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                        color: color,
                      ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(fontSize: 13, height: 1.35)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: syncing ? null : onSync,
              icon: const Icon(Icons.sync_rounded),
              label: Text(S.of(context).syncNow),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count', style: const TextStyle(color: Color(0xFF667085))),
        ],
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF667085)),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      );
}

class _QueueTile extends StatelessWidget {
  const _QueueTile({required this.operation});
  final OutboxOp operation;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.upload_rounded, color: Color(0xFF009688)),
          title: Text(operation.type.name),
          subtitle: Text(
            operation.entityId ?? operation.payload['id']?.toString() ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(S.of(context).syncRetries(operation.retries)),
        ),
      );
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});
  final SyncLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (entry.kind) {
      SyncLogKind.sent => (Icons.upload_rounded, const Color(0xFF1769AA)),
      SyncLogKind.received => (Icons.download_rounded, const Color(0xFF7B61A8)),
      SyncLogKind.success => (
          Icons.check_circle_outline,
          const Color(0xFF16835B)
        ),
      SyncLogKind.error => (
          Icons.error_outline_rounded,
          Theme.of(context).colorScheme.error
        ),
      SyncLogKind.info => (Icons.sync_rounded, const Color(0xFF667085)),
    };
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(entry.title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(_time(entry.timestamp)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.details?.isNotEmpty == true)
            SelectableText(entry.details!,
                style: const TextStyle(fontSize: 12.5, height: 1.4)),
        ],
      ),
    );
  }

  String _time(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}:'
      '${value.second.toString().padLeft(2, '0')}';
}
