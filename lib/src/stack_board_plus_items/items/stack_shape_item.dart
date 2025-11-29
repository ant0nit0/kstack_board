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
    // TODO: implement toJson
    throw UnimplementedError();
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
    );
  }
}
