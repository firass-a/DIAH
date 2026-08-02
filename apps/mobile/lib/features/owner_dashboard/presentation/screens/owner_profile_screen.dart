import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/owner_providers.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../widgets/owner_widgets.dart';
import 'owner_shell.dart';

class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(authProvider).user;
    final stats = ref.watch(ownerStatisticsProvider);
    final address = user?.addresses.isNotEmpty == true
        ? user!.addresses.first
        : null;

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      appBar: OwnerAppBar(
        title: s.profile,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          OwnerCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: OwnerColors.accentSoft,
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage!)
                      : null,
                  child: user?.profileImage == null
                      ? Text(
                          (user?.fullName.isNotEmpty == true
                                  ? user!.fullName[0]
                                  : '?')
                              .toUpperCase(),
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 36,
                            color: OwnerColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  user?.fullName ?? '',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.roleOwner,
                  style: const TextStyle(
                    color: OwnerColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OwnerCard(
            child: Column(
              children: [
                _infoRow(Icons.phone_outlined, user?.phone ?? '—'),
                const Divider(height: 24),
                _infoRow(
                  Icons.location_on_outlined,
                  address != null
                      ? '${address.street}, ${address.city}'
                      : s.t('لا يوجد عنوان', 'Pas d’adresse', 'No address'),
                ),
                const Divider(height: 24),
                _infoRow(
                  Icons.checkroom_outlined,
                  s.t(
                    '${stats.dressCount} فستان مملوك',
                    '${stats.dressCount} robe(s)',
                    '${stats.dressCount} owned dress(es)',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OwnerSectionTitle(s.statistics),
          Row(
            children: [
              Expanded(
                child: OwnerStatCard(
                  label: s.t('إيجارات نشطة', 'Actives', 'Active'),
                  value: '${stats.activeRentals}',
                  icon: Icons.timelapse,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OwnerStatCard(
                  label: s.revenue,
                  value: s.formatPrice(stats.totalEarnings),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OwnerCard(
            onTap: () => context.go('/home'),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.storefront_outlined, color: OwnerColors.accent),
              title: Text(
                s.t(
                  'تصفّح كزبونة',
                  'Parcourir en cliente',
                  'Browse as customer',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 10),
          OwnerCard(
            onTap: () => context.push('/profile/edit'),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit_outlined, color: OwnerColors.accent),
              title: Text(s.t('تعديل الملف', 'Modifier le profil', 'Edit profile')),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 10),
          OwnerCard(
            onTap: () => context.push('/owner/history'),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: OwnerColors.accent),
              title: Text(s.t('سجل الإيجار', 'Historique', 'Rental history')),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: Text(s.t('تسجيل الخروج', 'Déconnexion', 'Log out')),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: OwnerColors.accent, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}
