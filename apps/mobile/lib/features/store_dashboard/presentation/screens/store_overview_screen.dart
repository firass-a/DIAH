import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/store_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../core/widgets/dress_image.dart';
import '../../../../shared/enums/app_enums.dart';
import '../widgets/store_widgets.dart';
import 'store_shell.dart';

class StoreOverviewScreen extends ConsumerWidget {
  const StoreOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final store = ref.watch(currentStoreProvider);
    final stats = ref.watch(storeStatsProvider);
    final bookings = ref.watch(storeBookingsProvider);
    final pending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .take(3)
        .toList();

    if (store == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: StoreAppBar(
        title: s.t('لوحة المحل', 'Espace boutique', 'Store dashboard'),
        showAccount: true,
        actions: [
          IconButton(
            onPressed: () => context.push('/store/analytics'),
            icon: const Icon(Icons.insights_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          StorePanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: DressImage(
                    source: store.coverImage ?? store.imageUrl ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      ClipOval(
                        child: DressImage(
                          source: store.logo ?? store.imageUrl ?? '',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.storeName,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _businessLabel(store.type, s),
                              style: const TextStyle(
                                fontSize: 12,
                                color: DiahColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RatingWidget(rating: store.rating),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StoreSectionTitle(
            s.t('نظرة عامة', 'Vue d\'ensemble', 'Overview'),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              StoreStatCard(
                label: s.t('إجمالي الفساتين', 'Robes totales', 'Total dresses'),
                value: '${stats.totalDresses}',
                icon: Icons.checkroom_outlined,
                onTap: () => context.go('/store/inventory'),
              ),
              StoreStatCard(
                label: s.t('إيجارات نشطة', 'Locations actives', 'Active rentals'),
                value: '${stats.activeRentals}',
                icon: Icons.timelapse,
                accent: const Color(0xFF5A8F7B),
              ),
              StoreStatCard(
                label: s.t('حجوزات معلقة', 'En attente', 'Pending bookings'),
                value: '${stats.pendingBookings}',
                icon: Icons.pending_actions_outlined,
                accent: DiahColors.warning,
                onTap: () => context.go('/store/bookings'),
              ),
              StoreStatCard(
                label: s.t('إيراد الشهر', 'Revenu du mois', 'Monthly revenue'),
                value: s.formatPrice(stats.monthlyRevenue),
                icon: Icons.payments_outlined,
                accent: const Color(0xFF6B5B7A),
                onTap: () => context.push('/store/revenue'),
              ),
              StoreStatCard(
                label: s.t('مكتملة', 'Terminées', 'Completed rentals'),
                value: '${stats.completedRentals}',
                icon: Icons.task_alt,
              ),
              StoreStatCard(
                label: s.t('متوسط التقييم', 'Note moyenne', 'Average rating'),
                value: stats.averageRating.toStringAsFixed(1),
                icon: Icons.star_outline,
                accent: const Color(0xFFD4A017),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StoreSectionTitle(
            s.t('طلبات تحتاج إجراء', 'À traiter', 'Needs action'),
            trailing: TextButton(
              onPressed: () => context.go('/store/bookings'),
              child: Text(s.seeAll),
            ),
          ),
          if (pending.isEmpty)
            StorePanel(
              child: Text(
                s.t(
                  'لا توجد حجوزات معلقة',
                  'Aucune réservation en attente',
                  'No pending bookings',
                ),
                style: const TextStyle(color: DiahColors.textMuted),
              ),
            )
          else
            ...pending.map((b) {
              final dresses = ref.watch(storeDressesProvider);
              final dress = dresses.where((d) => d.id == b.dressId).firstOrNull;
              final name = dress?.name ?? b.dressId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StorePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '${b.startDate.toString().substring(0, 10)} → ${b.endDate.toString().substring(0, 10)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DiahColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          PriceWidget(amount: b.totalPrice),
                          const Spacer(),
                          TextButton(
                            onPressed: () => ref
                                .read(storeNotifierProvider.notifier)
                                .updateBookingStatus(
                                  b.id,
                                  BookingStatus.rejected,
                                ),
                            child: Text(s.t('رفض', 'Refuser', 'Reject')),
                          ),
                          FilledButton(
                            onPressed: () => ref
                                .read(storeNotifierProvider.notifier)
                                .updateBookingStatus(
                                  b.id,
                                  BookingStatus.accepted,
                                ),
                            child: Text(s.t('قبول', 'Approuver', 'Approve')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/store/subscription'),
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: Text(s.subscription),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/store/profile'),
                  icon: const Icon(Icons.storefront_outlined),
                  label: Text(s.t('ملف المحل', 'Profil boutique', 'Store profile')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _businessLabel(StoreType t, AppStrings s) {
    switch (t) {
      case StoreType.wedding:
        return s.t('فساتين أعراس', 'Robes de mariée', 'Wedding Dresses');
      case StoreType.evening:
        return s.t('فساتين سهرات', 'Robes de soirée', 'Evening Dresses');
      case StoreType.traditional:
        return s.t('فساتين تقليدية', 'Traditionnel', 'Traditional Dresses');
      case StoreType.multi:
        return s.t('متعدد', 'Mixte', 'Mixed');
    }
  }
}
