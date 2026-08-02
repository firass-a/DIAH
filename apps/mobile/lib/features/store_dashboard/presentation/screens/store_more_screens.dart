import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/fake_backend/store_providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';
import '../widgets/store_widgets.dart';
import 'store_shell.dart';

class StoreMoreScreen extends ConsumerWidget {
  const StoreMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    final items = [
      (
        Icons.payments_outlined,
        s.revenue,
        '/store/revenue',
      ),
      (
        Icons.insights_outlined,
        s.statistics,
        '/store/analytics',
      ),
      (
        Icons.workspace_premium_outlined,
        s.subscription,
        '/store/subscription',
      ),
      (
        Icons.storefront_outlined,
        s.t('ملف المحل', 'Profil boutique', 'Store profile'),
        '/store/profile',
      ),
      (
        Icons.person_outline,
        s.t('حساب المحل', 'Compte boutique', 'Store account'),
        '/store/account',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: StoreAppBar(
        title: s.t('المزيد', 'Plus', 'More'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          return StorePanel(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(item.$1, color: DiahColors.primary),
              title: Text(
                item.$2,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (item.$3 == '/store/account') {
                  context.go(item.$3);
                } else {
                  context.push(item.$3);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class StoreRevenueScreen extends ConsumerWidget {
  const StoreRevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final stats = ref.watch(storeStatsProvider);
    final txs = ref.watch(storeTransactionsProvider);
    final analytics = ref.watch(storeAnalyticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: AppBar(title: Text(s.revenue)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StoreStatCard(
                label: s.t('إجمالي الإيرادات', 'Revenu total', 'Total revenue'),
                value: s.formatPrice(stats.totalRevenue),
                icon: Icons.account_balance_wallet_outlined,
              ),
              StoreStatCard(
                label: s.t('إيراد الشهر', 'Ce mois', 'Monthly revenue'),
                value: s.formatPrice(stats.monthlyRevenue),
                icon: Icons.calendar_today_outlined,
                accent: const Color(0xFF5A8F7B),
              ),
              StoreStatCard(
                label: s.t('معاملات مكتملة', 'Transactions', 'Completed tx'),
                value: '${stats.completedTransactions}',
                icon: Icons.receipt_long_outlined,
              ),
              StoreStatCard(
                label: s.t('مدفوعات معلقة', 'En attente', 'Pending payments'),
                value: s.formatPrice(stats.pendingPayments),
                icon: Icons.hourglass_empty,
                accent: DiahColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          StoreSectionTitle(s.t('منحنى الإيرادات', 'Courbe', 'Revenue trend')),
          StorePanel(child: StoreBarChart(values: analytics.monthlyBars)),
          const SizedBox(height: 16),
          StoreSectionTitle(
            s.t('المعاملات', 'Transactions', 'Transactions'),
          ),
          if (txs.isEmpty)
            StorePanel(
              child: Text(
                s.t('لا معاملات بعد', 'Aucune', 'No transactions yet'),
                style: const TextStyle(color: DiahColors.textMuted),
              ),
            )
          else
            ...txs.take(20).map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StorePanel(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.description ?? t.type.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${t.date.toString().substring(0, 10)} · ${t.status.name}',
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StoreSubscriptionScreen extends ConsumerWidget {
  const StoreSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final store = ref.watch(currentStoreProvider);
    if (store == null) return const Scaffold(body: SizedBox.shrink());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: AppBar(title: Text(s.subscription)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StorePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: DiahColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      s.t('الاشتراك الحالي', 'Abonnement actuel', 'Current plan'),
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _row(s.t('الباقة', 'Offre', 'Plan'), store.subscriptionPlan.name),
                _row(
                  s.t('الحالة', 'Statut', 'Status'),
                  store.subscriptionStatus.name,
                ),
                _row(
                  s.t('تاريخ البدء', 'Début', 'Start date'),
                  store.subscriptionStartedAt?.toString().substring(0, 10) ?? '—',
                ),
                _row(
                  s.t('التجديد', 'Renouvellement', 'Renewal date'),
                  store.subscriptionExpiresAt?.toString().substring(0, 10) ?? '—',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StoreSectionTitle(
            s.t('باقات وهمية', 'Offres (mock)', 'Mock plans'),
          ),
          _PlanCard(
            title: s.t('شهري', 'Mensuel', 'Monthly'),
            price: '4 900 ${s.currency}',
            selected: store.subscriptionPlan == SubscriptionPlan.monthly,
            onTap: () => ref
                .read(storeNotifierProvider.notifier)
                .changeSubscription(SubscriptionPlan.monthly),
          ),
          const SizedBox(height: 10),
          _PlanCard(
            title: s.t('سنوي', 'Annuel', 'Yearly'),
            price: '49 000 ${s.currency}',
            selected: store.subscriptionPlan == SubscriptionPlan.yearly,
            badge: s.t('توفير', 'Économie', 'Save'),
            onTap: () => ref
                .read(storeNotifierProvider.notifier)
                .changeSubscription(SubscriptionPlan.yearly),
          ),
          const SizedBox(height: 12),
          Text(
            s.t(
              'الدفع وهمي في النموذج الأولي — لا بوابة حقيقية.',
              'Paiement fictif — prototype uniquement.',
              'Mock payment only — no real gateway in the prototype.',
            ),
            style: const TextStyle(color: DiahColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(k, style: const TextStyle(color: DiahColors.textSecondary))),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return StorePanel(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(price),
        trailing: selected
            ? const Icon(Icons.check_circle, color: DiahColors.success)
            : TextButton(onPressed: onTap, child: Text(badge ?? 'Select')),
      ),
    );
  }
}

class StoreProfileEditScreen extends ConsumerStatefulWidget {
  const StoreProfileEditScreen({super.key});

  @override
  ConsumerState<StoreProfileEditScreen> createState() =>
      _StoreProfileEditScreenState();
}

class _StoreProfileEditScreenState
    extends ConsumerState<StoreProfileEditScreen> {
  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _address;
  late TextEditingController _city;
  late TextEditingController _phone;
  late TextEditingController _hours;
  late TextEditingController _logo;
  late TextEditingController _cover;
  StoreType _type = StoreType.multi;
  bool _loading = false;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final store = ref.read(currentStoreProvider);
    if (store == null) return;
    _name = TextEditingController(text: store.name);
    _desc = TextEditingController(text: store.description);
    _address = TextEditingController(text: store.address);
    _city = TextEditingController(text: store.city);
    _phone = TextEditingController(text: store.phone ?? '');
    _hours = TextEditingController(text: store.openingHours);
    _logo = TextEditingController(text: store.logo ?? store.imageUrl ?? '');
    _cover = TextEditingController(text: store.coverImage ?? '');
    _type = store.type;
    _ready = true;
  }

  @override
  void dispose() {
    if (_ready) {
      _name.dispose();
      _desc.dispose();
      _address.dispose();
      _city.dispose();
      _phone.dispose();
      _hours.dispose();
      _logo.dispose();
      _cover.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final store = ref.read(currentStoreProvider);
    if (store == null) return;
    setState(() => _loading = true);
    await ref.read(storeNotifierProvider.notifier).updateStore(
      store.copyWith(
        name: _name.text.trim(),
        description: _desc.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        phone: _phone.text.trim(),
        openingHours: _hours.text.trim(),
        logo: _logo.text.trim(),
        coverImage: _cover.text.trim(),
        imageUrl: _logo.text.trim(),
        type: _type,
      ),
    );
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(stringsProvider).save)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final store = ref.watch(currentStoreProvider);
    if (store == null || !_ready) {
      return const Scaffold(body: LoadingState());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: AppBar(
        title: Text(s.t('ملف المحل', 'Profil boutique', 'Store profile')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: _cover.text,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  Container(height: 140, color: DiahColors.softLavender),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cover,
            decoration: InputDecoration(
              labelText: s.t('صورة الغلاف', 'Couverture', 'Cover image URL'),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _logo,
            decoration: InputDecoration(
              labelText: s.t('الشعار', 'Logo', 'Logo URL'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: s.t('اسم المحل', 'Nom', 'Store name'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: InputDecoration(labelText: s.description),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: InputDecoration(
              labelText: s.t('العنوان', 'Adresse', 'Address'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _city,
            decoration: InputDecoration(
              labelText: s.t('المدينة', 'Ville', 'City'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            decoration: InputDecoration(labelText: s.phone),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hours,
            decoration: InputDecoration(
              labelText: s.t('ساعات العمل', 'Horaires', 'Opening hours'),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<StoreType>(
            initialValue: _type,
            decoration: InputDecoration(
              labelText: s.t('نوع النشاط', "Type d'activité", 'Business type'),
            ),
            items: StoreType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(_typeLabel(t, s)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: s.save, isLoading: _loading, onPressed: _save),
        ],
      ),
    );
  }

  String _typeLabel(StoreType t, AppStrings s) {
    switch (t) {
      case StoreType.wedding:
        return s.t('فساتين أعراس', 'Mariage', 'Wedding Dresses');
      case StoreType.evening:
        return s.t('فساتين سهرات', 'Soirée', 'Evening Dresses');
      case StoreType.traditional:
        return s.t('تقليدية', 'Traditionnel', 'Traditional Dresses');
      case StoreType.multi:
        return s.t('متعدد', 'Mixte', 'Mixed');
    }
  }
}

class StoreAnalyticsScreen extends ConsumerWidget {
  const StoreAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final a = ref.watch(storeAnalyticsProvider);
    final stats = ref.watch(storeStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0F5),
      appBar: AppBar(title: Text(s.statistics)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (a.mostRented != null)
            StorePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.t('الأكثر إيجاراً', 'Plus louée', 'Most rented dress'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a.mostRented!.name,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('${a.mostRented!.rentalCount} ${s.t("إيجار", "locations", "rentals")}'),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StoreStatCard(
                  label: s.t('إجمالي الإيجارات', 'Locations', 'Total rentals'),
                  value: '${a.totalRentals}',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StoreStatCard(
                  label: s.t('متوسط التقييم', 'Note', 'Avg rating'),
                  value: stats.averageRating.toStringAsFixed(1),
                  icon: Icons.star_outline,
                  accent: const Color(0xFFD4A017),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StoreSectionTitle(s.t('الإيرادات (6 أشهر)', '6 mois', 'Revenue (6 mo)')),
          StorePanel(child: StoreBarChart(values: a.monthlyBars)),
          const SizedBox(height: 16),
          StoreSectionTitle(
            s.t('التصنيفات الشائعة', 'Catégories', 'Popular categories'),
          ),
          if (a.categoryCounts.isEmpty)
            StorePanel(
              child: Text(
                s.t('لا بيانات بعد', 'Pas de données', 'No data yet'),
                style: const TextStyle(color: DiahColors.textMuted),
              ),
            )
          else
            ...a.categoryCounts.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StorePanel(
                  child: Row(
                    children: [
                      Expanded(child: Text(s.categoryLabel(e.key))),
                      Text(
                        '${e.value}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
