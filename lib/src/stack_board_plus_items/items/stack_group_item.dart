import 'package:flutter/painting.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import '../item_content/stack_group_content.dart';

/// StackGroupItem represents a group of stack items
/// Groups behave as a single unit for transformations
class StackGroupItem extends StackItem<GroupItemContent> {
  StackGroupItem({
    super.content,
    super.id,
    super.angle = 0,
    required super.size,
    super.offset,
    super.lockZOrder = false,
    super.status = null,
    super.flipX = false,
    super.flipY = false,
    super.locked = false,
  });

  factory StackGroupItem.fromJson(Map<String, dynamic> data) {
    return StackGroupItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? 0.0 : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset:
          data['offset'] == null ? null : jsonToOffset(asMap(data['offset'])),
      status: StackItemStatus.values[data['status'] as int],
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      locked: asNullT<bool>(data['locked']) ?? false,
      flipX: asNullT<bool>(data['flipX']) ?? false,
      flipY: asNullT<bool>(data['flipY']) ?? false,
      content: GroupItemContent.fromJson(asMap(data['content'])),
    );
  }

  @override
  StackGroupItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    GroupItemContent? content,
    bool? flipX,
    bool? flipY,
    bool? locked,
  }) {
    return StackGroupItem(
      id: id,
      angle: angle ?? this.angle,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      content: content ?? this.content,
      locked: locked ?? this.locked,
    );
  }
}
