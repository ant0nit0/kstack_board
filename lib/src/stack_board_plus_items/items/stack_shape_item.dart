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
  final StackShapeType type;
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

  StackShapeContent copyWith({
    StackShapeType? type,
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
    StackShapeType type = StackShapeType.values.byName(json['type']);
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
