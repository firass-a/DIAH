import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/onboarding_providers.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../../../shared/models/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Color _roleAccent(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return DiahColors.accent;
      case UserRole.customer:
        return const Color(0xFF887893);
      case UserRole.individualOwner:
        return const Color(0xFF9B6B8A);
      case UserRole.storeOwner:
        return const Color(0xFF6B5B7A);
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return Icons.person_outline;
      case UserRole.customer:
        return Icons.shopping_bag_outlined;
      case UserRole.individualOwner:
        return Icons.checkroom_outlined;
      case UserRole.storeOwner:
        return Icons.storefront_outlined;
    }
  }

  String _roleLabel(UserRole role, AppStrings s) {
    switch (role) {
      case UserRole.guest:
        return s.roleGuest;
      case UserRole.customer:
        return s.roleCustomer;
      case UserRole.individualOwner:
        return s.roleOwner;
      case UserRole.storeOwner:
        return s.roleStore;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        body: EmptyState(
          message: s.loginRequired,
          actionLabel: s.login,
          onAction: () => context.push('/login'),
        ),
      );
    }

    final accent = _roleAccent(user.role);
    final bookings = ref.watch(customerBookingsProvider);
    final favorites = ref.watch(favoriteDressesProvider);
    final stats = ref.watch(ownerStatsProvider);
    final store = user.storeId != null
        ? ref.watch(storeByIdProvider(user.storeId!))
        : null;
    final city = user.addresses.isNotEmpty ? user.addresses.first.city : '—';
    final memberYear = user.createdAt?.year.toString() ?? '2026';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.95),
                    accent.withValues(alpha: 0.65),
                    DiahColors.background,
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: DiahColors.softLavender,
                          backgroundImage: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child: user.profileImage == null
                              ? Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0]
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user.fullName,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: DiahColors.text,
                        ),
                      ),
                      if (!auth.isGuest) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.phone,
                          style: const TextStyle(color: DiahColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          city,
                          style: const TextStyle(
                            fontSize: 13,
                            color: DiahColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_roleIcon(user.role), size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              _roleLabel(user.role, s),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (store != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          store.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ],
                      if (!auth.isGuest) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${s.memberSince} $memberYear',
                          style: const TextStyle(
                            fontSize: 12,
                            color: DiahColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!auth.isGuest)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: LuxuryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.quickStats,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      if (user.role == UserRole.customer)
                        Row(
                          children: [
                            _MiniStat(
                              label: s.myBookings,
                              value: '${bookings.length}',
                              color: accent,
                            ),
                            _MiniStat(
                              label: s.favorites,
                              value: '${favorites.length}',
                              color: accent,
                            ),
                            _MiniStat(
                              label: s.addresses,
                              value: '${user.addresses.length}',
                              color: accent,
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            _MiniStat(
                              label: s.myDresses,
                              value: '${stats.totalDresses}',
                              color: accent,
                            ),
                            _MiniStat(
                              label: s.revenue,
                              value: s.formatPrice(stats.revenue),
                              color: accent,
                              compact: true,
                            ),
                            _MiniStat(
                              label: s.rentalRequests,
                              value: '${stats.pendingRequests}',
                              color: accent,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),
                if (!auth.isGuest) ...[
                  _ModeSwitcher(user: user),
                  if (!user.hasMode(AccountMode.individualOwner))
                    _MenuTile(
                      icon: Icons.checkroom_outlined,
                      title: s.becomeOwner,
                      highlight: true,
                      onTap: () {
                        ref
                            .read(onboardingProvider.notifier)
                            .selectMode(AccountMode.individualOwner);
                        context.go('/onboarding/owner');
                      },
                    ),
                  if (!user.hasMode(AccountMode.storeOwner))
                    _MenuTile(
                      icon: Icons.storefront_outlined,
                      title: s.t(
                        'أريد إنشاء محل كراء',
                        'Créer ma boutique de location',
                        'I want to create my rental store',
                      ),
                      highlight: true,
                      onTap: () {
                        ref
                            .read(onboardingProvider.notifier)
                            .selectMode(AccountMode.storeOwner);
                        context.go('/onboarding/store');
                      },
                    ),
                  _MenuTile(
                    icon: Icons.edit_outlined,
                    title: s.editProfile,
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _MenuTile(
                    icon: Icons.calendar_today_outlined,
                    title: s.myBookings,
                    onTap: () => context.push('/profile/bookings'),
                  ),
                  _MenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: s.myTransactions,
                    onTap: () => context.push('/profile/transactions'),
                  ),
                  _MenuTile(
                    icon: Icons.location_on_outlined,
                    title: s.addresses,
                    onTap: () => context.push('/profile/addresses'),
                  ),
                  _MenuTile(
                    icon: Icons.favorite_outline,
                    title: s.favorites,
                    onTap: () => context.go('/favorites'),
                  ),
                  _MenuTile(
                    icon: Icons.notifications_outlined,
                    title: s.notifications,
                    onTap: () => context.push('/notifications'),
                  ),
                ],
                _MenuTile(
                  icon: Icons.settings_outlined,
                  title: s.settings,
                  onTap: () => context.push('/settings'),
                ),
                _MenuTile(
                  icon: Icons.logout,
                  title: s.logout,
                  danger: true,
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: compact ? 12 : 18,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: DiahColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends ConsumerWidget {
  const _ModeSwitcher({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    if (user.accountModes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LuxuryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.t(
                'تجربتي على دياه',
                'Mes expériences Diah',
                'My Diah experiences',
              ),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              s.t(
                'بدّلي بين أوضاع حسابك في أي وقت',
                'Changez de mode à tout moment',
                'Switch between your account modes anytime',
              ),
              style: const TextStyle(
                fontSize: 12,
                color: DiahColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (user.hasMode(AccountMode.customer))
                  _ModeChip(
                    label: s.roleCustomer,
                    selected: user.role == UserRole.customer,
                    onTap: () async {
                      await ref
                          .read(profileNotifierProvider.notifier)
                          .switchActiveMode(AccountMode.customer);
                      if (context.mounted) context.go('/home');
                    },
                  ),
                if (user.hasMode(AccountMode.individualOwner))
                  _ModeChip(
                    label: s.roleOwner,
                    selected: user.role == UserRole.individualOwner,
                    onTap: () async {
                      await ref
                          .read(profileNotifierProvider.notifier)
                          .switchActiveMode(AccountMode.individualOwner);
                      if (context.mounted) context.go('/owner');
                    },
                  ),
                if (user.hasMode(AccountMode.storeOwner))
                  _ModeChip(
                    label: s.roleStore,
                    selected: user.role == UserRole.storeOwner,
                    onTap: () async {
                      await ref
                          .read(profileNotifierProvider.notifier)
                          .switchActiveMode(AccountMode.storeOwner);
                      if (context.mounted) context.go('/store');
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: DiahColors.softLavender,
      checkmarkColor: DiahColors.primary,
      side: BorderSide(
        color: selected ? DiahColors.primary : DiahColors.border,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.highlight = false,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool highlight;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LuxuryCard(
        onTap: onTap,
        color: highlight ? DiahColors.softLavender : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: danger
                  ? DiahColors.error
                  : highlight
                      ? DiahColors.primary
                      : DiahColors.accent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: danger ? DiahColors.error : DiahColors.text,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: DiahColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user!;
    _name = TextEditingController(text: user.fullName);
    _phone = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(s.editProfile)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: s.fullName),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phone,
              decoration: InputDecoration(labelText: s.phone),
            ),
            const SizedBox(height: 8),
            Text(
              s.t(
                'يُحدَّث الاسم الأول واللقب تلقائياً',
                'Prénom et nom mis à jour automatiquement',
                'First and last name update automatically',
              ),
              style: const TextStyle(fontSize: 12, color: DiahColors.textMuted),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: s.save,
              isLoading: _loading,
              onPressed: () async {
                setState(() => _loading = true);
                final user = ref.read(authProvider).user!;
                final parts = _name.text.trim().split(RegExp(r'\s+'));
                final first = parts.isNotEmpty ? parts.first : '';
                final last =
                    parts.length > 1 ? parts.sublist(1).join(' ') : '';
                await ref.read(authProvider.notifier).updateProfile(
                  user.copyWith(
                    firstName: first,
                    lastName: last,
                    fullName: _name.text.trim(),
                    phone: _phone.text.trim(),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BookingsListScreen extends ConsumerWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final bookings = ref.watch(customerBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.myBookings)),
      body: bookings.isEmpty
          ? EmptyState(message: s.emptyBookings)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final b = bookings[i];
                final dress = ref.watch(dressByIdProvider(b.dressId));
                return LuxuryCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dress?.name ?? b.dressId,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${b.startDate.toString().substring(0, 10)} → ${b.endDate.toString().substring(0, 10)}',
                        style: const TextStyle(
                          color: DiahColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
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
                              bookingStatusLabel(b.status, s),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const Spacer(),
                          PriceWidget(amount: b.totalPrice),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final txs = ref.watch(userTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.myTransactions)),
      body: txs.isEmpty
          ? EmptyState(message: s.t('لا توجد معاملات', 'Aucune transaction', 'Aucune transaction'))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: txs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final t = txs[i];
                return LuxuryCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: DiahColors.softLavender,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          t.type == TransactionType.deposit
                              ? Icons.lock_outline
                              : t.type == TransactionType.refund
                                  ? Icons.undo
                                  : Icons.payments_outlined,
                          color: DiahColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.description ?? t.type.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              t.date.toString().substring(0, 16),
                              style: const TextStyle(
                                fontSize: 12,
                                color: DiahColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PriceWidget(amount: t.amount),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final user = ref.watch(authProvider).user;
    final addresses = user?.addresses ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(s.addresses)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAddress(context, ref),
        child: const Icon(Icons.add),
      ),
      body: addresses.isEmpty
          ? EmptyState(
              message: s.t('لا توجد عناوين', 'Aucune adresse', 'Aucune adresse'),
              actionLabel: s.t('إضافة عنوان', 'Ajouter', 'Ajouter'),
              onAction: () => _addAddress(context, ref),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = addresses[i];
                return LuxuryCard(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: DiahColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.label,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('${a.street}, ${a.city}'),
                            Text(a.phone, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      if (a.isDefault)
                        const Icon(Icons.check_circle, color: DiahColors.success, size: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addAddress(BuildContext context, WidgetRef ref) async {
    final label = TextEditingController(text: 'المنزل');
    final street = TextEditingController();
    final city = TextEditingController(text: 'الجزائر العاصمة');
    final phone = TextEditingController(text: ref.read(authProvider).user?.phone);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('عنوان جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: label, decoration: const InputDecoration(labelText: 'التسمية')),
            TextField(controller: street, decoration: const InputDecoration(labelText: 'الشارع')),
            TextField(controller: city, decoration: const InputDecoration(labelText: 'المدينة')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'الهاتف')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حفظ')),
        ],
      ),
    );

    if (ok == true) {
      final user = ref.read(authProvider).user!;
      final addr = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: label.text,
        street: street.text,
        city: city.text,
        phone: phone.text,
        isDefault: user.addresses.isEmpty,
      );
      await ref.read(authProvider.notifier).updateProfile(
        user.copyWith(addresses: [...user.addresses, addr]),
      );
    }
  }
}

class BecomeOwnerScreen extends ConsumerWidget {
  const BecomeOwnerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Legacy route — funnel into the new multi-role onboarding.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).selectMode(AccountMode.individualOwner);
      context.go('/onboarding/role');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

