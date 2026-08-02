import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/fake_backend/providers.dart';
import '../../../../core/fake_backend/store_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../../../shared/models/models.dart';
import '../widgets/store_widgets.dart';
import 'store_shell.dart';

class StoreBookingsScreen extends ConsumerWidget {
  const StoreBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final bookings = ref.watch(storeBookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: StoreAppBar(
        title: s.t('إدارة الحجوزات', 'Réservations', 'Booking management'),
      ),
      body: bookings.isEmpty
          ? EmptyState(message: s.emptyBookings)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final b = bookings[i];
                final dress = ref.watch(dressByIdProvider(b.dressId));
                return StorePanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dress?.name ?? b.dressId,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: DiahColors.softLavender,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _storeStatusLabel(b.status, s),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${b.startDate.toString().substring(0, 10)} → ${b.endDate.toString().substring(0, 10)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DiahColors.textMuted,
                        ),
                      ),
                      Text(
                        '${s.size}: ${b.size ?? "—"} · ${s.formatPrice(b.totalPrice)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _actions(b, ref, s),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  List<Widget> _actions(Booking b, WidgetRef ref, AppStrings s) {
    final n = ref.read(storeNotifierProvider.notifier);
    Widget btn(String label, BookingStatus st, {bool filled = false}) {
      if (filled) {
        return FilledButton(
          onPressed: () => n.updateBookingStatus(b.id, st),
          child: Text(label),
        );
      }
      return OutlinedButton(
        onPressed: () => n.updateBookingStatus(b.id, st),
        child: Text(label),
      );
    }

    switch (b.status) {
      case BookingStatus.pending:
        return [
          btn(s.t('رفض', 'Refuser', 'Reject'), BookingStatus.rejected),
          btn(
            s.t('موافقة', 'Approuver', 'Approve'),
            BookingStatus.accepted,
            filled: true,
          ),
        ];
      case BookingStatus.accepted:
        return [
          btn(
            s.t('تجهيز', 'Préparer', 'Preparing'),
            BookingStatus.preparing,
            filled: true,
          ),
          btn(s.t('إلغاء', 'Annuler', 'Cancel'), BookingStatus.cancelled),
        ];
      case BookingStatus.preparing:
        return [
          btn(
            s.t('تسليم', 'Livrer', 'Delivered'),
            BookingStatus.delivered,
            filled: true,
          ),
        ];
      case BookingStatus.delivered:
        return [
          btn(
            s.t('إرجاع', 'Retour', 'Returned'),
            BookingStatus.returned,
            filled: true,
          ),
        ];
      default:
        return [];
    }
  }

  String _storeStatusLabel(BookingStatus st, AppStrings s) {
    switch (st) {
      case BookingStatus.pending:
        return s.t('معلق', 'En attente', 'Pending');
      case BookingStatus.accepted:
        return s.t('موافق عليه', 'Approuvé', 'Approved');
      case BookingStatus.rejected:
        return s.t('مرفوض', 'Refusé', 'Rejected');
      case BookingStatus.preparing:
        return s.t('قيد التجهيز', 'Préparation', 'Preparing');
      case BookingStatus.delivered:
        return s.t('تم التسليم', 'Livré', 'Delivered');
      case BookingStatus.returned:
        return s.t('تم الإرجاع', 'Retourné', 'Returned');
      case BookingStatus.cancelled:
        return s.t('ملغى', 'Annulé', 'Cancelled');
      case BookingStatus.completed:
        return s.t('مكتمل', 'Terminé', 'Completed');
    }
  }
}

class StoreCalendarScreen extends ConsumerStatefulWidget {
  const StoreCalendarScreen({super.key});

  @override
  ConsumerState<StoreCalendarScreen> createState() =>
      _StoreCalendarScreenState();
}

class _StoreCalendarScreenState extends ConsumerState<StoreCalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final bookings = ref.watch(storeBookingsProvider);
    final dresses = ref.watch(storeDressesProvider);

    final events = <DateTime, List<Booking>>{};
    for (final b in bookings) {
      if (b.status == BookingStatus.rejected ||
          b.status == BookingStatus.cancelled) {
        continue;
      }
      var cursor = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      while (!cursor.isAfter(end)) {
        final key = DateTime(cursor.year, cursor.month, cursor.day);
        events.putIfAbsent(key, () => []).add(b);
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    final selectedKey = _selected == null
        ? null
        : DateTime(_selected!.year, _selected!.month, _selected!.day);
    final dayBookings = selectedKey == null
        ? <Booking>[]
        : (events[selectedKey] ?? []);

    final returnsSoon = bookings
        .where(
          (b) =>
              b.status == BookingStatus.delivered ||
              b.status == BookingStatus.accepted ||
              b.status == BookingStatus.preparing,
        )
        .where(
          (b) => b.endDate.isAfter(DateTime.now().subtract(const Duration(days: 1))),
        )
        .take(5)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: StoreAppBar(title: s.calendar),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          StorePanel(
            child: TableCalendar<Booking>(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 120)),
              focusedDay: _focused,
              selectedDayPredicate: (d) =>
                  _selected != null && isSameDay(_selected, d),
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return events[key] ?? [];
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                markerDecoration: const BoxDecoration(
                  color: DiahColors.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: DiahColors.accent.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: DiahColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selected = selected;
                  _focused = focused;
                });
              },
              onPageChanged: (f) => _focused = f,
            ),
          ),
          const SizedBox(height: 16),
          StoreSectionTitle(
            s.t('حجوزات اليوم المحدد', 'Réservations du jour', 'Selected day'),
          ),
          if (dayBookings.isEmpty)
            StorePanel(
              child: Text(
                s.t('لا حجوزات في هذا اليوم', 'Aucune', 'No rentals this day'),
                style: const TextStyle(color: DiahColors.textMuted),
              ),
            )
          else
            ...dayBookings.map((b) {
              final dress = dresses.cast<Dress?>().firstWhere(
                (d) => d!.id == b.dressId,
                orElse: () => null,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StorePanel(
                  child: Text(
                    '${dress?.name ?? b.dressId} · ${bookingStatusLabel(b.status, s)}',
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),
          StoreSectionTitle(
            s.t('مواعيد الإرجاع القادمة', 'Retours à venir', 'Upcoming returns'),
          ),
          ...returnsSoon.map((b) {
            final dress = dresses.cast<Dress?>().firstWhere(
              (d) => d!.id == b.dressId,
              orElse: () => null,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StorePanel(
                child: Row(
                  children: [
                    const Icon(Icons.assignment_return_outlined,
                        color: DiahColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${dress?.name ?? ""} — ${b.endDate.toString().substring(0, 10)}',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          StoreSectionTitle(
            s.t('فساتين غير متاحة قريباً', 'Indisponibles', 'Unavailable soon'),
          ),
          ...dresses.where((d) => d.unavailableDates.isNotEmpty).take(5).map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StorePanel(
                child: Text(
                  '${d.name} · ${d.unavailableDates.length} ${s.t("يوم محجوز", "jours bloqués", "blocked days")}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
