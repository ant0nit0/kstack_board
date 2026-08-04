import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// Enum for supported shape types
enum StackShapeType {
  rectangle,
  circle,

  /// Kept for backward-compatible deserialization of old journals only.
  /// Loaded instances are migrated to [rectangle] + a `borderRadius`.
  roundedRectangle,
  line,
  star,
  polygon,
  heart,
  halfMoon,
}

/// Data model for a shape's properties
class StackShapeContent implements StackItemContent {
  /// The silhouette, as one of the eight the package itself can draw.
  ///
  /// Still written on every save, and still the only thing an older build
  /// reads. When [shapeId] names a silhouette from the host app's wider
  /// catalogue, this holds the nearest of the eight so that build gets a
  /// rectangle rather than an exception.
  final StackShapeType type;

  /// The silhouette, as the host app's catalogue names it.
  ///
  /// Null on everything saved before that catalogue existed, and on anything
  /// whose shape is one of the original eight. Takes precedence over [type]
  /// wherever it is set.
  final String? shapeId;

  /// Per-item seed for the silhouettes that are generated from noise, so two
  /// torn shapes on a page do not tear identically.
  final int seed;

  /// A picture shown inside the silhouette, clipped to it.
  ///
  /// The same triple every image-backed item carries: the local image id, the
  /// Cloud Storage URL a synced page arrives with, and the stock id.
  final String? assetName;
  final String? url;
  final String? pixabayId;

  /// How that picture sits in the silhouette's box.
  final BoxFit imageFit;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double opacity; // 0.0 - 1.0
  final double tilt; // in degrees
  final double width;
  final double height;
  final int? endpoints; // for polygon/star only
  final double borderRadius; // for rectangle only
  final Color? shadowColor; // null = no shadow
  final Offset? shadowOffset;
  final double shadowBlurRadius;

  StackShapeContent({
    required this.type,
    this.shapeId,
    this.seed = 0,
    this.assetName,
    this.url,
    this.pixabayId,
    this.imageFit = BoxFit.cover,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.opacity,
    required this.tilt,
    required this.width,
    required this.height,
    this.endpoints,
    this.borderRadius = 0.0,
    this.shadowColor,
    this.shadowOffset,
    this.shadowBlurRadius = 0.0,
  });

  bool get hasShadow => shadowColor != null;

  /// Whether there is a picture to show inside the silhouette.
  bool get hasImage =>
      (assetName != null && assetName!.isNotEmpty) ||
      (url != null && url!.isNotEmpty);

  StackShapeContent copyWith({
    StackShapeType? type,
    String? shapeId,
    int? seed,
    String? assetName,
    String? url,
    String? pixabayId,
    BoxFit? imageFit,
    bool clearImage = false,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? opacity,
    double? tilt,
    double? width,
    double? height,
    int? endpoints,
    double? borderRadius,
    Color? shadowColor,
    Offset? shadowOffset,
    double? shadowBlurRadius,
    bool clearShadow = false,
  }) {
    return StackShapeContent(
      type: type ?? this.type,
      shapeId: shapeId ?? this.shapeId,
      seed: seed ?? this.seed,
      assetName: clearImage ? null : (assetName ?? this.assetName),
      url: clearImage ? null : (url ?? this.url),
      pixabayId: clearImage ? null : (pixabayId ?? this.pixabayId),
      imageFit: imageFit ?? this.imageFit,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      tilt: tilt ?? this.tilt,
      width: width ?? this.width,
      height: height ?? this.height,
      endpoints: endpoints ?? this.endpoints,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowColor: clearShadow ? null : (shadowColor ?? this.shadowColor),
      shadowOffset: clearShadow ? null : (shadowOffset ?? this.shadowOffset),
      shadowBlurRadius:
          clearShadow ? 0.0 : (shadowBlurRadius ?? this.shadowBlurRadius),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      if (shapeId != null) 'shapeId': shapeId,
      if (seed != 0) 'seed': seed,
      if (assetName != null) 'assetName': assetName,
      if (url != null) 'url': url,
      if (pixabayId != null) 'pixabayId': pixabayId,
      'imageFit': imageFit.index,
      'fillColor': fillColor.toARGB32(),
      'strokeColor': strokeColor.toARGB32(),
      'strokeWidth': strokeWidth,
      'opacity': opacity,
      'tilt': tilt.toString(),
      'width': width.toString(),
      'height': height.toString(),
      'endpoints': endpoints.toString(),
      'borderRadius': borderRadius,
      if (shadowColor != null) 'shadowColor': shadowColor?.toARGB32(),
      if (shadowOffset != null)
        'shadowOffset': {'dx': shadowOffset!.dx, 'dy': shadowOffset!.dy},
      'shadowBlurRadius': shadowBlurRadius,
    };
  }

  factory StackShapeContent.fromJson(Map<String, dynamic> json) {
    // Tolerant on purpose. A page synced from a build that knows a shape this
    // one does not must still open — showing a rectangle — rather than throwing
    // and taking the whole page's load down with it.
    StackShapeType type = StackShapeType.values.firstWhere(
      (StackShapeType t) => t.name == json['type'],
      orElse: () => StackShapeType.rectangle,
    );
    final double width = asNullT<double>(json['width']) ?? 100.0;
    final double height = asNullT<double>(json['height']) ?? 100.0;
    double borderRadius = asNullT<double>(json['borderRadius']) ?? 0.0;
    // Migrate legacy rounded rectangles to rectangle + border radius,
    // matching the radius the old painter used (min(w, h) * 0.2).
    if (type == StackShapeType.roundedRectangle) {
      type = StackShapeType.rectangle;
      if (borderRadius == 0.0) {
        borderRadius = (width < height ? width : height) * 0.2;
      }
    }
    return StackShapeContent(
      type: type,
      shapeId: asNullT<String>(json['shapeId']),
      seed: asNullT<int>(json['seed']) ?? 0,
      assetName: asNullT<String>(json['assetName']),
      url: asNullT<String>(json['url']),
      pixabayId: asNullT<String>(json['pixabayId']),
      imageFit: json['imageFit'] == null
          ? BoxFit.cover
          : BoxFit.values[asT<int>(json['imageFit'])],
      fillColor: Color(asNullT<int>(json['fillColor']) ?? 0xFF000000),
      strokeColor: Color(asNullT<int>(json['strokeColor']) ?? 0xFF000000),
      strokeWidth: asNullT<double>(json['strokeWidth']) ?? 0.0,
      opacity: asNullT<double>(json['opacity']) ?? 1.0,
      tilt: asNullT<double>(json['tilt']) ?? 0.0,
      width: width,
      height: height,
      endpoints: asNullT<int>(json['endpoints']),
      borderRadius: borderRadius,
      shadowColor: json['shadowColor'] == null
          ? null
          : Color(asT<int>(json['shadowColor'])),
      shadowOffset: json['shadowOffset'] == null
          ? null
          : Offset(
              asT<double>(json['shadowOffset']['dx']),
              asT<double>(json['shadowOffset']['dy']),
            ),
      shadowBlurRadius: asNullT<double>(json['shadowBlurRadius']) ?? 0.0,
    );
  }

  @override
  StackShapeContent resize(double scaleFactor) {
    return copyWith(
      strokeWidth: strokeWidth * scaleFactor,
      width: width * scaleFactor,
      height: height * scaleFactor,
      borderRadius: borderRadius * scaleFactor,
      shadowOffset: shadowOffset == null
          ? null
          : Offset(
              shadowOffset!.dx * scaleFactor,
              shadowOffset!.dy * scaleFactor,
            ),
      shadowBlurRadius: shadowBlurRadius * scaleFactor,
    );
  }
}

class StackShapeItem extends StackItem<StackShapeContent> {
  StackShapeItem({
    required super.size,
    required super.content,
    super.offset,
    super.angle = null,
    super.status = null,
    super.lockZOrder = null,
    super.flipX = false,
    super.flipY = false,
    super.id,
    super.locked = false,
    super.opacity = 1,
  });

  @override
  StackShapeItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    bool? flipX,
    bool? flipY,
    StackShapeContent? content, // not used, but required for override
    bool? locked,
    double? opacity,
  }) {
    return StackShapeItem(
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      content: content ?? this.content,
      locked: locked ?? this.locked,
      opacity: opacity ?? this.opacity,
    );
  }

  factory StackShapeItem.fromJson(Map<String, dynamic> json) {
    return StackShapeItem(
      id: asNullT<String>(json['id']),
      size: jsonToSize(asMap(json['size'])),
      offset: jsonToOffset(asMap(json['offset'])),
      angle: asNullT<double>(json['angle']) ?? 0.0,
      status: StackItemStatus.values[asNullT<int>(json['status']) ?? 0],
      lockZOrder: asNullT<bool>(json['lockZOrder']) ?? false,
      flipX: asNullT<bool>(json['flipX']) ?? false,
      flipY: asNullT<bool>(json['flipY']) ?? false,
      locked: asNullT<bool>(json['locked']) ?? false,
      opacity: asNullT<double>(json['opacity']) ?? 1.0,
      content: StackShapeContent.fromJson(asMap(json['content'])),
    );
  }
}
