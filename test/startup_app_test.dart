import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/preloader/startup_app.dart';

void main() {
  testWidgets('reports a stall before the first stage is announced',
      (tester) async {
    final ready = Completer<Widget>();
    await tester.pumpWidget(StartupApp(initialize: (_) => ready.future));
    await tester.pump(const Duration(seconds: 21));
    expect(find.textContaining('Долгое ожидание: Запуск приложения'),
        findsOneWidget);
    ready.complete(const MaterialApp(home: Text('Tasks ready')));
    await tester.pumpAndSettle();
    expect(find.text('Tasks ready'), findsOneWidget);
  });

  testWidgets('shows loading until initialization completes', (tester) async {
    final ready = Completer<Widget>();
    await tester.pumpWidget(StartupApp(initialize: (onStage) {
      onStage('Подготовка базы задач');
      return ready.future;
    }));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Подготовка базы задач'), findsOneWidget);
    ready.complete(const MaterialApp(home: Text('Tasks ready')));
    await tester.pumpAndSettle();
    expect(find.text('Tasks ready'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('startup failure displays the failing stage', (tester) async {
    await tester.pumpWidget(StartupApp(initialize: (onStage) async {
      onStage('Подготовка базы задач');
      throw StateError('database unavailable');
    }));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось запустить приложение'), findsOneWidget);
    expect(
        find.textContaining('Ошибка: Подготовка базы задач'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slow initialization can finish without starting it twice',
      (tester) async {
    final ready = Completer<Widget>();
    var calls = 0;
    await tester.pumpWidget(StartupApp(initialize: (onStage) {
      calls++;
      onStage('Открытие локальных данных');
      return ready.future;
    }));
    await tester.pump(const Duration(seconds: 21));
    expect(find.textContaining('Долгое ожидание:'), findsOneWidget);
    ready.complete(const MaterialApp(home: Text('Tasks ready')));
    await tester.pumpAndSettle();
    expect(find.text('Tasks ready'), findsOneWidget);
    expect(calls, 1);
  });
}
