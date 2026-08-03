import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/fake_backend/fake_database.dart';
import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../core/widgets/dress_image.dart';
import '../../../../shared/models/models.dart';

class DressDetailScreen extends ConsumerWidget {
  const DressDetailScreen({
    super.key,
    required this.dressId,
    this.heroTag,
  });

  final String dressId;
  /// Must match the tapped [DressCard] tag to avoid duplicate Hero conflicts.
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final dress = ref.watch(dressByIdProvider(dressId));
    final isFav = ref.watch(isFavoriteProvider(dressId));

    if (dress == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorState(message: s.error),
      );
    }

    final store = dress.storeId != null
        ? ref.watch(storeByIdProvider(dress.storeId!))
        : null;
    final owner = FakeDatabase.instance.users.cast<AppUser?>().firstWhere(
      (u) => u!.id == dress.ownerId,
      orElse: () => null,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 440,
            pinned: true,
            backgroundColor: DiahColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageGallery(
                images: dress.images,
                heroTag: heroTag ?? 'dress-detail-$dressId',
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? DiahColors.error : DiahColors.text,
                ),
                onPressed: () {
                  final auth = ref.read(authProvider);
                  if (!auth.isAuthenticated) {
                    context.push('/login');
                    return;
                  }
                  ref.read(favoritesNotifierProvider.notifier).toggle(dress.id);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dress.name,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingWidget(
                        rating: dress.rating,
                        count: dress.reviews.length,
                      ),
                      const Spacer(),
                      PriceWidget(
                        amount: dress.pricePerDay,
                        suffix: s.pricePerDay,
                        large: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.palette_outlined,
                        label: '${s.color}: ${dress.color}',
                      ),
                      _InfoChip(
                        icon: Icons.straighten,
                        label: '${s.size}: ${dress.sizes.join(", ")}',
                      ),
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: s.categoryLabel(dress.category),
                      ),
                      _InfoChip(
                        icon: Icons.account_balance_wallet_outlined,
                        label: '${s.deposit}: ${s.formatPrice(dress.deposit)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    s.description,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dress.description,
                    style: const TextStyle(
                      height: 1.6,
                      color: DiahColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    s.availability,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LuxuryCard(
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          color: DiahColors.accent.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        disabledDecoration: const BoxDecoration(
                          color: Color(0xFFE8D4D4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      enabledDayPredicate: (day) => dress.isAvailableOn(day),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (store != null && store.showBrandName) ...[
                    Text(
                      s.store,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LuxuryCard(
                      onTap: () {
                        ref
                            .read(searchFiltersProvider.notifier)
                            .setStore(store.id);
                        context.go('/search');
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: DressImage(
                              source: store.imageUrl ?? '',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  store.city,
                                  style: const TextStyle(
                                    color: DiahColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          RatingWidget(rating: store.rating),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else if (owner != null) ...[
                    // Privacy: never expose individual owner personal names.
                    Text(
                      s.personalWardrobe,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LuxuryCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: DiahColors.softLavender,
                            child: const Icon(
                              Icons.checkroom_outlined,
                              color: DiahColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.t(
                                'خزانة شخصية موثّقة',
                                'Garde-robe personnelle vérifiée',
                                'Verified personal wardrobe',
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    s.reviews,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (dress.reviews.isEmpty)
                    Text(
                      s.t('لا توجد تقييمات بعد', "Pas encore d'avis", "Pas encore d'avis"),
                      style: const TextStyle(color: DiahColors.textMuted),
                    )
                  else
                    ...dress.reviews.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LuxuryCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    r.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  RatingWidget(rating: r.rating),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(r.comment),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: PrimaryButton(
            label: s.bookNow,
            icon: Icons.calendar_month_outlined,
            onPressed: () {
              final auth = ref.read(authProvider);
              if (!auth.isAuthenticated) {
                context.push('/login');
                return;
              }
              ref.read(bookingDraftProvider.notifier).start(dress.id);
              context.push('/booking/${dress.id}');
            },
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DiahColors.softLavender,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: DiahColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
