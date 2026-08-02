import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final notifs = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.notifications),
        actions: [
          if (notifs.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                final user = ref.read(authProvider).user;
                if (user != null) {
                  ref
                      .read(notificationRepositoryProvider)
                      .markAllAsRead(user.id);
                }
              },
              child: Text(s.t('قراءة الكل', 'Tout lu', 'Tout lu')),
            ),
        ],
      ),
      body: notifs.isEmpty
          ? EmptyState(message: s.emptyNotifications, icon: Icons.notifications_none)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final n = notifs[i];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    ref.read(notificationRepositoryProvider).delete(n.id);
                  },
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    decoration: BoxDecoration(
                      color: DiahColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete, color: DiahColors.error),
                  ),
                  child: LuxuryCard(
                    onTap: () {
                      ref.read(notificationRepositoryProvider).markAsRead(n.id);
                    },
                    color: n.isRead ? null : DiahColors.softLavender,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _icon(n.type),
                          color: DiahColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight:
                                      n.isRead ? FontWeight.w500 : FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: DiahColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                n.createdAt.toString().substring(0, 16),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: DiahColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: DiahColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.newBooking:
        return Icons.calendar_today_outlined;
      case NotificationType.bookingAccepted:
        return Icons.check_circle_outline;
      case NotificationType.bookingRejected:
        return Icons.cancel_outlined;
      case NotificationType.dressApproved:
        return Icons.checkroom_outlined;
      case NotificationType.dressRejected:
        return Icons.block;
      case NotificationType.dressReturned:
        return Icons.assignment_return_outlined;
      case NotificationType.paymentCompleted:
        return Icons.payments_outlined;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }
}
