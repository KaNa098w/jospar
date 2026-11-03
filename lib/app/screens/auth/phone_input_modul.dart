import 'dart:async';

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
  const AuthPage({super.key, this.emailMode = false});

  final bool emailMode;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SocialAuthService _socialAuth = SocialAuthService();
  final AuthService _authService = AuthService();
  final AuthStorage _storage = AuthStorage();
  final DeviceRegistrationService _deviceRegistration =
      DeviceRegistrationService();
  String? _loadingProvider;
  bool _syncingAfterAuth = false;
  bool _registering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  int _retrySeconds = 0;
  Timer? _retryTimer;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final Map<String, String> _serverErrors = {};

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
      await _completeAuthentication(result, deviceId);
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

  Future<void> _submitEmailAuth() async {
    if (_loadingProvider != null || _retrySeconds > 0) return;
    setState(_serverErrors.clear);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loadingProvider = 'email');
    try {
      final email = _emailController.text.trim().toLowerCase();
      _emailController.text = email;
      final deviceId = await _registeredDeviceId();
      final result = _registering
          ? await _authService.register(
              email: email,
              password: _passwordController.text,
              passwordConfirmation: _passwordConfirmationController.text,
              firstName: _optionalText(_firstNameController),
              lastName: _optionalText(_lastNameController),
              deviceId: deviceId,
            )
          : await _authService.login(
              email: email,
              password: _passwordController.text,
              deviceId: deviceId,
            );
      await _completeAuthentication(result, deviceId);
    } on AuthException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 429) {
        _showError(_messageFor(error));
        _startRetryCooldown(error.retryAfter ?? const Duration(seconds: 30));
      } else if (error.details.isNotEmpty) {
        setState(() {
          for (final entry in error.details.entries) {
            if (entry.value.isNotEmpty) {
              _serverErrors[entry.key] = entry.value.first;
            }
          }
        });
        _formKey.currentState?.validate();
      } else {
        _showError(_messageFor(error));
      }
    } catch (error) {
      _showError(
          'Не удалось выполнить вход. Проверьте подключение к интернету.');
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String _messageFor(AuthException error) {
    if (error.statusCode == 401 || error.code == 'invalid_credentials') {
      return 'Неверный email или пароль.';
    }
    if (error.statusCode == 429) {
      return 'Слишком много попыток. Повторите позже.';
    }
    return error.message;
  }

  void _startRetryCooldown(Duration duration) {
    _retryTimer?.cancel();
    setState(() => _retrySeconds = duration.inSeconds.clamp(1, 300));
    _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _retrySeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _retrySeconds = 0);
      } else {
        setState(() => _retrySeconds--);
      }
    });
  }

  Future<void> _completeAuthentication(
    AuthResponse result,
    String? deviceId,
  ) async {
    if (!mounted) return;
    setState(() => _syncingAfterAuth = true);
    await _linkDeviceToAuthenticatedUser(result, deviceId);
    if (!mounted) return;
    await context.read<GlobalProvider>().setAuthData(result);
    if (!mounted) return;
    context.go('/preloader');
  }

  void _switchMode() {
    setState(() {
      _registering = !_registering;
      _serverErrors.clear();
      _passwordController.clear();
      _passwordConfirmationController.clear();
    });
  }

  void _clearServerError(String field) {
    if (_serverErrors.remove(field) != null) setState(() {});
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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
        title: widget.emailMode
            ? Text(_registering ? 'Регистрация' : 'Вход')
            : null,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child:
                    widget.emailMode ? _buildEmailForm() : _buildAuthOptions(),
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

  Widget _buildAuthOptions() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height - 160,
      ),
      child: Column(
        key: const ValueKey('auth-options'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SocialButton(
            label: 'Войти',
            loading: false,
            enabled: _loadingProvider == null,
            onPressed: () => context.push('/auth/email'),
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  Widget _buildEmailForm() {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    return Form(
      key: _formKey,
      child: Column(
        key: ValueKey(_registering ? 'register-form' : 'login-form'),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: ThemeColors.primary.withValues(alpha: .10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _registering
                        ? Icons.person_add_alt_1_rounded
                        : Icons.mail_outline_rounded,
                    color: ThemeColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _registering ? 'Создать аккаунт' : 'Вход в аккаунт',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _registering
                      ? 'Заполните данные для регистрации'
                      : 'Введите email и пароль',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  enabled: _loadingProvider == null,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    errorText: _serverErrors['email'],
                  ),
                  onChanged: (_) => _clearServerError('email'),
                  validator: (value) {
                    if (_serverErrors['email'] != null) return null;
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Введите email';
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                        .hasMatch(email)) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                ),
                if (_registering) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _firstNameController,
                    enabled: _loadingProvider == null,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Имя (необязательно)',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      errorText: _serverErrors['first_name'],
                    ),
                    onChanged: (_) => _clearServerError('first_name'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _lastNameController,
                    enabled: _loadingProvider == null,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Фамилия (необязательно)',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      errorText: _serverErrors['last_name'],
                    ),
                    onChanged: (_) => _clearServerError('last_name'),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  enabled: _loadingProvider == null,
                  obscureText: _obscurePassword,
                  autofillHints: _registering
                      ? const [AutofillHints.newPassword]
                      : const [AutofillHints.password],
                  textInputAction: _registering
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_registering) _submitEmailAuth();
                  },
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                    border: inputBorder,
                    enabledBorder: inputBorder,
                    errorText: _serverErrors['password'],
                  ),
                  onChanged: (_) => _clearServerError('password'),
                  validator: (value) {
                    if (_serverErrors['password'] != null) return null;
                    if ((value ?? '').length < 8) return 'Минимум 8 символов';
                    return null;
                  },
                ),
                if (_registering) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordConfirmationController,
                    enabled: _loadingProvider == null,
                    obscureText: _obscureConfirmation,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitEmailAuth(),
                    decoration: InputDecoration(
                      labelText: 'Повторите пароль',
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirmation = !_obscureConfirmation,
                        ),
                        icon: Icon(_obscureConfirmation
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                      ),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      errorText: _serverErrors['password_confirmation'],
                    ),
                    onChanged: (_) =>
                        _clearServerError('password_confirmation'),
                    validator: (value) {
                      if (_serverErrors['password_confirmation'] != null) {
                        return null;
                      }
                      if (value != _passwordController.text) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _loadingProvider == null && _retrySeconds == 0
                        ? _submitEmailAuth
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: ThemeColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loadingProvider == 'email'
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _retrySeconds > 0
                                ? 'Повторить через $_retrySeconds сек.'
                                : _registering
                                    ? 'Создать аккаунт'
                                    : 'Войти',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loadingProvider == null ? _switchMode : null,
                  child: Text(
                    _registering
                        ? 'Уже есть аккаунт? Войти'
                        : 'Нет аккаунта? Создать',
                  ),
                ),
              ],
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
    this.icon,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final Widget? icon;
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final displayedIcon = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon;
    final style = OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: BorderSide(color: ThemeColors.primary.withValues(alpha: .35)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
    final labelWidget = Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: displayedIcon == null
          ? OutlinedButton(
              onPressed: enabled ? onPressed : null,
              style: style,
              child: labelWidget,
            )
          : OutlinedButton.icon(
              onPressed: enabled ? onPressed : null,
              style: style,
              icon: displayedIcon,
              label: labelWidget,
            ),
    );
  }
}
