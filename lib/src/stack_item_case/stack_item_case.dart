import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

import 'stack_item_types.dart';
import 'stack_item_gestures_mixin.dart';
import 'widgets/scale_handle.dart';
import 'widgets/resize_handle.dart';
import 'widgets/tool_actions.dart';

/// This is the main class for the stack item case
/// It is used to wrap the stack item and provide the functions of the stack item
/// It is the core of the stack board plus
/// * Operate box
/// * Used to wrap child widgets to provide functions of operate box
/// * 1. Drag
/// * 2. Scale
/// * 3. Resize
/// * 4. Rotate
/// * 5. Select
/// * 6. Edit
/// * 7. Delete (white in edit status)
class StackItemCase extends StatefulWidget {
  const StackItemCase({
    super.key,
    required this.stackItem,
    required this.childBuilder,
    this.caseStyle,
    this.onDel,
    this.onTap,
    this.onSizeChanged,
    this.onOffsetChanged,
    this.onAngleChanged,
    this.onStatusChanged,
    this.actionsBuilder,
    this.borderBuilder,
    this.customActionsBuilder,
  });

  /// * StackItemData
  final StackItem<StackItemContent> stackItem;

  /// * Child builder, update when item status changed
  final Widget? Function(StackItem<StackItemContent> item)? childBuilder;

  /// * Outer frame style
  final CaseStyle? caseStyle;

  /// * Remove intercept
  final void Function()? onDel;

  /// * Click callback
  final void Function()? onTap;

  /// * Size change callback
  /// * The return value can control whether to continue
  final bool? Function(Size size)? onSizeChanged;

  /// * Position change callback
  /// * The return value can control whether to continue
  final bool? Function(Offset offset)? onOffsetChanged;

  /// * Angle change callback
  /// * The return value can control whether to continue
  final bool? Function(double angle)? onAngleChanged;

  /// * Operation status callback
  /// * The return value can control whether to continue
  final bool? Function(StackItemStatus operatState)? onStatusChanged;

  /// * Operation layer builder
  final Widget Function(StackItemStatus operatState, CaseStyle caseStyle)?
      actionsBuilder;

  /// * Border builder
  final Widget Function(StackItemStatus operatState)? borderBuilder;

  final List<Widget> Function(
          StackItem<StackItemContent> item, BuildContext context)?
      customActionsBuilder;

  @override
  State<StatefulWidget> createState() {
    return _StackItemCaseState();
  }
}

class _StackItemCaseState extends State<StackItemCase>
    with StackItemGestures<StackItemCase> {
  @override
  StackBoardPlusController get controller =>
      StackBoardPlusConfig.of(context).controller;

  @override
  StackItem<StackItemContent> get stackItem => widget.stackItem;

  @override
  void onStatusChanged(StackItemStatus status) =>
      widget.onStatusChanged?.call(status);

  @override
  void onOffsetChanged(Offset offset) => widget.onOffsetChanged?.call(offset);

  @override
  void onSizeChanged(Size size) => widget.onSizeChanged?.call(size);

  @override
  void onAngleChanged(double angle) => widget.onAngleChanged?.call(angle);

  /// * Outer frame style
  CaseStyle _caseStyle(BuildContext context) =>
      widget.caseStyle ??
      StackBoardPlusConfig.of(context).caseStyle ??
      const CaseStyle();

  @override
  double getMinSize(BuildContext context) => _caseStyle(context).buttonSize * 2;

  /// * Main body mouse pointer style
  MouseCursor _cursor(StackItemStatus status) {
    if (status == StackItemStatus.moving) {
      return SystemMouseCursors.grabbing;
    } else if (status == StackItemStatus.editing) {
      return SystemMouseCursors.click;
    }

    return SystemMouseCursors.grab;
  }

  /// * Click
  void _onTap(BuildContext context) {
    widget.onTap?.call();
    controller.selectOne(itemId);
    widget.onStatusChanged?.call(StackItemStatus.selected);
  }

  /// * Click edit
  void _onEdit(BuildContext context, StackItemStatus status) {
    if (status == StackItemStatus.editing) return;

    final StackBoardPlusController stackController = controller;
    status = StackItemStatus.editing;
    stackController.selectOne(itemId);
    stackController.updateBasic(itemId, status: status);
    widget.onStatusChanged?.call(status);
  }

  @override
  Widget build(BuildContext context) {
    return ConfigBuilder.withItem(
      itemId,
      shouldRebuild:
          (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
              p.offset != n.offset ||
              p.angle != n.angle ||
              p.size != n.size ||
              p.status != n.status,
      childBuilder: (StackItem<StackItemContent> item, Widget c) {
        return Positioned(
          key: ValueKey<String>(item.id),
          top: item.offset.dy,
          left: item.offset.dx,
          child: Transform.translate(
            offset: Offset(
                -item.size.width / 2 -
                    (item.status != StackItemStatus.idle
                        ? _caseStyle(context).buttonSize / 2
                        : 0),
                -item.size.height / 2 -
                    (item.status != StackItemStatus.idle
                        ? _caseStyle(context).buttonSize * 1.5
                        : 0)),
            child: Transform.rotate(angle: item.angle, child: c),
          ),
        );
      },
      child: ConfigBuilder.withItem(
        itemId,
        shouldRebuild:
            (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
                p.status != n.status,
        childBuilder: (StackItem<StackItemContent> item, Widget c) {
          if (item.status == StackItemStatus.locked) {
            return IgnorePointer(child: _content(context, item));
          }
          return MouseRegion(
            cursor: _cursor(item.status),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (ScaleStartDetails details) =>
                  onGestureStart(details, context),
              onScaleUpdate: (ScaleUpdateDetails details) =>
                  onGestureUpdate(details, context),
              onScaleEnd: (ScaleEndDetails details) =>
                  onGestureEnd(details, context),
              onTap: () => _onTap(context),
              onDoubleTap: () => _onEdit(context, item.status),
              child: _childrenStack(context, item),
            ),
          );
        },
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _childrenStack(
      BuildContext context, StackItem<StackItemContent> item) {
    final CaseStyle style = _caseStyle(context);

    final List<Widget> widgets = <Widget>[_content(context, item)];

    widgets.add(widget.borderBuilder?.call(item.status) ??
        _frameBorder(context, item.status));

    if (widget.actionsBuilder != null) {
      widgets.add(widget.actionsBuilder!(item.status, _caseStyle(context)));
    } else if (item.status != StackItemStatus.editing) {
      if (item.status != StackItemStatus.idle) {
        if (item.size.height > getMinSize(context) * 2) {
          widgets.add(Positioned(
              bottom: style.buttonSize,
              right: 0,
              top: style.buttonSize,
              child: _buildResizeXHandle(
                  context, item.status, HandlePosition.right)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              top: style.buttonSize,
              child: _buildResizeXHandle(
                  context, item.status, HandlePosition.left)));
        }
        if (item.size.width > getMinSize(context) * 2) {
          widgets.add(Positioned(
              left: 0,
              top: style.buttonSize,
              right: 0,
              child: _buildResizeYHandle(
                  context, item.status, HandlePosition.top)));
          widgets.add(Positioned(
              left: 0,
              bottom: style.buttonSize,
              right: 0,
              child: _buildResizeYHandle(
                  context, item.status, HandlePosition.bottom)));
        }
        if (item.size.height > getMinSize(context) &&
            item.size.width > getMinSize(context)) {
          widgets.add(Positioned(
              top: style.buttonSize,
              right: 0,
              child: _buildScaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpRightDownLeft,
                  HandlePosition.topRight)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              child: _buildScaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpRightDownLeft,
                  HandlePosition.bottomLeft)));
        }
        widgets.addAll(<Widget>[
          if (item.status == StackItemStatus.editing)
            _buildDeleteHandle(context)
          else
            ToolActions(
              params: ToolActionParams(
                item: item,
                context: context,
                style: style,
                customActionsBuilder: widget.customActionsBuilder,
                onDel: widget.onDel,
                onRotateStart: (d) =>
                    onPanStart(d, context, StackItemStatus.roating),
                onRotateUpdate: (d) => onRotateUpdate(d, context, item.status),
                onRotateEnd: (_) => onPanEnd(context, item.status),
                onMoveStart: (d) =>
                    onPanStart(d, context, StackItemStatus.moving),
                onMoveUpdate: (d) => onPanUpdate(d, context),
                onMoveEnd: (_) => onPanEnd(context, item.status),
              ),
            ),
          Positioned(
              top: style.buttonSize,
              left: 0,
              child: _buildScaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpLeftDownRight,
                  HandlePosition.topLeft)),
          Positioned(
              bottom: style.buttonSize,
              right: 0,
              child: _buildScaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpLeftDownRight,
                  HandlePosition.bottomRight)),
        ]);
      }
    } else {
      widgets.add(_buildDeleteHandle(context));
    }
    return Stack(children: widgets);
  }

  /// * Child component
  Widget _content(BuildContext context, StackItem<StackItemContent> item) {
    final CaseStyle style = _caseStyle(context);

    final Widget content =
        widget.childBuilder?.call(item) ?? const SizedBox.shrink();

    return ConfigBuilder.withItem(
      itemId,
      shouldRebuild:
          (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
              p.size != n.size || p.status != n.status,
      childBuilder: (StackItem<StackItemContent> item, Widget c) {
        return Padding(
            padding: item.status == StackItemStatus.idle
                ? EdgeInsets.zero
                : EdgeInsets.fromLTRB(
                    style.buttonSize / 2,
                    style.buttonSize * 1.5,
                    style.buttonSize / 2,
                    style.buttonSize * 1.5),
            child: SizedBox.fromSize(size: item.size, child: c));
      },
      child: content,
    );
  }

  /// * Border
  Widget _frameBorder(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);

    return Positioned(
        top: style.buttonSize * 1.5,
        bottom: style.buttonSize * 1.5,
        left: style.buttonSize / 2,
        right: style.buttonSize / 2,
        child: IgnorePointer(
          ignoring: true,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: status == StackItemStatus.idle
                    ? Colors.transparent
                    : style.frameBorderColor,
                width: style.frameBorderWidth,
              ),
            ),
          ),
        ));
  }

  /// * Delete handle
  Widget _buildDeleteHandle(BuildContext context) {
    final CaseStyle style = _caseStyle(context);

    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onDel?.call(),
          child: Container(
            width: style.buttonSize,
            height: style.buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.buttonBgColor,
              border: Border.all(
                width: style.buttonBorderWidth,
                color: style.buttonBorderColor,
              ),
            ),
            child: IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                    color: style.buttonIconColor,
                    size: style.buttonSize * 0.6,
                  ),
              child: const Icon(Icons.delete),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaleHandle(BuildContext context, StackItemStatus status,
      MouseCursor cursor, HandlePosition handle) {
    final CaseStyle style = _caseStyle(context);

    return ScaleHandle(
      onPanStart: (d) => onPanStart(d, context, StackItemStatus.scaling),
      onPanUpdate: (d) => onScaleUpdate(d, context, status, handle),
      onPanEnd: (_) => onPanEnd(context, status),
      cursor: cursor,
      caseStyle: style,
      icon: null,
    );
  }

  Widget _buildResizeXHandle(
      BuildContext context, StackItemStatus status, HandlePosition handle) {
    final CaseStyle style = _caseStyle(context);
    return ResizeHandle(
      onPanStart: (d) => onPanStart(d, context, StackItemStatus.resizing),
      onPanUpdate: (d) => onResizeUpdate(d, context, status, handle),
      onPanEnd: (_) => onPanEnd(context, status),
      cursor: SystemMouseCursors.resizeColumn,
      caseStyle: style,
      width: style.buttonSize / 3,
      height: style.buttonSize,
    );
  }

  Widget _buildResizeYHandle(
      BuildContext context, StackItemStatus status, HandlePosition handle) {
    final CaseStyle style = _caseStyle(context);
    return ResizeHandle(
      onPanStart: (d) => onPanStart(d, context, StackItemStatus.resizing),
      onPanUpdate: (d) => onResizeUpdate(d, context, status, handle),
      onPanEnd: (_) => onPanEnd(context, status),
      cursor: SystemMouseCursors.resizeRow,
      caseStyle: style,
      width: style.buttonSize,
      height: style.buttonSize / 3,
    );
  }
}
