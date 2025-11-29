import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ColorContent extends StackItemContent {
  ColorContent({required this.color});

  Color color;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'color': color.toARGB32(),
    };
  }
}

class ColorStackItem extends StackItem<ColorContent> {
  ColorStackItem({
    required super.size,
    super.id,
    super.offset,
    super.angle = null,
    super.status = null,
    super.content,
    super.flipX = false,
    super.flipY = false,
    super.locked = false,
    super.lockZOrder = false,
  });

  @override
  ColorStackItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    ColorContent? content,
    bool? flipX,
    bool? flipY,
    bool? locked,
  }) {
    return ColorStackItem(
      id: id, // <= must !!
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      content: content ?? this.content,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      locked: locked ?? this.locked,
      lockZOrder: lockZOrder ?? this.lockZOrder,
    );
  }
}
