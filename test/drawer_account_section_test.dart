import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/drawer/widgets/drawer_account_section.dart';
import 'package:jospar/core/models/auth_response.dart';

void main() {
  testWidgets('shows login action for anonymous user', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawerAccountSection(
            user: null,
            onOpen: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('Войти или зарегистрироваться'), findsOneWidget);
    await tester.tap(find.text('Войти или зарегистрироваться'));
    expect(opened, isTrue);
  });

  testWidgets('shows profile and logout action for authenticated user',
      (tester) async {
    var profileOpened = false;
    var loggedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawerAccountSection(
            user: User(
              firstName: 'Иван',
              lastName: 'Иванов',
              phoneNumber: '+77000000000',
            ),
            onOpen: () => profileOpened = true,
            onLogout: () => loggedOut = true,
          ),
        ),
      ),
    );

    expect(find.text('Иван Иванов'), findsOneWidget);
    expect(find.text('+77000000000'), findsOneWidget);
    await tester.tap(find.text('Иван Иванов'));
    await tester.tap(find.byTooltip('Выйти из аккаунта'));

    expect(profileOpened, isTrue);
    expect(loggedOut, isTrue);
  });
}
