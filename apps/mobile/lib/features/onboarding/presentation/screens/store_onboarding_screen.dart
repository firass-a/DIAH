import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/fake_backend/onboarding_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/dress_image.dart';
import '../../../../shared/enums/app_enums.dart';
import '../widgets/onboarding_widgets.dart';

class StoreOnboardingScreen extends ConsumerStatefulWidget {
  const StoreOnboardingScreen({super.key});

  @override
  ConsumerState<StoreOnboardingScreen> createState() =>
      _StoreOnboardingScreenState();
}

class _StoreOnboardingScreenState extends ConsumerState<StoreOnboardingScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _phone;
  late final TextEditingController _storeName;
  late final TextEditingController _bio;
  late final TextEditingController _desc;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _bizPhone;
  bool _loading = false;

  static const _categories = [
    'Wedding',
    'Evening',
    'Traditional',
    'Accessories',
  ];
  static const _inventorySizes = ['Less than 20', '20-50', '50+'];

  @override
  void initState() {
    super.initState();
    final d = ref.read(onboardingProvider);
    _first = TextEditingController(text: d.firstName);
    _last = TextEditingController(text: d.lastName);
    _phone = TextEditingController(text: d.phone);
    _storeName = TextEditingController(text: d.storeName);
    _bio = TextEditingController(text: d.storeBio);
    _desc = TextEditingController(text: d.storeDescription);
    _address = TextEditingController(text: d.storeAddress);
    _city = TextEditingController(text: d.storeCity);
    _bizPhone = TextEditingController(text: d.businessPhone);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _storeName.dispose();
    _bio.dispose();
    _desc.dispose();
    _address.dispose();
    _city.dispose();
    _bizPhone.dispose();
    super.dispose();
  }

  Future<String?> _pickImage() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery);
    return f?.path;
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
      );
      n.nextStep();
      return;
    }
    if (draft.step == 1) {
      if (_storeName.text.trim().isEmpty) return;
      n.updateStore(
        storeName: _storeName.text.trim(),
        storeBio: _bio.text.trim(),
        storeDescription: _desc.text.trim(),
        storeAddress: _address.text.trim(),
        storeCity: _city.text.trim(),
        businessPhone: _bizPhone.text.trim(),
      );
      n.nextStep();
      return;
    }
    if (draft.step == 2 || draft.step == 3) {
      if (draft.step == 3 &&
          (draft.categories.isEmpty || draft.inventorySizeRange == null)) {
        return;
      }
      n.nextStep();
      return;
    }
    // verification / finish
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
      totalSteps: 5,
      onBack: () {
        if (draft.step == 0) {
          context.go('/onboarding/role');
        } else {
          n.previousStep();
        }
      },
      bottom: ContinueButton(
        label: draft.step == 4
            ? s.t('إنهاء وإنشاء المحل', 'Créer la boutique', 'Create store')
            : s.continueText,
        isLoading: _loading,
        onPressed: () => _continue(s),
      ),
      child: switch (draft.step) {
        0 => FormSection(
            title: s.t('معلومات المالكة', 'Infos propriétaire', 'Owner information'),
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
              ],
            ),
          ),
        1 => FormSection(
            title: s.t('معلومات المحل', 'Infos boutique', 'Store information'),
            child: Column(
              children: [
                TextField(
                  controller: _storeName,
                  decoration: InputDecoration(
                    labelText: s.t('اسم المحل', 'Nom boutique', 'Store name'),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ImagePickBox(
                        label: s.t('الشعار', 'Logo', 'Logo'),
                        path: draft.storeLogo,
                        onTap: () async {
                          final p = await _pickImage();
                          if (p != null) n.updateStore(storeLogo: p);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ImagePickBox(
                        label: s.t('الغلاف', 'Couverture', 'Cover'),
                        path: draft.storeCover,
                        onTap: () async {
                          final p = await _pickImage();
                          if (p != null) n.updateStore(storeCover: p);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bio,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: s.t('نبذة', 'Bio', 'Bio'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: s.description),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _address,
                  decoration: InputDecoration(
                    labelText: s.t('العنوان', 'Adresse', 'Address'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _city,
                  decoration: InputDecoration(
                    labelText: s.t('المدينة', 'Ville', 'City'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bizPhone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: s.t(
                      'هاتف المحل',
                      'Téléphone boutique',
                      'Business phone',
                    ),
                  ),
                ),
              ],
            ),
          ),
        2 => FormSection(
            title: s.t('نوع النشاط', 'Type d’activité', 'Business type'),
            child: Column(
              children: StoreType.values.map((t) {
                final label = switch (t) {
                  StoreType.wedding =>
                    s.t('فساتين أعراس', 'Mariage', 'Wedding Dresses'),
                  StoreType.evening =>
                    s.t('فساتين سهرات', 'Soirée', 'Evening Dresses'),
                  StoreType.traditional =>
                    s.t('تقليدية', 'Traditionnel', 'Traditional Dresses'),
                  StoreType.multi => s.t('متنوع', 'Mixte', 'Mixed'),
                };
                final selected = draft.businessType == t;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: selected ? DiahColors.softLavender : DiahColors.card,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => n.updateStore(businessType: t),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? DiahColors.primary
                                : DiahColors.border,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        3 => FormSection(
            title: s.t('المخزون', 'Inventaire', 'Inventory information'),
            subtitle: s.t(
              'ما نوع الفساتين التي تبيعونها؟',
              'Quels types de robes proposez-vous ?',
              'What type of dresses do you sell?',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PreferenceSelector(
                  options: _categories,
                  selected: draft.categories,
                  onToggle: (v) => n.toggleInList('categories', v),
                ),
                const SizedBox(height: 20),
                Text(
                  s.t(
                    'كم فستاناً لديكم؟',
                    'Combien de robes avez-vous ?',
                    'How many dresses do you have?',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ..._inventorySizes.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: draft.inventorySizeRange == c
                          ? DiahColors.softLavender
                          : DiahColors.card,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => n.updateStore(inventorySizeRange: c),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: draft.inventorySizeRange == c
                                  ? DiahColors.primary
                                  : DiahColors.border,
                            ),
                          ),
                          child: Text(c),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        _ => FormSection(
            title: s.t('تحقق المحل', 'Vérification boutique', 'Store verification'),
            subtitle: s.t(
              'تحقق وهمي — الحالة: قيد المراجعة',
              'Vérification fictive — en attente',
              'Mock verification — status: Pending',
            ),
            child: VerificationCard(
              title: s.t('مستندات المحل', 'Documents', 'Business documents'),
              body: s.t(
                'اسم النشاط، هوية المالكة، صور المحل، إثبات العنوان',
                'Nom, identité, photos, preuve d’adresse',
                'Business name, owner ID, store photos, address proof',
              ),
              child: Column(
                children: [
                  Text(
                    _storeName.text.isEmpty ? '—' : _storeName.text,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final p = await _pickImage();
                      if (p != null) n.updateStore(storePhoto: p);
                    },
                    icon: const Icon(Icons.store_outlined),
                    label: Text(
                      draft.storePhoto == null
                          ? s.t('صور المحل', 'Photos boutique', 'Store photos')
                          : s.t('تم الرفع', 'Ajouté', 'Uploaded'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final p = await _pickImage();
                      if (p != null) n.updateStore(addressProofImage: p);
                    },
                    icon: const Icon(Icons.home_work_outlined),
                    label: Text(
                      draft.addressProofImage == null
                          ? s.t('إثبات العنوان', 'Preuve adresse', 'Address proof')
                          : s.t('تم الرفع', 'Ajouté', 'Uploaded'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      },
    );
  }
}

class _ImagePickBox extends StatelessWidget {
  const _ImagePickBox({
    required this.label,
    required this.path,
    required this.onTap,
  });

  final String label;
  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: DiahColors.softLavender,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DiahColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: path == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: DiahColors.primary),
                  const SizedBox(height: 6),
                  Text(label, style: const TextStyle(fontSize: 12)),
                ],
              )
            : DressImage(source: path!, height: 100, width: double.infinity),
      ),
    );
  }
}
