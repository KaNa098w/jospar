import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jospar/core/services/auth_service.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/offline/sync_engine.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';

class RealtimeLogEntry {
  const RealtimeLogEntry({
    required this.timestamp,
    required this.message,
    required this.isError,
  });

  final DateTime timestamp;
  final String message;
  final bool isError;
}

class RealtimeSync {
  static const _defaultAppKey =
      'a7d26ec594a832be62a5a1c7e27026732fdb4200d965e16d6a70e709cdc92e60';

  RealtimeSync({
    required this.syncEngine,
    this.appKey = const String.fromEnvironment(
      'REVERB_APP_KEY',
      defaultValue: _defaultAppKey,
    ),
  });

  final SyncEngine syncEngine;
  final String appKey;
  final AuthStorage _authStorage = AuthStorage();

  ReverbClient? _client;
  PrivateChannel? _channel;
  Timer? _retryTimer;
  Timer? _debounceTimer;
  bool _started = false;
  bool _connecting = false;
  bool _connected = false;
  bool _subscribed = false;
  bool _subscribing = false;
  bool _resettingClient = false;
  int _retryAttempt = 0;
  int _connectionFailures = 0;
  final StreamController<RealtimeLogEntry> _logController =
      StreamController<RealtimeLogEntry>.broadcast();
  final List<RealtimeLogEntry> _logs = <RealtimeLogEntry>[];

  bool get isConnected => _connected;
  bool get isSubscribed => _subscribed;
  Stream<RealtimeLogEntry> get logStream => _logController.stream;
  List<RealtimeLogEntry> get logs => List.unmodifiable(_logs);

  void start() {
    if (_started) return;
    _started = true;
    _log('connecting host=jospar.kz:443 tls=true');
    _connect();
  }

  Future<void> restart() async {
    await stop();
    start();
  }

  Future<void> _connect() async {
    if (!_started || _connecting || appKey.isEmpty) return;
    if (_client != null) {
      if (_connected) await _subscribeToCurrentUser();
      return;
    }
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      _log('connect: waiting for authenticated user');
      _scheduleRetry();
      return;
    }

    _connecting = true;
    try {
      late final ReverbClient client;
      client = ReverbClient.instance(
        host: 'jospar.kz',
        port: 443,
        appKey: appKey,
        useTLS: true,
        authEndpoint: 'https://jospar.kz/api/broadcasting/auth',
        pingInterval: const Duration(seconds: 20),
        // Read the token for every authorization. This is important after
        // logout/login because ReverbClient is a package-level singleton.
        authorizer: (channelName, socketId) async {
          final currentToken = await _authStorage.getToken();
          _log('authorizing channel=${_maskedChannel(channelName)}');
          if (currentToken == null || currentToken.isEmpty) {
            throw StateError('No Bearer token for channel authorization');
          }
          return {
            'Authorization': 'Bearer $currentToken',
            'Accept': 'application/json',
          };
        },
        onConnected: (socketId) {
          if (!_started || !identical(_client, client)) return;
          _connected = true;
          _retryAttempt = 0;
          _retryTimer?.cancel();
          _retryTimer = null;
          _log('connected: socketId=$socketId');
          unawaited(_subscribeToCurrentUser());
        },
        onReconnecting: () {
          if (_resettingClient) return;
          _connected = false;
          _subscribed = false;
          _subscribing = false;
          _channel = null;
          _log('reconnecting');
        },
        onDisconnected: () {
          if (_resettingClient) return;
          _connected = false;
          _subscribed = false;
          _subscribing = false;
          _channel = null;
          _connectionFailures++;
          _log('disconnected code=unknown reason=connection_closed');
          _scheduleRetry();
        },
        onError: (error) {
          if (_resettingClient) return;
          _log('error: $error');
          _subscribed = false;
          _subscribing = false;
          _connectionFailures++;
          _scheduleRetry();
        },
      );
      // connect() only starts the socket. The actual subscription is made by
      // onConnected after Reverb has supplied a socket_id.
      _client = client;
      await client.connect();
    } catch (error) {
      _log('connect failed: $error');
      _connected = false;
      _client = null;
      _channel = null;
      _connectionFailures++;
      _scheduleRetry();
    } finally {
      _connecting = false;
    }
  }

  Future<void> _subscribeToCurrentUser() async {
    if (!_started || !_connected || _subscribing) return;
    final client = _client;
    if (client == null || client.socketId == null) {
      _scheduleRetry();
      return;
    }
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      _log('subscription skipped: Bearer token is missing');
      _scheduleRetry();
      return;
    }

    _subscribing = true;
    try {
      final userId = await _currentServerUserId();
      final channelName = 'private-sync.user.$userId';
      var channel = _channel;
      if (channel == null || channel.name != channelName) {
        final staleChannel = channel;
        if (staleChannel != null && staleChannel.name != channelName) {
          client.unsubscribeFromChannel(staleChannel.name);
        }
        final existingChannel = client.getChannel(channelName);
        channel = client.subscribeToPrivateChannel(channelName);
        _channel = channel;
        if (existingChannel == null) {
          channel.bind('sync.changed', _onSyncChanged);
          // Kept for compatibility with servers/clients that preserve the
          // Echo leading dot instead of stripping it on the wire protocol.
          channel.bind('.sync.changed', _onSyncChanged);
          channel.addStateListener((state) {
            if (!_started || !identical(_channel, channel)) return;
            if (state == ChannelState.subscribed) {
              _subscribed = true;
              _retryAttempt = 0;
              _connectionFailures = 0;
              _log('auth status=200');
              _log('subscription succeeded');
              unawaited(_pullAfterSubscription());
            } else {
              _subscribed = false;
            }
          });
        } else if (channel.state == ChannelState.subscribed) {
          // The package automatically resubscribes retained channels before
          // the asynchronous /user verification above can finish.
          _subscribed = true;
          _retryAttempt = 0;
          _connectionFailures = 0;
          _log('subscription already restored');
          unawaited(_pullAfterSubscription());
        }
      } else if (channel.state == ChannelState.unsubscribed) {
        await channel.subscribe();
      }
    } catch (error) {
      _subscribed = false;
      _log('subscription failed: $error');
      _scheduleRetry();
    } finally {
      _subscribing = false;
    }
  }

  Future<String> _currentServerUserId() async {
    final user = await AuthService().getCurrentUser();
    final userId = user.id?.trim();
    if (userId == null || userId.isEmpty) {
      throw StateError('/api/v1/user returned an empty userId');
    }
    final cachedUserId = await _authStorage.getUserId();
    if (cachedUserId != userId) {
      _log(
        'userId refreshed: cached=${_maskedId(cachedUserId)} '
        'server=${_maskedId(userId)}',
      );
      await _authStorage.setUserId(userId);
    }
    return userId;
  }

  void _onSyncChanged(String eventName, dynamic payload) {
    dynamic decoded = payload;
    if (payload is String) {
      try {
        decoded = jsonDecode(payload);
      } catch (_) {}
    }
    final latestSequence =
        decoded is Map ? decoded['latest_sequence']?.toString() ?? '-' : '-';
    _log(
      'event received name=$eventName latestSequence=$latestSequence',
    );
    _debouncedPull();
  }

  Future<void> _pullAfterSubscription() async {
    _log('changes requested');
    await syncEngine.synchronize();
    _log(
      'changes completed count=${syncEngine.lastPullChangeCount} '
      'cursorUpdated=${syncEngine.lastPullCursorUpdated}',
    );
  }

  void _debouncedPull() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 250),
      _pullAfterSubscription,
    );
  }

  void _scheduleRetry() {
    if (!_started || appKey.isEmpty || _retryTimer != null) return;
    const delays = [2, 5, 10, 30];
    final delay = delays[_retryAttempt.clamp(0, delays.length - 1)];
    _retryAttempt++;
    _log('reconnect scheduled delay=${delay}s');
    _retryTimer = Timer(Duration(seconds: delay), () {
      _retryTimer = null;
      if (!_started) return;
      unawaited(syncEngine.synchronize());
      if (_connected) {
        _subscribeToCurrentUser();
      } else if (_client == null) {
        _connect();
      } else if (_client!.connectionState == ConnectionState.error ||
          _client!.connectionState == ConnectionState.disconnected) {
        if (_connectionFailures >= 3) {
          _recreateClient();
        } else {
          _reconnectClosedClient();
        }
      }
    });
  }

  Future<void> _recreateClient() async {
    if (!_started || _resettingClient) return;
    _resettingClient = true;
    _log('recreating WebSocket client after $_connectionFailures failures');
    _connected = false;
    _subscribed = false;
    _subscribing = false;
    _channel = null;
    _client = null;
    try {
      // pusher_reverb_flutter exposes only a singleton in production. Its
      // reset API is annotated for tests, but is the only supported way to
      // discard stale callbacks, channels and socket state before rebuilding.
      // ignore: invalid_use_of_visible_for_testing_member
      ReverbClient.resetInstance();
    } catch (error) {
      _log('client reset failed: $error');
    } finally {
      _resettingClient = false;
    }
    if (_started) unawaited(_connect());
  }

  Future<void> _reconnectClosedClient() async {
    final client = _client;
    if (!_started || client == null || _connecting) return;
    _connecting = true;
    try {
      await client.connect();
    } catch (error) {
      _log('reconnect failed: $error');
      _scheduleRetry();
    } finally {
      _connecting = false;
    }
  }

  Future<void> stop() async {
    _started = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _connected = false;
    _subscribed = false;
    _subscribing = false;
    _retryAttempt = 0;
    _connectionFailures = 0;
    final channel = _channel;
    _channel = null;
    // unsubscribe() marks the channel as unsubscribing before writing. If the
    // socket has already closed the write can fail, but awaiting and catching
    // it prevents an unhandled Future error and makes disconnect() idempotent.
    try {
      await channel?.unsubscribe();
    } catch (error) {
      _log('unsubscribe skipped: socket already closed ($error)');
    }
    try {
      _client?.disconnect();
    } catch (error) {
      _log('disconnect cleanup failed: $error');
    }
    _client = null;
  }

  void _log(String message) {
    final normalized = message.toLowerCase();
    final entry = RealtimeLogEntry(
      timestamp: DateTime.now(),
      message: message,
      isError: normalized.contains('error') ||
          normalized.contains('failed') ||
          normalized.contains('disconnected') ||
          normalized.contains('missing'),
    );
    _logs.add(entry);
    if (_logs.length > 200) _logs.removeAt(0);
    _logController.add(entry);
    if (kDebugMode) debugPrint('[Realtime] $message');
  }

  static String _maskedChannel(String channelName) {
    final separator = channelName.lastIndexOf('.');
    if (separator < 0 || separator == channelName.length - 1) {
      return channelName;
    }
    final id = channelName.substring(separator + 1);
    final visible = id.length <= 4 ? id.substring(0, 1) : id.substring(0, 4);
    return '${channelName.substring(0, separator + 1)}$visible***';
  }

  static String _maskedId(String? id) {
    if (id == null || id.isEmpty) return 'absent';
    return id.length <= 4
        ? '${id.substring(0, 1)}***'
        : '${id.substring(0, 4)}***';
  }
}
