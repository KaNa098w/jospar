import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/drawer/widgets/drawer_header_bar.dart';
import 'package:jospar/core/models/auth_response.dart';

void main() {
  testWidgets('shows one neutral authorization icon when signed out',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawerHeaderBar(
            hpad: 16,
            user: null,
            onAuthTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.login_rounded), findsOneWidget);
    expect(find.byIcon(Icons.apple), findsNothing);
    expect(find.text('G'), findsNothing);
  });

  testWidgets('shows user initials after authorization', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawerHeaderBar(
            hpad: 16,
            user: User(firstName: 'Иван', lastName: 'Иванов'),
            onAuthTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('ИИ'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsNothing);
  });
}
