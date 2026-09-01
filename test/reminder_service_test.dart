import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/services/reminder_service.dart';

void main() {
  test('parses reminder times from API values', () {
    expect(
      ReminderService.tryParseTime('08:05:00'),
      const TimeOfDay(hour: 8, minute: 5),
    );
    expect(
      ReminderService.tryParseTime('20:00'),
      const TimeOfDay(hour: 20, minute: 0),
    );
    expect(ReminderService.tryParseTime('24:00'), isNull);
    expect(ReminderService.tryParseTime(''), isNull);
  });

  test('formats reminder time for persistence', () {
    expect(
      ReminderService.formatTime(const TimeOfDay(hour: 7, minute: 3)),
      '07:03',
    );
    expect(ReminderService.formatTime(null), '');
  });
}
