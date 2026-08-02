import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/fake_backend/onboarding_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../widgets/onboarding_widgets.dart';

class OwnerOnboardingScreen extends ConsumerStatefulWidget {
  const OwnerOnboardingScreen({super.key});

  @override
  ConsumerState<OwnerOnboardingScreen> createState() =>
      _OwnerOnboardingScreenState();
}

class _OwnerOnboardingScreenState extends ConsumerState<OwnerOnboardingScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _legal;
  late final TextEditingController _otp;
  bool _loading = false;

  static const _categories = [
    'Wedding',
    'Evening',
    'Traditional',
    'Karakou',
    'Accessories',
  ];
  static const _counts = ['1-3', '4-10', '10+'];

  @override
  void initState() {
    super.initState();
    final d = ref.read(onboardingProvider);
    _first = TextEditingController(text: d.firstName);
    _last = TextEditingController(text: d.lastName);
    _phone = TextEditingController(text: d.phone);
    _city = TextEditingController(text: d.city);
    _legal = TextEditingController(text: d.legalFullName);
    _otp = TextEditingController();
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _city.dispose();
    _legal.dispose();
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
      if (draft.categories.isEmpty || draft.dressCountRange == null) return;
      n.nextStep();
      return;
    }
    if (draft.step == 2) {
      n.nextStep();
      return;
    }
    // verification
    n.setLegalName(_legal.text.trim());
    n.updatePersonal(phone: _phone.text.trim());
    if (!draft.otpSent) {
      await n.sendOtp();
      setState(() {});
      return;
    }
    if (!draft.otpVerified) {
      final ok = await n.verifyOtp(_otp.text.trim());
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.t('الرمز 1234', 'Code 1234', 'Code 1234'))),
        );
        return;
      }
    }
    setState(() => _loading = true);
    try {
      final route = await n.completeOnboarding();
      if (mounted) {
        context.go('/onboarding/complete?next=${Uri.encodeComponent(route)}');
      }
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
      totalSteps: 4,
      onBack: () {
        if (draft.step == 0) {
          context.go('/onboarding/role');
        } else {
          n.previousStep();
        }
      },
      bottom: ContinueButton(
        label: draft.step == 3 && draft.otpVerified
            ? s.t('إنهاء', 'Terminer', 'Finish')
            : draft.step == 3 && !draft.otpSent
                ? s.t('إرسال الرمز', 'Envoyer', 'Send code')
                : draft.step == 3
                    ? s.verify
                    : s.continueText,
        isLoading: _loading,
        onPressed: () => _continue(s),
      ),
      child: switch (draft.step) {
        0 => FormSection(
            title: s.t('معلوماتك', 'Vos infos', 'Personal information'),
            subtitle: s.t(
              'خزانة شخصية — ليست محلّاً تجارياً',
              'Garde-robe personnelle — pas une boutique',
              'Personal wardrobe — not a store',
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
          ),
        1 => FormSection(
            title: s.t('خزانتك', 'Votre garde-robe', 'Wardrobe information'),
            subtitle: s.t(
              'ما نوع الفساتين التي تريدين تأجيرها؟',
              'Quels types de robes souhaitez-vous louer ?',
              'What type of dresses do you want to rent?',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PreferenceSelector(
                  options: _categories,
                  selected: draft.categories,
                  onToggle: (v) => n.toggleInList('categories', v),
                ),
                const SizedBox(height: 24),
                Text(
                  s.t(
                    'كم فستاناً تريدين تأجيره؟',
                    'Combien de robes ?',
                    'How many dresses do you want to rent?',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ..._counts.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: draft.dressCountRange == c
                          ? DiahColors.softLavender
                          : DiahColors.card,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => n.setDressCountRange(c),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: draft.dressCountRange == c
                                  ? DiahColors.primary
                                  : DiahColors.border,
                            ),
                          ),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontWeight: draft.dressCountRange == c
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        2 => FormSection(
            title: s.t('أول فستان', 'Première robe', 'First dress setup'),
            subtitle: s.t(
              'هل تريدين إضافة أول فستان الآن؟',
              'Ajouter votre première robe maintenant ?',
              'Would you like to add your first dress now?',
            ),
            child: Column(
              children: [
                _ChoiceTile(
                  selected: draft.addFirstDressNow,
                  title: s.t('نعم، الآن', 'Oui, maintenant', 'Yes'),
                  onTap: () => n.setAddFirstDress(true),
                ),
                const SizedBox(height: 10),
                _ChoiceTile(
                  selected: !draft.addFirstDressNow,
                  title: s.t('لا، لاحقاً', 'Non, plus tard', 'No, later'),
                  onTap: () => n.setAddFirstDress(false),
                ),
              ],
            ),
          ),
        _ => FormSection(
            title: s.t('التحقق من الهوية', 'Vérification', 'Identity verification'),
            subtitle: s.t(
              'تحقق وهمي للنموذج الأولي — الحالة: قيد المراجعة',
              'Vérification fictive — statut : en attente',
              'Mock verification — status: Pending',
            ),
            child: VerificationCard(
              title: s.t('بطاقة الهوية', 'Pièce d’identité', 'ID card'),
              body: s.t(
                'ارفع صورة الهوية وأدخلي الاسم الكامل',
                'Ajoutez une photo d’identité',
                'Upload ID image and enter your full name',
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _legal,
                    decoration: InputDecoration(
                      labelText: s.t('الاسم الكامل', 'Nom complet', 'Full name'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final f = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (f != null) n.setIdCard(f.path);
                    },
                    icon: const Icon(Icons.badge_outlined),
                    label: Text(
                      draft.idCardImage == null
                          ? s.t('رفع صورة الهوية', 'Ajouter ID', 'Upload ID image')
                          : s.t('تم رفع الصورة', 'Image ajoutée', 'Image added'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
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
      },
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DiahColors.softLavender : DiahColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? DiahColors.primary : DiahColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: DiahColors.primary,
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
