import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// * Generate Id for StackItem
String _genId() {
  final DateTime now = DateTime.now();
  final int value = Random().nextInt(100000);
  return '$value-${now.millisecondsSinceEpoch}';
}

/// * Core class for layout data
/// * Custom needs to inherit this class
@immutable
abstract class StackItem<T extends StackItemContent> {
  StackItem({
    String? id,
    required this.size,
    Offset? offset,
    double? angle = 0,
    StackItemStatus? status = StackItemStatus.selected,
    bool? lockZOrder = false,
    bool? locked = false,
    bool? flipX = false,
    bool? flipY = false,
    this.content,
  })  : id = id ?? _genId(),
        offset = offset ?? Offset.zero,
        angle = angle ?? 0,
        lockZOrder = lockZOrder ?? false,
        flipX = flipX ?? false,
        flipY = flipY ?? false,
        status = status ?? StackItemStatus.selected,
        locked = locked ?? false;

  const StackItem.empty({
    required this.size,
    required this.offset,
    required this.angle,
    required this.status,
    required this.content,
    required this.lockZOrder,
    required this.locked,
    this.flipX = false,
    this.flipY = false,
  }) : id = '';

  /// id
  final String id;

  /// Size
  final Size size;

  /// Offset
  final Offset offset;

  /// Angle
  final double angle;

  /// Status
  final StackItemStatus status;

  final bool lockZOrder;

  final bool locked;

  /// Flip X
  final bool flipX;

  /// Flip Y
  final bool flipY;

  /// Content
  final T? content;

  /// Update content and return new instance
  StackItem<T> copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    bool? locked,
    bool? flipX,
    bool? flipY,
    T? content,
  });

  /// * Resize item based on board size change
  /// * [newBoardSize] is the new board size
  /// * [oldBoardSize] is the old board size
  /// * Returns a new StackItem instance with resized size, offset, and content
  StackItem<T> resize(Size newBoardSize, Size oldBoardSize) {
    // Calculate scale factor (assuming aspect ratio is preserved)
    final scaleFactor = newBoardSize.width / oldBoardSize.width;

    // Scale item size
    final newSize = Size(
      size.width * scaleFactor,
      size.height * scaleFactor,
    );

    // Scale item offset
    final newOffset = Offset(
      offset.dx * scaleFactor,
      offset.dy * scaleFactor,
    );

    // Resize content if it exists
    final newContent = content?.resize(scaleFactor) as T?;

    return copyWith(
      size: newSize,
      offset: newOffset,
      content: newContent,
    );
  }

  /// to json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': runtimeType.toString(),
      'angle': angle,
      'size': size.toJson(),
      'offset': offset.toJson(),
      'status': status.index,
      'lockZOrder': lockZOrder,
      'locked': locked,
      'flipX': flipX,
      'flipY': flipY,
      if (content != null) 'content': content?.toJson(),
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is StackItem && id == other.id;
}
