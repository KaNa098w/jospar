import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/auth/profile_page.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/models/auth_response.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('account deletion requires explicit destructive confirmation',
      (tester) async {
    final provider = _AuthenticatedProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<GlobalProvider>.value(
        value: provider,
        child: const MaterialApp(home: ProfilePage()),
      ),
    );

    await tester.tap(find.text('Удалить аккаунт'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Удалить аккаунт?'), findsOneWidget);
    expect(
      find.text(
        'Аккаунт и связанные с ним данные будут удалены '
        'без возможности восстановления.',
      ),
      findsOneWidget,
    );
    expect(find.text('Удалить безвозвратно'), findsOneWidget);
    expect(find.text('Отмена'), findsOneWidget);
  });
}

class _AuthenticatedProvider extends GlobalProvider {
  @override
  AuthResponse? get authResponse => AuthResponse(
        token: 'access-token',
        user: User(
          id: 'user-1',
          firstName: 'Иван',
          lastName: 'Иванов',
        ),
      );
}
