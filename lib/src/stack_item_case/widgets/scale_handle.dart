import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ScaleHandle extends StatelessWidget {
  const ScaleHandle({
    super.key,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.cursor,
    required this.caseStyle,
    required this.icon,
  });

  final Function(DragStartDetails) onPanStart;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;
  final MouseCursor cursor;
  final CaseStyle caseStyle;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Container(
          width: caseStyle.buttonSize,
          height: caseStyle.buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: caseStyle.buttonBgColor,
            border: Border.all(
              width: caseStyle.buttonBorderWidth,
              color: caseStyle.buttonBorderColor,
            ),
          ),
          child: icon == null
              ? null
              : IconTheme(
                  data: Theme.of(context).iconTheme.copyWith(
                        color: caseStyle.buttonIconColor,
                        size: caseStyle.buttonSize * 0.6,
                      ),
                  child: icon!,
                ),
        ),
      ),
    );
  }
}
