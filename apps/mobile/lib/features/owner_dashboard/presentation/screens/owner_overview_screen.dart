import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/owner_providers.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';
import '../widgets/owner_widgets.dart';
import 'owner_shell.dart';

class OwnerOverviewScreen extends ConsumerWidget {
  const OwnerOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final stats = ref.watch(ownerStatisticsProvider);
    final user = ref.watch(authProvider).user;
    final bookings = ref.watch(individualOwnerBookingsProvider);
    final pending =
        bookings.where((b) => b.status == BookingStatus.pending).take(3);

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      appBar: OwnerAppBar(
        title: s.t('خزانتي', 'Ma garde-robe', 'My wardrobe'),
        showMarketplace: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            s.t(
              'مرحباً ${user?.fullName.split(' ').first ?? ''}',
              'Bonjour ${user?.fullName.split(' ').first ?? ''}',
              'Hello ${user?.fullName.split(' ').first ?? ''}',
            ),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.t(
              'أجّري فساتينك واكسبي دخلاً إضافياً',
              'Louez vos robes et gagnez un revenu',
              'Rent your dresses and earn extra income',
            ),
            style: const TextStyle(color: DiahColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 24),
          OwnerSectionTitle(s.statistics),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              OwnerStatCard(
                label: s.myDresses,
                value: '${stats.dressCount}',
                icon: Icons.checkroom_outlined,
                onTap: () => context.go('/owner/dresses'),
              ),
              OwnerStatCard(
                label: s.t('إيجارات نشطة', 'Locations actives', 'Active rentals'),
                value: '${stats.activeRentals}',
                icon: Icons.timelapse,
                onTap: () => context.push('/owner/history'),
              ),
              OwnerStatCard(
                label: s.t('طلبات معلّقة', 'Demandes', 'Pending requests'),
                value: '${stats.pendingRequests}',
                icon: Icons.mail_outline,
                onTap: () => context.go('/owner/requests'),
              ),
              OwnerStatCard(
                label: s.t('مكتملة', 'Terminées', 'Completed'),
                value: '${stats.completedRentals}',
                icon: Icons.verified_outlined,
                onTap: () => context.push('/owner/history'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OwnerCard(
            onTap: () => context.go('/owner/earnings'),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: OwnerColors.accentSoft,
                  child: const Icon(
                    Icons.payments_outlined,
                    color: OwnerColors.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.t('إجمالي الأرباح', 'Gains totaux', 'Total earnings'),
                        style: const TextStyle(
                          color: DiahColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          s.formatPrice(stats.totalEarnings),
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: DiahColors.textMuted),
              ],
            ),
          ),
          if (stats.pendingReviewCount > 0) ...[
            const SizedBox(height: 12),
            OwnerCard(
              onTap: () => context.go('/owner/dresses'),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top, color: DiahColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.t(
                        '${stats.pendingReviewCount} فستان بانتظار مراجعة المنصة',
                        '${stats.pendingReviewCount} robe(s) en attente de validation',
                        '${stats.pendingReviewCount} dress(es) awaiting platform review',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          OwnerSectionTitle(
            s.rentalRequests,
            action: TextButton(
              onPressed: () => context.go('/owner/requests'),
              child: Text(s.t('الكل', 'Tout', 'All')),
            ),
          ),
          if (pending.isEmpty)
            OwnerCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 40,
                      color: OwnerColors.accent.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.t(
                        'لا توجد طلبات جديدة بعد',
                        'Aucune demande pour le moment',
                        'No new requests yet',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: DiahColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            ...pending.map((b) {
              final dress = ref.watch(dressByIdProvider(b.dressId));
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OwnerCard(
                  onTap: () => context.go('/owner/requests'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dress?.name ?? b.dressId,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_fmt(b.startDate)} → ${_fmt(b.endDate)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: DiahColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        bookingStatusLabel(b.status, s),
                        style: const TextStyle(
                          fontSize: 12,
                          color: OwnerColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
          PrimaryButton(
            label: s.addDress,
            onPressed: () => context.push('/owner/add-dress'),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
