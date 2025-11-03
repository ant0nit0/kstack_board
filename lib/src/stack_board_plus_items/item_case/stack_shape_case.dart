import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// Signature for custom editor builder
/// Passes the current shape item and a callback to update it
/// This can return any widget or trigger any UI pattern (dialogs, bottom sheets, etc.)
typedef ShapeEditorBuilder = Widget Function(
  BuildContext context,
  StackShapeItem item,
  ValueChanged<StackShapeItem> onUpdate,
);

/// Dynamic, extensible case for shape items
class StackShapeCase extends StatefulWidget {
  final StackShapeItem item;
  final ShapeEditorBuilder? customEditorBuilder;
  final bool enableResize;
  final bool enableRotate;
  final bool enableFlip;
  final bool enableMove;

  const StackShapeCase({
    super.key,
    required this.item,
    this.customEditorBuilder,
    this.enableResize = true,
    this.enableRotate = true,
    this.enableFlip = true,
    this.enableMove = true,
  });

  @override
  State<StackShapeCase> createState() => _StackShapeCaseState();
}

class _StackShapeCaseState extends State<StackShapeCase> {
  late StackShapeItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _updateItem(StackShapeItem newItem) {
    setState(() => _item = newItem);
  }

  void _onDoubleTap() {
    if (widget.customEditorBuilder != null) {
      widget.customEditorBuilder!(context, _item, _updateItem);
      return;
    } 
  }

  @override
  Widget build(BuildContext context) {
    // Add gesture handling for resize, rotate, flip, etc. 
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: StackShapeContent(data: _item.data),
    );
  }
} 