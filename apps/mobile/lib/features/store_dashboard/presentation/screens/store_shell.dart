import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/store_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';

class StoreShell extends ConsumerWidget {
  const StoreShell({super.key, required this.child});

  final Widget child;

  int _index(String loc) {
    if (loc.startsWith('/store/inventory')) return 1;
    if (loc.startsWith('/store/bookings')) return 2;
    if (loc.startsWith('/store/calendar')) return 3;
    if (loc.startsWith('/store/more')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final store = ref.watch(currentStoreProvider);
    final loc = GoRouterState.of(context).uri.toString();
    final index = _index(loc);

    if (store == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront, size: 48, color: DiahColors.accent),
                const SizedBox(height: 16),
                Text(
                  s.t(
                    'لا يوجد محل مرتبط بحسابك',
                    'Aucune boutique liée',
                    'No store linked to your account',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/create-store'),
                  child: Text(
                    s.t(
                      'أنشئ محلك',
                      'Créer ma boutique',
                      'Create my store',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: DiahColors.card,
        indicatorColor: DiahColors.softLavender,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/store');
            case 1:
              context.go('/store/inventory');
            case 2:
              context.go('/store/bookings');
            case 3:
              context.go('/store/calendar');
            case 4:
              context.go('/store/more');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: s.t('نظرة عامة', 'Aperçu', 'Overview'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: s.inventory,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: ref.watch(storeStatsProvider).pendingBookings > 0,
              label: Text('${ref.watch(storeStatsProvider).pendingBookings}'),
              child: const Icon(Icons.event_note_outlined),
            ),
            selectedIcon: const Icon(Icons.event_note),
            label: s.t('حجوزات', 'Réservations', 'Bookings'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: s.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon: const Icon(Icons.more_horiz),
            label: s.t('المزيد', 'Plus', 'More'),
          ),
        ],
      ),
    );
  }
}

class StoreAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const StoreAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showAccount = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showAccount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(currentStoreProvider);
    return AppBar(
      backgroundColor: const Color(0xFFF3F0F5),
      title: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: DiahColors.text,
            ),
          ),
          if (store != null)
            Text(
              store.storeName,
              style: const TextStyle(
                fontSize: 11,
                color: DiahColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      leading: showAccount
          ? IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.go('/store/account'),
            )
          : null,
      actions: actions,
    );
  }
}
