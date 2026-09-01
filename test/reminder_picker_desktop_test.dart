import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/modal_sheet/reminder_picker_sheet.dart';
import 'package:jospar/core/l10n/s.dart';

void main() {
  test('new reminder starts at the current local time', () {
    final time = resolveReminderInitialTime(
      null,
      now: DateTime(2026, 8, 30, 14, 37),
    );

    expect(time, const TimeOfDay(hour: 14, minute: 37));
  });

  test('saved reminder time takes precedence over the current time', () {
    final time = resolveReminderInitialTime(
      const TimeOfDay(hour: 8, minute: 5),
      now: DateTime(2026, 8, 30, 14, 37),
    );

    expect(time, const TimeOfDay(hour: 8, minute: 5));
  });

  testWidgets('desktop mouse wheel changes the reminder time', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final semantics = tester.ensureSemantics();
    TimeOfDay? savedTime;
    try {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ru')],
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  final result = await showReminderPickerSheet(
                    context,
                    initialTime: const TimeOfDay(hour: 8, minute: 0),
                  );
                  if (result?.time != null) {
                    setState(() => savedTime = result!.time);
                  }
                },
                child: const Text('Открыть'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();

      final hourWheel = find.byType(ListWheelScrollView).first;
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: tester.getCenter(hourWheel),
          scrollDelta: const Offset(0, 80),
        ),
      );
      await tester.pumpAndSettle();

      final selectedHour = tester
          .widget<ListWheelScrollView>(hourWheel)
          .controller as FixedExtentScrollController;
      expect(selectedHour.selectedItem % 24, 9);

      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      expect(savedTime, const TimeOfDay(hour: 9, minute: 0));
    } finally {
      semantics.dispose();
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
