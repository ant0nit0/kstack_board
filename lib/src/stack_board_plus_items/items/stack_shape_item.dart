import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// Enum for supported shape types
enum StackShapeType {
  rectangle,
  circle,
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
  });

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
    };
  }

  factory StackShapeContent.fromJson(Map<String, dynamic> json) {
    return StackShapeContent(
      type: StackShapeType.values.byName(json['type']),
      fillColor: Color(asNullT<int>(json['fillColor']) ?? 0xFF000000),
      strokeColor: Color(asNullT<int>(json['strokeColor']) ?? 0xFF000000),
      strokeWidth: asNullT<double>(json['strokeWidth']) ?? 0.0,
      opacity: asNullT<double>(json['opacity']) ?? 1.0,
      tilt: asNullT<double>(json['tilt']) ?? 0.0,
      width: asNullT<double>(json['width']) ?? 100.0,
      height: asNullT<double>(json['height']) ?? 100.0,
      endpoints: asNullT<int>(json['endpoints']),
    );
  }

  @override
  StackShapeContent resize(double scaleFactor) {
    return copyWith(
      strokeWidth: strokeWidth * scaleFactor,
      width: width * scaleFactor,
      height: height * scaleFactor,
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
