import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../shared/enums/app_enums.dart';
import '../../shared/models/models.dart';
import '../fake_backend/providers.dart';
import '../localization/app_strings.dart';
import '../theme/diah_theme.dart';
import 'dress_image.dart';

class LuxuryCard extends StatelessWidget {
  const LuxuryCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DiahColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: color ?? DiahColors.card,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(onPressed: onPressed, child: Text(label));
    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class PriceWidget extends ConsumerWidget {
  const PriceWidget({
    super.key,
    required this.amount,
    this.suffix,
    this.large = false,
  });

  final double amount;
  final String? suffix;
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: s.formatPrice(amount),
              style: GoogleFonts.dmSans(
                fontSize: large ? 22 : 15,
                fontWeight: FontWeight.w700,
                color: DiahColors.primary,
              ),
            ),
            if (suffix != null)
              TextSpan(
                text: ' $suffix',
                style: TextStyle(
                  fontSize: large ? 14 : 12,
                  color: DiahColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.count,
    this.size = 14,
  });

  final double rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: const Color(0xFFD4A017), size: size),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 1,
            fontWeight: FontWeight.w600,
            color: DiahColors.text,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(fontSize: size - 2, color: DiahColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class DiahFilterChip extends StatelessWidget {
  const DiahFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: DiahColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : DiahColors.text,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      checkmarkColor: Colors.white,
      backgroundColor: DiahColors.softLavender,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class DressCard extends ConsumerWidget {
  const DressCard({
    super.key,
    required this.dress,
    this.width = 180,
    /// Unique scope so the same dress can appear in multiple lists safely.
    this.heroScope = 'card',
  });

  final Dress dress;
  final double width;
  final String heroScope;

  String get heroTag => 'dress-$heroScope-${dress.id}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isFav = ref.watch(isFavoriteProvider(dress.id));

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () => context.push('/dress/${dress.id}', extra: heroTag),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: heroTag,
                    child: DressImage(
                      source: dress.images.isNotEmpty ? dress.images.first : '',
                      width: width,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        final auth = ref.read(authProvider);
                        if (!auth.isAuthenticated) {
                          context.push('/login');
                          return;
                        }
                        ref.read(favoritesNotifierProvider.notifier).toggle(
                          dress.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFav ? DiahColors.error : DiahColors.text,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              dress.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: DiahColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: PriceWidget(
                    amount: dress.pricePerDay,
                    suffix: s.pricePerDay,
                  ),
                ),
                RatingWidget(rating: dress.rating, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StoreCard extends ConsumerWidget {
  const StoreCard({super.key, required this.store});

  final Store store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LuxuryCard(
      onTap: () {
        ref.read(searchFiltersProvider.notifier).setStore(store.id);
        context.go('/search');
      },
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: DressImage(
                source: store.imageUrl ?? '',
                height: 110,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.showBrandName ? store.name : 'محل شريك',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: DiahColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store.city,
                          style: const TextStyle(
                            fontSize: 12,
                            color: DiahColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      RatingWidget(rating: store.rating, size: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key, required this.images, this.heroTag});

  final List<String> images;
  final String? heroTag;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final image = DressImage(
                source: widget.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 420,
              );
              if (i == 0 && widget.heroTag != null) {
                return Hero(tag: widget.heroTag!, child: image);
              }
              return image;
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _index == i ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _index == i
                    ? DiahColors.primary
                    : DiahColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: DiahColors.softLavender,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: DiahColors.accent),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: DiahColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: DiahColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: DiahColors.textMuted)),
          ],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      message: message,
      icon: Icons.error_outline,
      actionLabel: onRetry != null ? 'إعادة المحاولة' : null,
      onAction: onRetry,
    );
  }
}

class SectionHeader extends ConsumerWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: DiahColors.text,
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                s.seeAll,
                style: const TextStyle(
                  color: DiahColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String bookingStatusLabel(BookingStatus status, AppStrings s) {
  switch (status) {
    case BookingStatus.pending:
      return s.t('قيد الانتظار', 'En attente', 'Pending');
    case BookingStatus.accepted:
      return s.t('مقبول', 'Accepté', 'Accepted');
    case BookingStatus.rejected:
      return s.t('مرفوض', 'Refusé', 'Rejected');
    case BookingStatus.preparing:
      return s.t('قيد التجهيز', 'En préparation', 'Preparing');
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
