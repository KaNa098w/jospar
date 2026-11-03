import 'dart:async';

import 'package:flutter/material.dart';

/// Draws the first frame before starting platform plugins and local migrations.
class StartupApp extends StatefulWidget {
  const StartupApp({super.key, required this.initialize});

  final Future<Widget> Function(void Function(String) onStage) initialize;

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  Widget? _app;
  String _stage = 'Запуск приложения';
  bool _failed = false;
  bool _slow = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_initialize());
    });
  }

  Future<void> _initialize() async {
    _watchStage();
    try {
      final app = await widget.initialize((stage) {
        debugPrint('[Startup] $stage');
        if (!mounted) return;
        setState(() {
          _stage = stage;
          _slow = false;
        });
        _watchStage();
      });
      if (mounted) setState(() => _app = app);
    } catch (error, stack) {
      debugPrint('[Startup] Failed at $_stage: $error\n$stack');
      if (mounted) setState(() => _failed = true);
    } finally {
      _timer?.cancel();
    }
  }

  void _watchStage() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 20), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_app != null) return _app!;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Jospar', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 24),
                  if (!_failed) const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    _failed ? 'Не удалось запустить приложение' : _stage,
                    textAlign: TextAlign.center,
                  ),
                  if (_failed || _slow) ...[
                    const SizedBox(height: 12),
                    SelectableText(
                      '${_failed ? 'Ошибка' : 'Долгое ожидание'}: $_stage.\n'
                      'Закройте и снова откройте приложение. '
                      'Если проблема повторяется, сообщите этот этап поддержке.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
