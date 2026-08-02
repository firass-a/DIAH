import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/onboarding_providers.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/fake_backend/store_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';
import '../widgets/store_widgets.dart';
import 'store_shell.dart';

/// Account screen inside the store shell — never opens customer home tabs.
class StoreAccountScreen extends ConsumerWidget {
  const StoreAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(authProvider).user;
    final store = ref.watch(currentStoreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: StoreAppBar(
        title: s.t('حساب المحل', 'Compte boutique', 'Store account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StorePanel(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage!)
                      : null,
                  backgroundColor: DiahColors.softLavender,
                  child: user?.profileImage == null
                      ? Text(user?.fullName.isNotEmpty == true
                          ? user!.fullName[0]
                          : '?')
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? '',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        store?.name ?? '',
                        style: const TextStyle(color: DiahColors.primary),
                      ),
                      Text(
                        user?.phone ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: DiahColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (user != null && user.accountModes.length > 1)
            StorePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t(
                      'تبديل التجربة',
                      'Changer d’expérience',
                      'Switch experience',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (user.hasMode(AccountMode.customer))
                        ActionChip(
                          label: Text(s.roleCustomer),
                          onPressed: () async {
                            await ref
                                .read(profileNotifierProvider.notifier)
                                .switchActiveMode(AccountMode.customer);
                            if (context.mounted) context.go('/home');
                          },
                        ),
                      if (user.hasMode(AccountMode.individualOwner))
                        ActionChip(
                          label: Text(s.roleOwner),
                          onPressed: () async {
                            await ref
                                .read(profileNotifierProvider.notifier)
                                .switchActiveMode(AccountMode.individualOwner);
                            if (context.mounted) context.go('/owner');
                          },
                        ),
                      ActionChip(
                        label: Text(s.roleStore),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (user != null && user.accountModes.length > 1)
            const SizedBox(height: 12),
          StorePanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: DiahColors.primary),
                  title: Text(s.editProfile),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile/edit'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: DiahColors.primary),
                  title: Text(s.settings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: DiahColors.primary),
                  title: Text(s.notifications),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/notifications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SecondaryButton(
            label: s.logout,
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
