import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

/// See `svg_file_picture.dart`. Native implementation: delegates to
/// [SvgPicture.file] exactly as before this shim existed.
SvgPicture? svgPictureFromFile(
  Object file, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  String? semanticsLabel,
  bool excludeFromSemantics = false,
  ColorFilter? colorFilter,
  bool matchTextDirection = false,
}) {
  if (file is! File) return null;
  return SvgPicture.file(
    file,
    width: width,
    height: height,
    fit: fit,
    semanticsLabel: semanticsLabel,
    excludeFromSemantics: excludeFromSemantics,
    colorFilter: colorFilter,
    matchTextDirection: matchTextDirection,
  );
}
