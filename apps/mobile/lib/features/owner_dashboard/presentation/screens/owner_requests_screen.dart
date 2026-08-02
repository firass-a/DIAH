import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/fake_backend/fake_database.dart';
import '../../../../core/fake_backend/owner_providers.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../core/widgets/dress_image.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../../../shared/models/models.dart';
import '../widgets/owner_widgets.dart';
import 'owner_shell.dart';

class OwnerRequestsScreen extends ConsumerWidget {
  const OwnerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final bookings = ref.watch(ownerBookingNotifierProvider);

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      appBar: OwnerAppBar(title: s.rentalRequests),
      body: bookings.isEmpty
          ? EmptyState(
              message: s.emptyBookings,
              icon: Icons.inbox_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final b = bookings[i];
                final dress = ref.watch(dressByIdProvider(b.dressId));
                final customer =
                    FakeDatabase.instance.users.cast<AppUser?>().firstWhere(
                          (u) => u!.id == b.customerId,
                          orElse: () => null,
                        );

                return OwnerCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DressImage(
                            source: dress?.images.isNotEmpty == true
                                ? dress!.images.first
                                : '',
                            width: 64,
                            height: 72,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dress?.name ?? b.dressId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  customer?.fullName ??
                                      s.t('زبونة', 'Cliente', 'Customer'),
                                  style: const TextStyle(
                                    color: DiahColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_fmt(b.startDate)} → ${_fmt(b.endDate)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                s.formatPrice(b.totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: OwnerColors.accentSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              bookingStatusLabel(b.status, s),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: OwnerColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (b.status == BookingStatus.pending) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => ref
                                    .read(ownerBookingNotifierProvider.notifier)
                                    .reject(b.id),
                                child: Text(
                                  s.t('رفض', 'Refuser', 'Reject'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: OwnerColors.accent,
                                ),
                                onPressed: () => ref
                                    .read(ownerBookingNotifierProvider.notifier)
                                    .accept(b.id),
                                child: Text(
                                  s.t('قبول', 'Accepter', 'Accept'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (b.status == BookingStatus.accepted ||
                          b.status == BookingStatus.delivered) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => ref
                              .read(ownerBookingNotifierProvider.notifier)
                              .markReturned(b.id),
                          child: Text(
                            s.t('تم الإرجاع', 'Marquer retourné', 'Mark returned'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
