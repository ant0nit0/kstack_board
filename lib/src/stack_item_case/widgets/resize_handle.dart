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
    return Center(
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: SizedBox(
            width: width * 3,
            height: height * 3,
            child: Center(
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color:
                      caseStyle.resizeHandleBgColor ?? caseStyle.buttonBgColor,
                  border: Border.all(
                    width: caseStyle.buttonBorderWidth,
                    color: caseStyle.resizeHandleBorderColor ??
                        caseStyle.buttonBorderColor,
                  ),
                  borderRadius: BorderRadius.circular(caseStyle.buttonSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
