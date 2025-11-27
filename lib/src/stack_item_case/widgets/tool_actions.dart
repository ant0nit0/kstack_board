import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ToolActionParams {
  final StackItem<StackItemContent> item;
  final BuildContext context;
  final CaseStyle style;
  final List<Widget> Function(StackItem<StackItemContent>, BuildContext)?
      customActionsBuilder;
  final VoidCallback? onDel;
  final Function(DragStartDetails) onRotateStart;
  final Function(DragUpdateDetails) onRotateUpdate;
  final Function(DragEndDetails) onRotateEnd;
  final Function(DragStartDetails) onMoveStart;
  final Function(DragUpdateDetails) onMoveUpdate;
  final Function(DragEndDetails) onMoveEnd;

  ToolActionParams({
    required this.item,
    required this.context,
    required this.style,
    this.customActionsBuilder,
    this.onDel,
    required this.onRotateStart,
    required this.onRotateUpdate,
    required this.onRotateEnd,
    required this.onMoveStart,
    required this.onMoveUpdate,
    required this.onMoveEnd,
  });
}

class ToolActions extends StatelessWidget {
  final ToolActionParams params;

  const ToolActions({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final buttonSize = params.style.buttonStyle.size ?? 24.0;

    return Positioned(
      top: -buttonSize * 0.1,
      left: 0,
      right: 0,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          ...StackItemActionHelper.buildCustomActions(
            item: params.item,
            context: params.context,
            customActionsBuilder: params.customActionsBuilder,
            caseStyle: params.style,
          ),
          if (params.item.status != StackItemStatus.editing) ...[
            _buildRotateHandle(),
            if ((params.item.size.width + params.item.size.height <
                    buttonSize * 6) ||
                (params.item is StackDrawItem))
              _buildMoveHandle(),
          ],
          if (!(params.item.size.width + params.item.size.height <
              buttonSize * 6))
            _buildDeleteHandle(),
        ],
      ),
    );
  }

  Widget _buildRotateHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: params.onRotateStart,
        onPanUpdate: params.onRotateUpdate,
        onPanEnd: params.onRotateEnd,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: _ToolButton(
            style: params.style,
            child: const Icon(Icons.sync),
          ),
        ),
      ),
    );
  }

  Widget _buildMoveHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: params.onMoveStart,
        onPanUpdate: params.onMoveUpdate,
        onPanEnd: params.onMoveEnd,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: _ToolButton(
            style: params.style,
            child: const Icon(Icons.open_with),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: params.onDel,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: _ToolButton(
            style: params.style,
            child: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final CaseStyle style;
  final Widget? child;

  const _ToolButton({required this.style, this.child});

  @override
  Widget build(BuildContext context) {
    final size = style.buttonStyle.size ?? 24.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.buttonStyle.color ?? Colors.white,
        border: Border.all(
          width: style.buttonStyle.borderWidth ?? 1.0,
          color: style.buttonStyle.borderColor ?? Colors.grey,
        ),
      ),
      child: child == null
          ? null
          : IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                    color: style.buttonStyle.iconColor ?? Colors.grey,
                    size: size * 0.6,
                  ),
              child: child!,
            ),
    );
  }
}
