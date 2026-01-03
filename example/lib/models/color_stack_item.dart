import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ColorContent extends StackItemContent {
  ColorContent({required this.color});

  Color color;

  factory ColorContent.fromJson(Map<String, dynamic> json) {
    return ColorContent(
      color: Color(json['color'] as int),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'color': color.toARGB32(),
    };
  }

  @override
  ColorContent resize(double scaleFactor) {
    // Color content doesn't need to resize anything
    return ColorContent(color: color);
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

  factory ColorStackItem.fromJson(Map<String, dynamic> data) {
    return ColorStackItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? null : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset:
          data['offset'] == null ? null : jsonToOffset(asMap(data['offset'])),
      status: StackItemStatus.values[data['status'] as int],
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      locked: asNullT<bool>(data['locked']) ?? false,
      flipX: asNullT<bool>(data['flipX']) ?? false,
      flipY: asNullT<bool>(data['flipY']) ?? false,
      content: ColorContent.fromJson(asMap(data['content'])),
    );
  }
}
