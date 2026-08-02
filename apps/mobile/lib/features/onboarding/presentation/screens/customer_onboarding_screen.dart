import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/fake_backend/onboarding_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../widgets/onboarding_widgets.dart';

class CustomerOnboardingScreen extends ConsumerStatefulWidget {
  const CustomerOnboardingScreen({super.key});

  @override
  ConsumerState<CustomerOnboardingScreen> createState() =>
      _CustomerOnboardingScreenState();
}

class _CustomerOnboardingScreenState
    extends ConsumerState<CustomerOnboardingScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _otp;
  bool _loading = false;

  static const _categories = [
    'Wedding Dresses',
    'Evening Dresses',
    'Traditional Dresses',
    'Karakou',
    'Caftan',
    'Accessories',
  ];
  static const _occasions = [
    'Wedding',
    'Engagement',
    'Party',
    'Graduation',
    'Formal Event',
  ];
  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];
  static const _colors = [
    'White',
    'Black',
    'Red',
    'Gold',
    'Green',
    'Pink',
    'Purple',
  ];

  @override
  void initState() {
    super.initState();
    final d = ref.read(onboardingProvider);
    _first = TextEditingController(text: d.firstName);
    _last = TextEditingController(text: d.lastName);
    _phone = TextEditingController(text: d.phone);
    _city = TextEditingController(text: d.city);
    _otp = TextEditingController();
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _city.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _continue(AppStrings s) async {
    final n = ref.read(onboardingProvider.notifier);
    final draft = ref.read(onboardingProvider);

    if (draft.step == 0) {
      if (_first.text.trim().isEmpty) return;
      n.updatePersonal(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        phone: _phone.text.trim(),
        city: _city.text.trim(),
      );
      n.nextStep();
      return;
    }
    if (draft.step == 1) {
      n.nextStep();
      return;
    }
    // verification
    if (!draft.otpSent) {
      n.updatePersonal(phone: _phone.text.trim());
      await n.sendOtp();
      setState(() {});
      return;
    }
    if (!draft.otpVerified) {
      final ok = await n.verifyOtp(_otp.text.trim());
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.t('رمز خاطئ — جرّبي 1234', 'Code: 1234', 'Use code 1234'))),
        );
        return;
      }
    }
    setState(() => _loading = true);
    try {
      final route = await n.completeOnboarding();
      if (mounted) context.go('/onboarding/complete?next=${Uri.encodeComponent(route)}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final draft = ref.watch(onboardingProvider);
    final n = ref.read(onboardingProvider.notifier);

    return OnboardingScaffold(
      step: draft.step,
      totalSteps: 3,
      onBack: () {
        if (draft.step == 0) {
          context.go('/onboarding/role');
        } else {
          n.previousStep();
        }
      },
      bottom: ContinueButton(
        label: draft.step == 2 && draft.otpVerified
            ? s.t('إنهاء', 'Terminer', 'Finish')
            : draft.step == 2 && !draft.otpSent
                ? s.t('إرسال الرمز', 'Envoyer le code', 'Send code')
                : draft.step == 2
                    ? s.t('تحقق', 'Vérifier', 'Verify')
                    : s.continueText,
        isLoading: _loading,
        onPressed: () => _continue(s),
      ),
      child: draft.step == 0
          ? FormSection(
              title: s.t('معلوماتك الشخصية', 'Vos informations', 'Personal information'),
              subtitle: s.t(
                'لنتعرّف عليكِ قليلاً',
                'Faisons connaissance',
                'Let’s get to know you',
              ),
              child: Column(
                children: [
                  ProfileImagePicker(
                    imagePath: draft.profileImage,
                    onPicked: (p) => n.updatePersonal(profileImage: p),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _first,
                    decoration: InputDecoration(
                      labelText: s.t('الاسم', 'Prénom', 'First name'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _last,
                    decoration: InputDecoration(
                      labelText: s.t('اللقب', 'Nom', 'Last name'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: s.phone),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _city,
                    decoration: InputDecoration(
                      labelText: s.t('المدينة', 'Ville', 'City'),
                    ),
                  ),
                ],
              ),
            )
          : draft.step == 1
              ? FormSection(
                  title: s.t('ذوقكِ في الموضة', 'Vos goûts', 'Fashion preferences'),
                  subtitle: s.t(
                    'اختاري ما يناسب أسلوبك',
                    'Choisissez votre style',
                    'Choose what matches your style',
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.categories,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      PreferenceSelector(
                        options: _categories,
                        selected: draft.categories,
                        onToggle: (v) => n.toggleInList('categories', v),
                      ),
                      const SizedBox(height: 18),
                      Text(s.occasion,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      PreferenceSelector(
                        options: _occasions,
                        selected: draft.occasions,
                        onToggle: (v) => n.toggleInList('occasions', v),
                      ),
                      const SizedBox(height: 18),
                      Text(s.size,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      PreferenceSelector(
                        options: _sizes,
                        selected: draft.sizes,
                        onToggle: (v) => n.toggleInList('sizes', v),
                      ),
                      const SizedBox(height: 18),
                      Text(s.color,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      PreferenceSelector(
                        options: _colors,
                        selected: draft.colors,
                        onToggle: (v) => n.toggleInList('colors', v),
                      ),
                    ],
                  ),
                )
              : FormSection(
                  title: s.t('التحقق', 'Vérification', 'Verification'),
                  subtitle: s.t(
                    'تحقّقي من رقم هاتفكِ (رمز تجريبي 1234)',
                    'Vérifiez votre téléphone (code 1234)',
                    'Verify your phone (demo code 1234)',
                  ),
                  child: VerificationCard(
                    title: s.otpTitle,
                    body: draft.otpVerified
                        ? s.t(
                            'تم التحقق بنجاح ✨',
                            'Vérifié avec succès',
                            'Verified successfully',
                          )
                        : s.otpHint,
                    child: Column(
                      children: [
                        TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          enabled: !draft.otpVerified,
                          decoration: InputDecoration(labelText: s.phone),
                        ),
                        if (draft.otpSent && !draft.otpVerified) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _otp,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: s.otpTitle),
                          ),
                        ],
                        if (draft.otpVerified)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Icon(Icons.check_circle,
                                color: DiahColors.success, size: 40),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
