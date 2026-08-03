import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/diah_theme.dart';

bool isNetworkImageSource(String source) {
  final s = source.trim().toLowerCase();
  return s.startsWith('http://') || s.startsWith('https://');
}

bool isAssetImageSource(String source) {
  final s = source.trim();
  return s.startsWith('assets/');
}

/// Renders a dress image from a network URL, bundled asset, or local file path.
class DressImage extends StatelessWidget {
  const DressImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: DiahColors.softLavender,
      alignment: Alignment.center,
      child: const Icon(
        Icons.checkroom_outlined,
        color: DiahColors.accent,
        size: 36,
      ),
    );

    Widget image;
    if (source.trim().isEmpty) {
      image = placeholder;
    } else if (isNetworkImageSource(source)) {
      image = CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => Container(
          width: width,
          height: height,
          color: DiahColors.softLavender,
        ),
        errorWidget: (_, _, _) => placeholder,
      );
    } else if (isAssetImageSource(source)) {
      image = Image.asset(
        source.trim(),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    } else {
      final file = File(source);
      image = file.existsSync()
          ? Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, _, _) => placeholder,
            )
          : placeholder;
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
