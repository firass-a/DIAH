import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/fake_backend/providers.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_widgets.dart';
import '../../../../shared/enums/app_enums.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchFiltersProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DiahColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final results = ref.watch(searchResultsProvider);
    final filters = ref.watch(searchFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.search),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible:
                  filters.category != null ||
                  filters.size != null ||
                  filters.color != null ||
                  filters.occasion != null,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _controller,
              onChanged: (v) =>
                  ref.read(searchFiltersProvider.notifier).setQuery(v),
              decoration: InputDecoration(
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchFiltersProvider.notifier).setQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                DiahFilterChip(
                  label: s.t('الكل', 'Tout', 'Tout'),
                  selected: filters.category == null,
                  onSelected: (_) =>
                      ref.read(searchFiltersProvider.notifier).setCategory(null),
                ),
                const SizedBox(width: 8),
                ...DressCategory.values.map(
                  (c) => Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: DiahFilterChip(
                      label: s.categoryLabel(c),
                      selected: filters.category == c,
                      onSelected: (_) => ref
                          .read(searchFiltersProvider.notifier)
                          .setCategory(filters.category == c ? null : c),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Text(
                  s.t(
                    '${results.length} نتيجة',
                    '${results.length} résultats',
                    '${results.length} results',
                  ),
                  style: const TextStyle(color: DiahColors.textMuted),
                ),
                const Spacer(),
                PopupMenuButton<DressSortOption>(
                  onSelected: (v) =>
                      ref.read(searchFiltersProvider.notifier).setSort(v),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: DressSortOption.newest,
                      child: Text(s.t('الأحدث', 'Plus récent', 'Newest')),
                    ),
                    PopupMenuItem(
                      value: DressSortOption.priceLowToHigh,
                      child: Text(s.t('السعر ↑', 'Prix ↑', 'Price ↑')),
                    ),
                    PopupMenuItem(
                      value: DressSortOption.priceHighToLow,
                      child: Text(s.t('السعر ↓', 'Prix ↓', 'Price ↓')),
                    ),
                    PopupMenuItem(
                      value: DressSortOption.rating,
                      child: Text(s.t('التقييم', 'Note', 'Rating')),
                    ),
                    PopupMenuItem(
                      value: DressSortOption.popular,
                      child: Text(s.t('الأكثر طلباً', 'Populaire', 'Popular')),
                    ),
                  ],
                  child: Row(
                    children: [
                      Text(s.sortBy, style: const TextStyle(color: DiahColors.primary)),
                      const Icon(Icons.arrow_drop_down, color: DiahColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? EmptyState(message: s.noResults, icon: Icons.search_off)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: results.length,
                    itemBuilder: (_, i) => DressCard(
                      dress: results[i],
                      width: double.infinity,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  RangeValues _price = const RangeValues(500, 20000);
  String? _size;
  String? _color;

  static const sizes = ['XS', 'S', 'M', 'L', 'XL', 'One Size'];
  static const colors = [
    'أبيض',
    'أسود وذهبي',
    'وردي',
    'بورغندي',
    'كحلي',
    'ذهبي',
    'أخضر زمردي',
    'شمبانيا',
    'فضي',
    'عاجي',
  ];

  @override
  void initState() {
    super.initState();
    final f = ref.read(searchFiltersProvider);
    _size = f.size;
    _color = f.color;
    _price = RangeValues(f.minPrice ?? 500, f.maxPrice ?? 20000);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DiahColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s.filters,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(s.size, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: sizes
                  .map(
                    (sz) => DiahFilterChip(
                      label: sz,
                      selected: _size == sz,
                      onSelected: (_) =>
                          setState(() => _size = _size == sz ? null : sz),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(s.color, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors
                  .map(
                    (c) => DiahFilterChip(
                      label: c,
                      selected: _color == c,
                      onSelected: (_) =>
                          setState(() => _color = _color == c ? null : c),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '${s.priceRange}: ${_price.start.round()} - ${_price.end.round()}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _price,
              min: 500,
              max: 20000,
              divisions: 39,
              activeColor: DiahColors.primary,
              onChanged: (v) => setState(() => _price = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: s.reset,
                    onPressed: () {
                      ref.read(searchFiltersProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: s.apply,
                    onPressed: () {
                      final n = ref.read(searchFiltersProvider.notifier);
                      n.setSize(_size);
                      n.setColor(_color);
                      n.setPriceRange(_price.start, _price.end);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final auth = ref.watch(authProvider);
    final dresses = ref.watch(favoriteDressesProvider);

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text(s.favorites)),
        body: EmptyState(
          message: s.t(
            'سجّلي الدخول لعرض المفضلة',
            'Connectez-vous pour voir vos favoris',
            'Log in to see your favorites',
          ),
          icon: Icons.favorite_border,
          actionLabel: s.login,
          onAction: () => context.push('/login'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.favorites)),
      body: dresses.isEmpty
          ? EmptyState(message: s.emptyFavorites, icon: Icons.favorite_border)
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              itemCount: dresses.length,
              itemBuilder: (_, i) =>
                  DressCard(dress: dresses[i], width: double.infinity),
            ),
    );
  }
}
