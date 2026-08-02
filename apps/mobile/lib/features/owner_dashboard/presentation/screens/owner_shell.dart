import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/owner_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../widgets/owner_widgets.dart';

class OwnerShell extends ConsumerWidget {
  const OwnerShell({super.key, required this.child});

  final Widget child;

  int _index(String loc) {
    if (loc.startsWith('/owner/dresses')) return 1;
    if (loc.startsWith('/owner/requests')) return 2;
    if (loc.startsWith('/owner/earnings')) return 3;
    if (loc.startsWith('/owner/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final stats = ref.watch(ownerStatisticsProvider);
    final loc = GoRouterState.of(context).uri.toString();
    final index = _index(loc);

    return Scaffold(
      backgroundColor: OwnerColors.canvas,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        backgroundColor: DiahColors.card,
        indicatorColor: OwnerColors.accentSoft,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/owner');
            case 1:
              context.go('/owner/dresses');
            case 2:
              context.go('/owner/requests');
            case 3:
              context.go('/owner/earnings');
            case 4:
              context.go('/owner/profile');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: s.t('نظرة', 'Aperçu', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.checkroom_outlined),
            selectedIcon: const Icon(Icons.checkroom),
            label: s.myDresses,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: stats.pendingRequests > 0,
              label: Text('${stats.pendingRequests}'),
              child: const Icon(Icons.mail_outline),
            ),
            selectedIcon: const Icon(Icons.mail),
            label: s.t('طلبات', 'Demandes', 'Requests'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments),
            label: s.t('أرباح', 'Gains', 'Earnings'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: s.profile,
          ),
        ],
      ),
    );
  }
}

class OwnerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OwnerAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showMarketplace = false,
  });

  final String title;
  final List<Widget>? actions;
  final bool showMarketplace;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: OwnerColors.canvas,
      title: Text(
        title,
        style: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: DiahColors.text,
        ),
      ),
      leading: showMarketplace
          ? IconButton(
              tooltip: 'Marketplace',
              icon: const Icon(Icons.storefront_outlined),
              onPressed: () => context.go('/home'),
            )
          : null,
      actions: actions,
    );
  }
}
