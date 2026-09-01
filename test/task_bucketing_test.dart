import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/tasks/utils/bucketing.dart';
import 'package:jospar/core/models/tasks_response.dart';

void main() {
  test('includes tasks completed today regardless of their task date', () {
    final today = DateTime(2026, 8, 12);
    final tasks = [
      TaskItems(
        id: 'completed-today',
        date: '2026-08-20',
        isCompleted: true,
        updatedAt: '2026-08-12T10:30:00',
      ),
      TaskItems(
        id: 'completed-yesterday',
        isCompleted: true,
        updatedAt: '2026-08-11T23:59:00',
      ),
      TaskItems(
        id: 'edited-today',
        isCompleted: false,
        updatedAt: '2026-08-12T12:00:00',
      ),
    ];

    expect(
      completedOnDay(tasks, today).map((task) => task.id),
      ['completed-today'],
    );
  });

  final base = DateTime(2026, 8, 2);

  test('groups upcoming dates into relative sections', () {
    expect(bucketFor(base, base), kBucketToday);
    expect(bucketFor(DateTime(2026, 8, 1), base), kBucketToday);
    expect(bucketFor(DateTime(2026, 8, 3), base), kBucketTomorrow);
    expect(bucketFor(DateTime(2026, 8, 9), base), kBucketWeek);
    expect(bucketFor(DateTime(2026, 8, 10), base), kBucketMonth);
    expect(bucketFor(DateTime(2026, 9, 1), base), kBucketMonth);
    expect(bucketFor(DateTime(2026, 9, 2), base), kBucketLater);
  });

  test('drop targets assign dates inside their sections', () {
    expect(dateForBucket(kBucketTomorrow, base), DateTime(2026, 8, 3));
    expect(dateForBucket(kBucketWeek, base), DateTime(2026, 8, 5));
    expect(dateForBucket(kBucketMonth, base), DateTime(2026, 8, 16));
    expect(dateForBucket(kBucketLater, base), DateTime(2027, 8, 2));
  });

  test('later section shows dates only within three months', () {
    expect(showDateInLater(DateTime(2026, 11, 2), base), isTrue);
    expect(showDateInLater(DateTime(2026, 11, 3), base), isFalse);
    expect(showDateInLater(DateTime(2027, 8, 2), base), isFalse);
  });
}
