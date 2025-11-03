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
class StackShapeData {
  final StackShapeType type;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double opacity; // 0.0 - 1.0
  final double tilt; // in degrees
  final double width;
  final double height;
  final bool flipHorizontal;
  final bool flipVertical;
  final int? endpoints; // for polygon/star only

  StackShapeData({
    required this.type,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.opacity,
    required this.tilt,
    required this.width,
    required this.height,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.endpoints,
  });

  StackShapeData copyWith({
    StackShapeType? type,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    double? opacity,
    double? tilt,
    double? width,
    double? height,
    bool? flipHorizontal,
    bool? flipVertical,
    int? endpoints,
  }) {
    return StackShapeData(
      type: type ?? this.type,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      tilt: tilt ?? this.tilt,
      width: width ?? this.width,
      height: height ?? this.height,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      endpoints: endpoints ?? this.endpoints,
    );
  }
}

class StackShapeItem extends StackItem<StackItemContent> {
  final StackShapeData data;
  StackShapeItem({
    required this.data,
    required super.size,
    super.offset,
    super.angle = null,
    super.status = null,
    super.lockZOrder = null,
    super.id,
  }) : super(
          content: null,
        );

  @override
  StackShapeItem copyWith({
    StackShapeData? data,
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    StackItemContent? content, // not used, but required for override
  }) {
    return StackShapeItem(
      data: data ?? this.data,
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
    );
  }
} 