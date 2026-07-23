import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// Rotation handle displayed at a corner of the item case.
/// Dragging it rotates the item around its center.
class RotateHandle extends StatelessWidget {
  const RotateHandle({
    super.key,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.caseStyle,
  });

  final Function(DragStartDetails) onPanStart;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;
  final CaseStyle caseStyle;

  @override
  Widget build(BuildContext context) {
    final size =
        caseStyle.scaleHandleStyle?.size ?? caseStyle.buttonStyle.size ?? 24.0;
    final hitAreaPadding = caseStyle.handleHitAreaPadding;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
            child: IconTheme(
              // The handle background uses the scale-handle color (often
              // white), so the icon follows the handle's border color to
              // stay visible — not the buttonStyle icon color (often white).
              data: Theme.of(context).iconTheme.copyWith(
                    color: caseStyle.scaleHandleStyle?.borderColor ??
                        caseStyle.buttonStyle.borderColor ??
                        Colors.grey,
                    size: size * 0.7,
                  ),
              child: const Icon(Icons.refresh),
            ),
          ),
        ),
      ),
    );
  }
}
