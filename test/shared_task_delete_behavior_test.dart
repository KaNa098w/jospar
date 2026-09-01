import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/widgets/custom_alert_dialog.dart';
import 'package:jospar/core/models/tasks_response.dart';

void main() {
  test('received shared tasks use leave instead of delete', () {
    expect(
      shouldLeaveSharedTask(
        TaskItems(isShared: true, collaborationRole: 'viewer'),
      ),
      isTrue,
    );
    expect(
      shouldLeaveSharedTask(
        TaskItems(isShared: true, collaborationRole: 'editor'),
      ),
      isTrue,
    );
  });

  test('owned tasks use normal delete', () {
    expect(
      shouldLeaveSharedTask(
        TaskItems(isShared: true, collaborationRole: 'owner'),
      ),
      isFalse,
    );
    expect(shouldLeaveSharedTask(TaskItems(isShared: false)), isFalse);
  });
}
