import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jospar/core/models/auth_response.dart';
import 'package:jospar/core/services/auth_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialSignInCancelled implements Exception {
  const SocialSignInCancelled();
}

class SocialAuthConfigurationException implements Exception {
  const SocialAuthConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SocialAuthService {
  SocialAuthService({
    AuthService? authService,
    GoogleSignIn? googleSignIn,
  })  : _authService = authService ?? AuthService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const _defaultGoogleWebClientId =
      '905339478529-dg4o3hpl7bijof9cutbvcockds8e5uno.apps.googleusercontent.com';
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: _defaultGoogleWebClientId,
  );
  static const _defaultGoogleIosClientId =
      '905339478529-3cfl2k3rng9rfab8tplv8mroeog5tfvp.apps.googleusercontent.com';
  static const _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: _defaultGoogleIosClientId,
  );
  static const _defaultGoogleDesktopClientId =
      '905339478529-uosn45ihtcvo38ckb1s02acevf38jlq0.apps.googleusercontent.com';
  static const _googleDesktopClientId = String.fromEnvironment(
    'DESKTOP_CLIENT_ID',
    defaultValue: _defaultGoogleDesktopClientId,
  );

  final AuthService _authService;
  final GoogleSignIn _googleSignIn;
  static bool _googleInitialized = false;

  Future<void> initialize() async {
    if (_googleInitialized) {
      _debugLog('initialize: already completed');
      return;
    }
    _debugLog(
      'initialize: start '
      '(web=$kIsWeb, platform=$defaultTargetPlatform, '
      'serverClientId=$_googleWebClientId, '
      'nativeClientId=${defaultTargetPlatform == TargetPlatform.iOS ? _googleIosClientId : defaultTargetPlatform == TargetPlatform.macOS ? _googleDesktopClientId : 'not used'})',
    );
    await _googleSignIn.initialize(
      // On the web `defaultTargetPlatform` describes the host OS (macOS in
      // Chrome on a Mac), not the runtime. google_sign_in_web requires the
      // OAuth Web client ID explicitly; serverClientId alone is insufficient.
      clientId: kIsWeb
          ? _googleWebClientId
          : defaultTargetPlatform == TargetPlatform.iOS
              ? _googleIosClientId
              : defaultTargetPlatform == TargetPlatform.macOS
                  ? _googleDesktopClientId
                  : null,
      serverClientId: _googleWebClientId.isEmpty ? null : _googleWebClientId,
    );
    _googleInitialized = true;
    _debugLog('initialize: success');
  }

  Future<AuthResponse> signInWithGoogle({String? deviceId}) async {
    if (_googleWebClientId.isEmpty) {
      throw const SocialAuthConfigurationException(
        'Google-вход не настроен: приложение запущено без '
        'GOOGLE_WEB_CLIENT_ID.',
      );
    }
    await initialize();
    try {
      _debugLog('authenticate: opening Google account selector');
      final account = await _googleSignIn.authenticate();
      _debugLog(
        'authenticate: success '
        '(account=${_maskEmail(account.email)})',
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          'missing_google_id_token',
          'Google не вернул ID token.',
        );
      }
      _debugLog(
        'idToken: received '
        '(length=${idToken.length}, value=${_maskToken(idToken)})',
      );
      _debugLog(
        'backend: sending social login '
        '(provider=google, deviceId=${deviceId == null ? 'absent' : 'present'})',
      );
      return _authService.socialLogin(
        provider: 'google',
        token: idToken,
        deviceId: deviceId,
      );
    } on GoogleSignInException catch (error) {
      _debugLog(
        'authenticate: GoogleSignInException '
        '(code=${error.code.name}, description=${error.description})',
      );
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialSignInCancelled();
      }
      throw SocialAuthConfigurationException(
        'Ошибка Google Sign-In (${error.code.name}): '
        '${error.description ?? 'проверьте OAuth Client ID и SHA-отпечатки.'}',
      );
    }
  }

  Future<AuthResponse> signInWithApple({String? deviceId}) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw const AuthException(
          'missing_apple_identity_token',
          'Apple не вернул identity token.',
        );
      }
      return _authService.socialLogin(
        provider: 'apple',
        token: identityToken,
        deviceId: deviceId,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SocialSignInCancelled();
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.logout();
    if (_googleInitialized) await _googleSignIn.signOut();
  }

  static void _debugLog(String message) {
    if (kDebugMode) debugPrint('[GoogleAuth] $message');
  }

  static String _maskToken(String token) {
    if (token.length < 12) return '***';
    return '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
  }

  static String _maskEmail(String email) {
    final separator = email.indexOf('@');
    if (separator <= 1) return '***';
    return '${email.substring(0, 2)}***${email.substring(separator)}';
  }
}
