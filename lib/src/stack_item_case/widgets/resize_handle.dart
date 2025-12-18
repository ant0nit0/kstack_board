import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ResizeHandle extends StatelessWidget {
  const ResizeHandle({
    super.key,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.cursor,
    required this.caseStyle,
    required this.width,
    required this.height,
  });

  final Function(DragStartDetails) onPanStart;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;
  final MouseCursor cursor;
  final CaseStyle caseStyle;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    // width/height passed here are usually the handle size logic from parent.
    // But the style of the handle itself (container) comes from caseStyle.
    final hitAreaPadding = caseStyle.handleHitAreaPadding;

    return Center(
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: Padding(
            padding: EdgeInsets.all(hitAreaPadding),
            child: SizedBox(
              width: width * 3,
              height: height * 3,
              child: Center(
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: caseStyle.resizeHandleStyle?.color ??
                        caseStyle.buttonStyle.color,
                    border: Border.all(
                      width: caseStyle.resizeHandleStyle?.borderWidth ??
                          caseStyle.buttonStyle.borderWidth ??
                          1.0,
                      color: caseStyle.resizeHandleStyle?.borderColor ??
                          caseStyle.buttonStyle.borderColor ??
                          Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(width),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
