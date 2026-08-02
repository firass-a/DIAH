import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/routing/role_home.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_logo.dart';
import '../../../../core/widgets/diah_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController(text: '0555123456');
  final _password = TextEditingController(text: '123456');
  bool _obscure = true;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final ok = await ref
        .read(authProvider.notifier)
        .login(_phone.text.trim(), _password.text);
    if (ok && mounted) context.go(homeRouteFromRef(ref));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(child: DiahLogo(size: 110)),
              const SizedBox(height: 16),
              Text(
                s.tagline,
                textAlign: TextAlign.center,
                style: const TextStyle(color: DiahColors.textSecondary),
              ),
              const SizedBox(height: 32),
              Text(
                s.login,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: s.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: s.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(s.forgotPassword),
                ),
              ),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: DiahColors.error),
                  ),
                ),
              PrimaryButton(
                label: s.login,
                isLoading: auth.isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: s.guest,
                onPressed: () async {
                  await ref.read(authProvider.notifier).loginAsGuest();
                  if (context.mounted) context.go(homeRouteFromRef(ref));
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.t('ليس لديك حساب؟', "Pas de compte ?", "Don't have an account?"),
                    style: const TextStyle(color: DiahColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(s.register),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LuxuryCard(
                color: DiahColors.softLavender,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.demoAccounts,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    _DemoChip(
                      label: '${s.roleCustomer} — سارة',
                      phone: '0555123456',
                      onTap: () {
                        _phone.text = '0555123456';
                        _password.text = '123456';
                      },
                    ),
                    _DemoChip(
                      label: '${s.roleOwner} — أمينة',
                      phone: '0666789012',
                      onTap: () {
                        _phone.text = '0666789012';
                        _password.text = '123456';
                      },
                    ),
                    _DemoChip(
                      label: '${s.roleStore} — فاطمة',
                      phone: '0777111222',
                      onTap: () {
                        _phone.text = '0777111222';
                        _password.text = '123456';
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip({
    required this.label,
    required this.phone,
    required this.onTap,
  });

  final String label;
  final String phone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: DiahColors.primary),
            const SizedBox(width: 8),
            Text('$label — $phone', style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _password.text.length < 4) {
      return;
    }
    final ok = await ref.read(authProvider.notifier).register(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text,
    );
    if (ok && mounted) context.go('/onboarding/role');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.register)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: s.fullName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: s.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: s.password,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            if (auth.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(auth.error!, style: const TextStyle(color: DiahColors.error)),
              ),
            PrimaryButton(
              label: s.register,
              isLoading: auth.isLoading,
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(_phone.text.trim());
    setState(() => _loading = false);
    if (ok && mounted) {
      context.push('/otp', extra: _phone.text.trim());
    } else {
      setState(() => _error = 'رقم الهاتف غير مسجل');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.forgotPassword)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: s.phone),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: DiahColors.error)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: s.continueText,
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otp = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await ref
        .read(authRepositoryProvider)
        .verifyOtp(widget.phone, _otp.text.trim());
    setState(() => _loading = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(stringsProvider).t(
              'تم التحقق بنجاح. يمكنك تسجيل الدخول.',
              'Vérifié. Vous pouvez vous connecter.',
              'Verified. You can log in now.',
            ),
          ),
        ),
      );
      context.go('/login');
    } else {
      setState(() => _error = 'رمز غير صحيح');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.otpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(s.otpHint, style: const TextStyle(color: DiahColors.textSecondary)),
            const SizedBox(height: 24),
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, letterSpacing: 12),
              decoration: const InputDecoration(hintText: '••••'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: DiahColors.error)),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: s.verify,
              isLoading: _loading,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}
