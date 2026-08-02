import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';

/// Dedicated activation: customer → professional store owner mode.
class CreateStoreScreen extends ConsumerStatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  ConsumerState<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends ConsumerState<CreateStoreScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController(text: 'الجزائر العاصمة');
  final _phone = TextEditingController();
  final _description = TextEditingController();
  StoreType _type = StoreType.wedding;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phone.text = ref.read(authProvider).user?.phone ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || _address.text.trim().isEmpty) {
      setState(() => _error = 'Complete store name and address');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).becomeStoreOwner(
        storeName: _name.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        type: _type,
        description: _description.text.trim(),
        phone: _phone.text.trim(),
        showBrandName: true,
      );
      if (mounted) context.go('/store');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.t(
            'أريد إنشاء محل كراء',
            'Créer ma boutique de location',
            'I want to create my rental store',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.t(
                'فعّلي وضع المحل المهني لإدارة المخزون والحجوزات والإيرادات.',
                'Activez le mode boutique pro pour gérer stock, réservations et revenus.',
                'Activate professional store mode to manage inventory, bookings, and revenue.',
              ),
              style: const TextStyle(
                color: DiahColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.t('معلومات المحل', 'Infos boutique', 'Store information'),
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: s.t('اسم المحل', 'Nom de la boutique', 'Store name'),
                prefixIcon: const Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(labelText: s.description),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: InputDecoration(
                labelText: s.t('العنوان', 'Adresse', 'Address'),
                prefixIcon: const Icon(Icons.location_on_outlined),
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
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: s.phone),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StoreType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: s.t('نوع النشاط', "Type d'activité", 'Business type'),
              ),
              items: [
                DropdownMenuItem(
                  value: StoreType.wedding,
                  child: Text(
                    s.t('فساتين أعراس', 'Robes de mariée', 'Wedding Dresses'),
                  ),
                ),
                DropdownMenuItem(
                  value: StoreType.evening,
                  child: Text(
                    s.t('فساتين سهرات', 'Soirée', 'Evening Dresses'),
                  ),
                ),
                DropdownMenuItem(
                  value: StoreType.traditional,
                  child: Text(
                    s.t('تقليدية', 'Traditionnel', 'Traditional Dresses'),
                  ),
                ),
                DropdownMenuItem(
                  value: StoreType.multi,
                  child: Text(s.t('متعدد', 'Mixte', 'Mixed')),
                ),
              ],
              onChanged: (v) => setState(() => _type = v ?? StoreType.wedding),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: DiahColors.error)),
            ],
            const SizedBox(height: 28),
            PrimaryButton(
              label: s.t(
                'تفعيل لوحة المحل',
                'Activer le tableau de bord',
                'Activate store dashboard',
              ),
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
