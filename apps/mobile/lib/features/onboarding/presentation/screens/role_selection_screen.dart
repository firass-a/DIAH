import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/onboarding_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../shared/enums/app_enums.dart';
import '../widgets/onboarding_widgets.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            Text(
              'Diah',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: DiahColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.t(
                'كيف ستستخدمين دياه؟',
                'Comment allez-vous utiliser Diah ?',
                'How will you use Diah?',
              ),
              style: GoogleFonts.cormorantGaramond(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.t(
                'يمكنك تفعيل أكثر من وضع لاحقاً من حسابك.',
                'Vous pourrez activer plusieurs modes plus tard.',
                'You can activate more than one mode later from your profile.',
              ),
              style: const TextStyle(color: DiahColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 28),
            RoleSelectionCard(
              title: s.t('استأجري فستاناً', 'Louer une robe', 'Rent a Dress'),
              description: s.t(
                'اعثري على الفستان المثالي لمناسبتك الخاصة.',
                'Trouvez la robe parfaite pour votre occasion.',
                'Find the perfect dress for your special occasion.',
              ),
              icon: Icons.search_rounded,
              actionLabel: s.t(
                'المتابعة كزبونة',
                'Continuer en cliente',
                'Continue as Customer',
              ),
              accent: const Color(0xFF887893),
              onTap: () {
                ref
                    .read(onboardingProvider.notifier)
                    .selectMode(AccountMode.customer);
                context.go('/onboarding/customer');
              },
            ),
            const SizedBox(height: 14),
            RoleSelectionCard(
              title: s.t(
                'أجّري فساتيني',
                'Louer mes robes',
                'Rent My Dresses',
              ),
              description: s.t(
                'شاركي فساتينك واكسبي دخلاً إضافياً.',
                'Partagez vos robes et gagnez un revenu.',
                'Share your dresses and earn additional income.',
              ),
              icon: Icons.checkroom_rounded,
              actionLabel: s.t(
                'أصبحي مؤجرة',
                'Devenir loueuse',
                'Become Owner',
              ),
              accent: const Color(0xFF9B6B8A),
              onTap: () {
                ref
                    .read(onboardingProvider.notifier)
                    .selectMode(AccountMode.individualOwner);
                context.go('/onboarding/owner');
              },
            ),
            const SizedBox(height: 14),
            RoleSelectionCard(
              title: s.t('أنشئي محلي', 'Créer ma boutique', 'Create My Store'),
              description: s.t(
                'أديري نشاط كراء فساتين احترافي.',
                'Gérez votre activité de location professionnelle.',
                'Manage your professional dress rental business.',
              ),
              icon: Icons.storefront_rounded,
              actionLabel: s.t('إنشاء محل', 'Créer la boutique', 'Create Store'),
              accent: const Color(0xFF6B5B7A),
              onTap: () {
                ref
                    .read(onboardingProvider.notifier)
                    .selectMode(AccountMode.storeOwner);
                context.go('/onboarding/store');
              },
            ),
          ],
        ),
      ),
    );
  }
}
