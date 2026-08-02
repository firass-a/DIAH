import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/diah_theme.dart';
import '../../../../core/widgets/diah_logo.dart';
import '../../../../core/widgets/diah_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LuxuryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.language,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _LangChip(
                      label: 'English',
                      selected: locale == AppLocale.en,
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(AppLocale.en),
                    ),
                    _LangChip(
                      label: 'العربية',
                      selected: locale == AppLocale.ar,
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(AppLocale.ar),
                    ),
                    _LangChip(
                      label: 'Français',
                      selected: locale == AppLocale.fr,
                      onTap: () => ref
                          .read(localeProvider.notifier)
                          .setLocale(AppLocale.fr),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LuxuryCard(
            child: Row(
              children: [
                const DiahLogo(size: 56, showShadow: false),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.aboutApp,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diah v1.0.0\n${s.aboutBody}',
                        style: const TextStyle(
                          color: DiahColors.textSecondary,
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: DiahColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : DiahColors.text,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: DiahColors.softLavender,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
