import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

/// See `svg_file_picture.dart`. Web implementation: there are no local files on
/// web, so this is unreachable in practice. Returning null lets the caller keep
/// its existing fallback rather than inventing a web-only placeholder here.
SvgPicture? svgPictureFromFile(
  Object file, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  String? semanticsLabel,
  bool excludeFromSemantics = false,
  ColorFilter? colorFilter,
  bool matchTextDirection = false,
}) =>
    null;
