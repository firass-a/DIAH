import 'package:flutter/material.dart';

import '../theme/diah_theme.dart';

/// Brand logo used across splash, auth, and home.
class DiahLogo extends StatelessWidget {
  const DiahLogo({
    super.key,
    this.size = 120,
    this.showShadow = true,
  });

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: DiahColors.primary.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/diah_logo.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: DiahColors.softLavender,
          alignment: Alignment.center,
          child: Text(
            'D',
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w600,
              color: DiahColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
