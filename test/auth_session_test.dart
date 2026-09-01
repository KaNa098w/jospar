import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/models/auth_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('login persists the backend token and user id', () async {
    final provider = GlobalProvider();

    await provider.setAuthData(
      AuthResponse(
        token: 'backend-token',
        user: User(
          id: 'user-1',
          firstName: 'Test',
          phoneNumber: '+77000000000',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      ),
    );

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('token'), 'backend-token');
    expect(preferences.getString('customerId'), 'user-1');
    expect(
      preferences.getString('avatarUrl'),
      'https://example.com/avatar.jpg',
    );

    final restoredProvider = GlobalProvider();
    await restoredProvider.initialize();
    expect(
      restoredProvider.authResponse?.user?.avatarUrl,
      'https://example.com/avatar.jpg',
    );
  });

  test('logout removes credentials from persistent storage', () async {
    SharedPreferences.setMockInitialValues({
      'token': 'backend-token',
      'customerId': 'user-1',
      'firstName': 'Test',
      'phoneNumber': '+77000000000',
    });
    final provider = GlobalProvider();
    await provider.initialize();

    await provider.logout();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('token'), isNull);
    expect(preferences.getString('customerId'), isNull);
    expect(provider.authResponse, isNull);
  });
}
