import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/models/auth_response.dart';
import 'package:jospar/core/services/auth_service.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/device_registration_service.dart';
import 'package:jospar/core/services/social_auth_service.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SocialAuthService _socialAuth = SocialAuthService();
  final AuthStorage _storage = AuthStorage();
  final DeviceRegistrationService _deviceRegistration =
      DeviceRegistrationService();
  String? _loadingProvider;
  bool _syncingAfterAuth = false;

  bool get _showApple =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> _signIn(String provider) async {
    if (_loadingProvider != null) return;
    setState(() => _loadingProvider = provider);
    try {
      debugPrint('[SocialAuthUI] sign-in started: provider=$provider');
      final deviceId = await _registeredDeviceId();
      final result = provider == 'google'
          ? await _socialAuth.signInWithGoogle(deviceId: deviceId)
          : await _socialAuth.signInWithApple(deviceId: deviceId);
      if (!mounted) return;
      setState(() => _syncingAfterAuth = true);
      await _linkDeviceToAuthenticatedUser(result, deviceId);
      if (!mounted) return;
      await context.read<GlobalProvider>().setAuthData(result);
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else if (mounted) {
        context.go('/preloader');
      }
    } on SocialSignInCancelled {
      // Closing the provider dialog is not an application error.
    } on AuthException catch (error) {
      _showError(error.message);
    } on SocialAuthConfigurationException catch (error) {
      _showError(error.message);
    } catch (error, stackTrace) {
      debugPrint('[SocialAuthUI] unexpected error: $error');
      debugPrintStack(
        label: '[SocialAuthUI] unexpected stack trace',
        stackTrace: stackTrace,
      );
      _showError('Не удалось выполнить вход: $error');
    } finally {
      if (mounted) {
        setState(() {
          _loadingProvider = null;
          _syncingAfterAuth = false;
        });
      }
    }
  }

  Future<String?> _registeredDeviceId() async {
    final deviceId = await _storage.ensureDeviceId();
    debugPrint('[SocialAuthUI] device id: available');
    try {
      await _deviceRegistration.ensureGuestRegistered(deviceId: deviceId);
      debugPrint('[SocialAuthUI] guest device registration: success');
      return deviceId;
    } on DeviceRegistrationException catch (error) {
      // device_id is optional for social login. Authentication must remain
      // available even when guest-device migration is temporarily unavailable.
      debugPrint(
        '[SocialAuthUI] guest device registration failed '
        '(status=${error.statusCode}, body=${error.body}); '
        'continuing with the stable device_id',
      );
      return deviceId;
    } catch (error, stackTrace) {
      debugPrint(
        '[SocialAuthUI] guest device registration unavailable: $error; '
        'continuing with the stable device_id',
      );
      debugPrintStack(
        label: '[SocialAuthUI] device registration stack trace',
        stackTrace: stackTrace,
      );
      return deviceId;
    }
  }

  Future<void> _linkDeviceToAuthenticatedUser(
    AuthResponse result,
    String? deviceId,
  ) async {
    final token = result.token;
    final userId = result.user?.id;
    if (deviceId == null ||
        deviceId.isEmpty ||
        token == null ||
        token.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return;
    }
    try {
      await _deviceRegistration.ensureRegistered(
        token: token,
        userId: userId,
        deviceId: deviceId,
        force: true,
      );
      debugPrint('[SocialAuthUI] authenticated device registration: success');
    } on DeviceRegistrationException catch (error) {
      debugPrint(
        '[SocialAuthUI] authenticated device registration failed '
        '(status=${error.statusCode}, body=${error.body})',
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[SocialAuthUI] authenticated device registration unavailable: $error',
      );
      debugPrintStack(
        label: '[SocialAuthUI] authenticated device registration stack trace',
        stackTrace: stackTrace,
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Добро пожаловать',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Войдите, чтобы синхронизировать задачи между устройствами',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 36),
                  _SocialButton(
                    label: 'Продолжить с Google',
                    icon: SvgPicture.asset(
                      'assets/icons/google_g.svg',
                      width: 22,
                      height: 22,
                    ),
                    loading: _loadingProvider == 'google',
                    enabled: _loadingProvider == null,
                    onPressed: () => _signIn('google'),
                  ),
                  if (_showApple) ...[
                    const SizedBox(height: 12),
                    _SocialButton(
                      label: 'Продолжить с Apple',
                      icon: const Icon(Icons.apple, size: 24),
                      loading: _loadingProvider == 'apple',
                      enabled: _loadingProvider == null,
                      onPressed: () => _signIn('apple'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'При первом входе аккаунт будет создан автоматически.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          if (_syncingAfterAuth)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: Center(child: _AuthenticationSyncProgress()),
              ),
            ),
        ],
      ),
    );
  }
}

class _AuthenticationSyncProgress extends StatelessWidget {
  const _AuthenticationSyncProgress();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Идёт синхронизация данных',
      liveRegion: true,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Синхронизация данных…',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Пожалуйста, подождите',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: BorderSide(color: ThemeColors.primary.withValues(alpha: .35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : icon,
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
