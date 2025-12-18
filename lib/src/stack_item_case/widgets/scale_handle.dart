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
    final size =
        caseStyle.scaleHandleStyle?.size ?? caseStyle.buttonStyle.size ?? 24.0;
    final hitAreaPadding = caseStyle.handleHitAreaPadding;

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: Padding(
          padding: EdgeInsets.all(hitAreaPadding),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: caseStyle.scaleHandleStyle?.color ??
                  caseStyle.buttonStyle.color,
              border: Border.all(
                width: caseStyle.scaleHandleStyle?.borderWidth ??
                    caseStyle.buttonStyle.borderWidth ??
                    1.0,
                color: caseStyle.scaleHandleStyle?.borderColor ??
                    caseStyle.buttonStyle.borderColor ??
                    Colors.grey,
              ),
            ),
            child: icon == null
                ? null
                : IconTheme(
                    data: Theme.of(context).iconTheme.copyWith(
                          color: caseStyle.buttonStyle.iconColor,
                          size: size * 0.6,
                        ),
                    child: icon!,
                  ),
          ),
        ),
      ),
    );
  }
}
