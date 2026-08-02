import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/fake_database.dart';
import '../../../../core/fake_backend/owner_providers.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../../../shared/models/models.dart';
import '../widgets/owner_widgets.dart';
import 'owner_shell.dart';

class OwnerEarningsScreen extends ConsumerWidget {
  const OwnerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final stats = ref.watch(ownerStatisticsProvider);
    final txs = ref.watch(individualOwnerTransactionsProvider);
    final bookings = ref.watch(individualOwnerBookingsProvider);

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      appBar: OwnerAppBar(
        title: s.t('أرباحي', 'Mes gains', 'My earnings'),
        actions: [
          TextButton(
            onPressed: () => context.push('/owner/history'),
            child: Text(s.t('السجل', 'Historique', 'History')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          OwnerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.t('إجمالي الأرباح', 'Gains totaux', 'Total earnings'),
                  style: const TextStyle(color: DiahColors.textMuted),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    s.formatPrice(stats.totalEarnings),
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OwnerStatCard(
                  label: s.t('مكتملة', 'Terminées', 'Completed rentals'),
                  value: '${stats.completedRentals}',
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OwnerStatCard(
                  label: s.t('أرباح معلّقة', 'Gains en attente', 'Pending earnings'),
                  value: s.formatPrice(stats.pendingEarnings),
                  icon: Icons.hourglass_empty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          OwnerSectionTitle(
            s.t('سجل الإيجارات', 'Historique locations', 'Rental history'),
          ),
          if (bookings.isEmpty)
            OwnerCard(
              child: Text(
                s.emptyBookings,
                style: const TextStyle(color: DiahColors.textMuted),
              ),
            )
          else
            ...bookings.take(12).map((b) {
              final dress = ref.watch(dressByIdProvider(b.dressId));
              final customer =
                  FakeDatabase.instance.users.cast<AppUser?>().firstWhere(
                        (u) => u!.id == b.customerId,
                        orElse: () => null,
                      );
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OwnerCard(
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
                              customer?.fullName ?? '—',
                              style: const TextStyle(
                                fontSize: 13,
                                color: DiahColors.textMuted,
                              ),
                            ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              s.formatPrice(b.totalPrice),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bookingStatusLabel(b.status, s),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (txs.isNotEmpty) ...[
            const SizedBox(height: 20),
            OwnerSectionTitle(
              s.t('المعاملات', 'Transactions', 'Transactions'),
            ),
            ...txs.take(8).map((t) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OwnerCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.description ?? t.type.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          s.formatPrice(t.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: t.status == TransactionStatus.completed
                                ? DiahColors.success
                                : DiahColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class OwnerHistoryScreen extends ConsumerWidget {
  const OwnerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final bookings = ref.watch(individualOwnerBookingsProvider);
    final now = DateTime.now();

    final current = bookings
        .where(
          (b) =>
              (b.status == BookingStatus.accepted ||
                  b.status == BookingStatus.preparing ||
                  b.status == BookingStatus.delivered) &&
              !b.endDate.isBefore(DateTime(now.year, now.month, now.day)),
        )
        .toList();
    final upcoming = bookings
        .where(
          (b) =>
              b.status == BookingStatus.accepted &&
              b.startDate.isAfter(now),
        )
        .toList();
    final past = bookings
        .where(
          (b) =>
              b.status == BookingStatus.returned ||
              b.status == BookingStatus.completed ||
              b.status == BookingStatus.cancelled ||
              b.status == BookingStatus.rejected ||
              b.endDate.isBefore(DateTime(now.year, now.month, now.day)),
        )
        .toList();

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      appBar: AppBar(
        backgroundColor: OwnerColors.canvas,
        title: Text(
          s.t('سجل الإيجار', 'Historique', 'Rental history'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _section(s.t('الحالية', 'En cours', 'Current'), current, ref, s),
          _section(s.t('القادمة', 'À venir', 'Upcoming'), upcoming, ref, s),
          _section(s.t('السابقة', 'Passées', 'Past'), past, ref, s),
        ],
      ),
    );
  }

  Widget _section(
    String title,
    List<Booking> bookings,
    WidgetRef ref,
    AppStrings s,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OwnerSectionTitle(title),
        if (bookings.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              s.t('لا شيء هنا', 'Rien ici', 'Nothing here'),
              style: const TextStyle(color: DiahColors.textMuted),
            ),
          )
        else
          ...bookings.map((b) {
            final dress = ref.watch(dressByIdProvider(b.dressId));
            final customer =
                FakeDatabase.instance.users.cast<AppUser?>().firstWhere(
                      (u) => u!.id == b.customerId,
                      orElse: () => null,
                    );
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OwnerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dress?.name ?? b.dressId,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(customer?.fullName ?? '—'),
                    Text(
                      '${_fmt(b.startDate)} → ${_fmt(b.endDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DiahColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            s.formatPrice(b.totalPrice),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Spacer(),
                        Text(bookingStatusLabel(b.status, s)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
