import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/diah_theme.dart';

class StoreStatCard extends StatelessWidget {
  const StoreStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? DiahColors.primary;
    return Material(
      color: DiahColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DiahColors.border),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DiahColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: DiahColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreSectionTitle extends StatelessWidget {
  const StoreSectionTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class StoreBarChart extends StatelessWidget {
  const StoreBarChart({super.key, required this.values, this.labels});

  final List<double> values;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(0, (m, v) => v > m ? v : m);
    final safeMax = max <= 0 ? 1.0 : max;
    const chartHeight = 180.0;
    const labelSlot = 18.0;
    const valueSlot = 18.0;
    const gaps = 10.0;
    const maxBar = chartHeight - labelSlot - valueSlot - gaps;

    // Charts & numeric axes stay LTR even in Arabic RTL UI.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: chartHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: TextDirection.ltr,
          children: List.generate(values.length, (i) {
            final h = (values[i] / safeMax) * maxBar;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: valueSlot,
                      child: Center(
                        child: Text(
                          values[i] >= 1000
                              ? '${(values[i] / 1000).toStringAsFixed(0)}k'
                              : values[i].toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            color: DiahColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: h.clamp(4, maxBar),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            DiahColors.primary,
                            DiahColors.accent.withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: labelSlot,
                      child: Center(
                        child: Text(
                          labels != null && i < labels!.length
                              ? labels![i]
                              : 'M${i + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: DiahColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class StorePanel extends StatelessWidget {
  const StorePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // Use Material (not a colored Container) so ListTile ink/splashes paint correctly.
    return Material(
      color: DiahColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: DiahColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
