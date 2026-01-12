import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

import 'stack_item_gestures_mixin.dart';
import 'stack_item_types.dart';
import 'widgets/dashed_border.dart';
import 'widgets/resize_handle.dart';
import 'widgets/scale_handle.dart';
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
    this.lockedCaseStyle,
    this.onDel,
    this.onTap,
    this.onSizeChanged,
    this.onOffsetChanged,
    this.onAngleChanged,
    this.onStatusChanged,
    this.actionsBuilder,
    this.borderBuilder,
    this.customActionsBuilder,
    this.minItemSize,
    this.enableLongPressGrouping = true,
  });

  /// * StackItemData
  final StackItem<StackItemContent> stackItem;

  /// * Child builder, update when item status changed
  final Widget? Function(StackItem<StackItemContent> item)? childBuilder;

  /// * Outer frame style
  final CaseStyle? caseStyle;

  /// * Locked outer frame style
  final CaseStyle? lockedCaseStyle;

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
    StackItem<StackItemContent> item,
    BuildContext context,
  )?
  customActionsBuilder;

  /// * Minimum item size
  final double? minItemSize;

  /// * Enable long press to toggle grouping status
  /// * Defaults to true
  final bool enableLongPressGrouping;

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
  CaseStyle _caseStyle(BuildContext context) {
    if (widget.stackItem.locked) {
      final CaseStyle? lockedStyle =
          widget.lockedCaseStyle ??
          StackBoardPlusConfig.of(context).lockedCaseStyle;
      if (lockedStyle != null) return lockedStyle;
    }

    return widget.caseStyle ??
        StackBoardPlusConfig.of(context).caseStyle ??
        const CaseStyle();
  }

  @override
  double getMinSize(BuildContext context) {
    final double buttonSize = _caseStyle(context).buttonStyle.size ?? 24.0;
    return widget.minItemSize ?? buttonSize * 2;
  }

  /// * Main body mouse pointer style
  MouseCursor _cursor(StackItemStatus status) {
    if (status == StackItemStatus.moving) {
      return SystemMouseCursors.grabbing;
    } else if (status == StackItemStatus.editing) {
      return SystemMouseCursors.click;
    }

    return SystemMouseCursors.grab;
  }

  /// Check if the item's parent group is in an active/selected state
  bool _isParentGroupActive(StackItem<StackItemContent> item) {
    if (!controller.isItemInGroup(item.id)) return false;
    final groupId = controller.getGroupForItem(item.id);
    if (groupId == null) return false;
    final group = controller.getGroupById(groupId);
    if (group == null) return false;
    return group.status == StackItemStatus.selected ||
        group.status == StackItemStatus.moving ||
        group.status == StackItemStatus.scaling ||
        group.status == StackItemStatus.resizing ||
        group.status == StackItemStatus.roating;
  }

  /// * Click
  /// Handles two-step selection for grouped items:
  /// - First tap on a grouped item: selects the group
  /// - Second tap on an item within an already selected group: selects that individual item
  void _onTap(BuildContext context) {
    widget.onTap?.call();
    // selectOne now handles the two-step selection logic internally
    controller.selectOne(itemId);
    widget.onStatusChanged?.call(StackItemStatus.selected);
  }

  /// * Long Press - Toggle grouping status
  void _onLongPress(BuildContext context) {
    // If long press grouping is disabled, do nothing
    if (!widget.enableLongPressGrouping) return;

    // For items in a group, toggle grouping on the group itself
    // unless the item is individually selected (group was already selected before)
    if (controller.isItemInGroup(itemId)) {
      final groupId = controller.getGroupForItem(itemId);
      if (groupId != null) {
        final item = controller.getById(itemId);
        // If this individual item is selected (not the group), toggle grouping on the item
        if (item != null && item.status == StackItemStatus.selected) {
          controller.toggleGroupingStatus(itemId);
          widget.onStatusChanged?.call(
            controller.getById(itemId)?.status ?? StackItemStatus.idle,
          );
          return;
        }
        // Otherwise toggle on the group
        controller.toggleGroupingStatus(groupId);
        widget.onStatusChanged?.call(
          controller.getById(groupId)?.status ?? StackItemStatus.idle,
        );
        return;
      }
    }
    // Toggle grouping status
    controller.toggleGroupingStatus(itemId);
    final item = controller.getById(itemId);
    if (item != null) {
      widget.onStatusChanged?.call(item.status);
    }
  }

  /// * Click edit
  void _onEdit(BuildContext context, StackItem item) {
    final status = item.status;
    if (status == StackItemStatus.editing) return;

    final StackBoardPlusController stackController = controller;
    stackController.selectOne(itemId);

    if (item is StackGroupItem) return;
    stackController.setItemStatus(item.id, StackItemStatus.editing);
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
        final double buttonSize = _caseStyle(context).buttonStyle.size ?? 24.0;
        return Positioned(
          key: ValueKey<String>(item.id),
          top: item.offset.dy,
          left: item.offset.dx,
          child: Transform.translate(
            offset: Offset(
              -item.size.width / 2 -
                  (item.status != StackItemStatus.idle ? buttonSize / 2 : 0),
              -item.size.height / 2 -
                  (item.status != StackItemStatus.idle ? buttonSize * 1.5 : 0),
            ),
            child: Transform.rotate(angle: item.angle, child: c),
          ),
        );
      },
      child: ConfigBuilder.withItem(
        itemId,
        shouldRebuild:
            (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
                p.status != n.status ||
                p.size != n.size ||
                p.offset != n.offset ||
                p.opacity != n.opacity ||
                p.angle != n.angle,
        childBuilder: (StackItem<StackItemContent> item, Widget c) {
          // if (item.locked) {
          //   return IgnorePointer(child: _content(context, item));
          // }
          final caseStyle = _caseStyle(context);
          final isGrouping = item.status == StackItemStatus.grouping;
          final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);

          // When requireSelectionForInteraction is enabled and item is idle,
          // don't provide scale handlers so pan/zoom gestures can pass through
          // to InteractiveViewer, while still allowing taps to be detected.
          // However, if the item's parent group is selected, we should handle
          // gestures to allow moving the group by panning on its items.
          final bool isParentGroupActive = _isParentGroupActive(item);
          final bool shouldAllowGesturePassthrough =
              config.requireSelectionForInteraction &&
              item.status == StackItemStatus.idle &&
              !isParentGroupActive;

          Widget content = MouseRegion(
            cursor: _cursor(item.status),
            child: GestureDetector(
              // Use translucent when allowing passthrough, opaque otherwise
              // to ensure proper gesture capture when handling gestures
              behavior: shouldAllowGesturePassthrough
                  ? HitTestBehavior.translucent
                  : HitTestBehavior.opaque,
              onScaleStart: shouldAllowGesturePassthrough
                  ? null
                  : (ScaleStartDetails details) =>
                        onGestureStart(details, context),
              onScaleUpdate: shouldAllowGesturePassthrough
                  ? null
                  : (ScaleUpdateDetails details) =>
                        onGestureUpdate(details, context),
              onScaleEnd: shouldAllowGesturePassthrough
                  ? null
                  : (ScaleEndDetails details) => onGestureEnd(details, context),
              onTap: () => _onTap(context),
              onDoubleTap: () => _onEdit(context, item),
              onLongPress: () => _onLongPress(context),
              child: _childrenStack(context, item),
            ),
          );

          // Apply wiggle animation if item is in grouping status
          if (isGrouping) {
            content = WiggleAnimation(
              config: caseStyle.wiggleAnimationConfig,
              isAnimating: isGrouping,
              child: content,
            );
          }

          return content;
        },
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _childrenStack(
    BuildContext context,
    StackItem<StackItemContent> item,
  ) {
    final CaseStyle style = _caseStyle(context);

    // Check if item is in a selected group - if so, hide borders/handles
    final bool isInSelectedGroup =
        !isGroupItem(item) &&
        controller.isItemInGroup(item.id) &&
        controller
                .getGroupById(controller.getGroupForItem(item.id) ?? '')
                ?.status ==
            StackItemStatus.selected;

    final List<Widget> widgets = <Widget>[_content(context, item)];

    // Show border if not in a selected group, or if in grouping status
    if (!isInSelectedGroup || item.status == StackItemStatus.grouping) {
      widgets.add(
        widget.borderBuilder?.call(item.status) ??
            _frameBorder(context, item.status),
      );
    }

    final double buttonSize = style.buttonStyle.size ?? 24.0;
    final double scaleHandleSize = style.scaleHandleStyle?.size ?? buttonSize;
    final double resizeHandleSize = style.resizeHandleStyle?.size ?? buttonSize;
    final double hitAreaPadding = style.handleHitAreaPadding;

    // The content has a padding of buttonSize/2 on left/right and buttonSize*1.5 on top/bottom
    // We need to align handles with the border which is at:
    // top: buttonSize * 1.5
    // bottom: buttonSize * 1.5
    // left: buttonSize / 2
    // right: buttonSize / 2

    final double topBorder = buttonSize * 1.5;
    final double bottomBorder = buttonSize * 1.5;
    final double leftBorder = buttonSize / 2;
    final double rightBorder = buttonSize / 2;

    // Don't show handles/actions if item is in a selected group (unless grouping)
    if (isInSelectedGroup && item.status != StackItemStatus.grouping) {
      return Stack(children: widgets);
    }

    if (widget.actionsBuilder != null) {
      widgets.add(widget.actionsBuilder!(item.status, _caseStyle(context)));
    } else if (item.status != StackItemStatus.editing) {
      if (item.status != StackItemStatus.idle) {
        // Groups cannot be resized, only scaled
        final bool isGroup = isGroupItem(item);
        if (!isGroup && item.size.height > getMinSize(context) * 2) {
          widgets.add(
            Positioned(
              bottom: bottomBorder - resizeHandleSize / 2 - hitAreaPadding,
              right:
                  rightBorder -
                  resizeHandleSize * 1.5 -
                  hitAreaPadding, // width is size/3
              top: topBorder - resizeHandleSize / 2 - hitAreaPadding,
              child: _buildResizeXHandle(
                context,
                item.status,
                HandlePosition.right,
              ),
            ),
          );
          widgets.add(
            Positioned(
              bottom: bottomBorder - resizeHandleSize / 2 - hitAreaPadding,
              left:
                  leftBorder -
                  resizeHandleSize * 1.5 -
                  hitAreaPadding, // width is size/3
              top: topBorder - resizeHandleSize / 2 - hitAreaPadding,
              child: _buildResizeXHandle(
                context,
                item.status,
                HandlePosition.left,
              ),
            ),
          );
        }
        if (!isGroup && item.size.width > getMinSize(context) * 2) {
          widgets.add(
            Positioned(
              left: leftBorder - resizeHandleSize / 2 - hitAreaPadding,
              top:
                  topBorder -
                  resizeHandleSize * 1.5 -
                  hitAreaPadding, // height is size/3
              right: rightBorder - resizeHandleSize / 2 - hitAreaPadding,
              child: _buildResizeYHandle(
                context,
                item.status,
                HandlePosition.top,
              ),
            ),
          );
          widgets.add(
            Positioned(
              left: leftBorder - resizeHandleSize / 2 - hitAreaPadding,
              bottom:
                  bottomBorder -
                  resizeHandleSize * 1.5 -
                  hitAreaPadding, // height is size/3
              right: rightBorder - resizeHandleSize / 2 - hitAreaPadding,
              child: _buildResizeYHandle(
                context,
                item.status,
                HandlePosition.bottom,
              ),
            ),
          );
        }

        final double scaleHandleOffsetTop =
            topBorder - scaleHandleSize / 2 - hitAreaPadding;
        final double scaleHandleOffsetBottom =
            bottomBorder - scaleHandleSize / 2 - hitAreaPadding;
        final double scaleHandleOffsetLeft =
            leftBorder - scaleHandleSize / 2 - hitAreaPadding;
        final double scaleHandleOffsetRight =
            rightBorder - scaleHandleSize / 2 - hitAreaPadding;

        if (item.size.height > getMinSize(context) &&
            item.size.width > getMinSize(context)) {
          widgets.add(
            Positioned(
              top: scaleHandleOffsetTop,
              right: scaleHandleOffsetRight,
              child: _buildScaleHandle(
                context,
                item.status,
                SystemMouseCursors.resizeUpRightDownLeft,
                HandlePosition.topRight,
              ),
            ),
          );
          widgets.add(
            Positioned(
              bottom: scaleHandleOffsetBottom,
              left: scaleHandleOffsetLeft,
              child: _buildScaleHandle(
                context,
                item.status,
                SystemMouseCursors.resizeUpRightDownLeft,
                HandlePosition.bottomLeft,
              ),
            ),
          );
        }
        widgets.addAll(<Widget>[
          if (style.showHelperButtons)
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
                  onRotateUpdate: (d) =>
                      onRotateUpdate(d, context, item.status),
                  onRotateEnd: (_) => onPanEnd(context, item.status),
                  onMoveStart: (d) =>
                      onPanStart(d, context, StackItemStatus.moving),
                  onMoveUpdate: (d) => onPanUpdate(d, context),
                  onMoveEnd: (_) => onPanEnd(context, item.status),
                ),
              ),
          Positioned(
            top: scaleHandleOffsetTop,
            left: scaleHandleOffsetLeft,
            child: _buildScaleHandle(
              context,
              item.status,
              SystemMouseCursors.resizeUpLeftDownRight,
              HandlePosition.topLeft,
            ),
          ),
          Positioned(
            bottom: scaleHandleOffsetBottom,
            right: scaleHandleOffsetRight,
            child: _buildScaleHandle(
              context,
              item.status,
              SystemMouseCursors.resizeUpLeftDownRight,
              HandlePosition.bottomRight,
            ),
          ),
        ]);
      }
    } else {
      if (style.showHelperButtons) {
        widgets.add(_buildDeleteHandle(context));
      }
    }
    return Stack(children: widgets);
  }

  /// * Child component
  Widget _content(BuildContext context, StackItem<StackItemContent> item) {
    final CaseStyle style = _caseStyle(context);
    final double buttonSize = style.buttonStyle.size ?? 24.0;

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
                  buttonSize / 2,
                  buttonSize * 1.5,
                  buttonSize / 2,
                  buttonSize * 1.5,
                ),
          child: SizedBox.fromSize(size: item.size, child: c),
        );
      },
      child: content,
    );
  }

  /// * Border
  Widget _frameBorder(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);
    final double buttonSize = style.buttonStyle.size ?? 24.0;

    if (status == StackItemStatus.idle) return const SizedBox.shrink();

    // Use different border color for grouping status
    final Color borderColor = status == StackItemStatus.grouping
        ? style.frameBorderColor.withValues(alpha: 0.7)
        : style.frameBorderColor;

    return Positioned(
      top: buttonSize * 1.5,
      bottom: buttonSize * 1.5,
      left: buttonSize / 2,
      right: buttonSize / 2,
      child: IgnorePointer(
        ignoring: true,
        child: style.isFrameDashed
            ? CustomPaint(
                painter: DashedRectPainter(
                  color: borderColor,
                  strokeWidth: style.frameBorderWidth,
                  dashWidth: style.dashWidth,
                  gap: style.dashGap,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: style.frameBorderWidth,
                  ),
                ),
              ),
      ),
    );
  }

  /// * Delete handle
  Widget _buildDeleteHandle(BuildContext context) {
    final CaseStyle style = _caseStyle(context);
    final double buttonSize = style.buttonStyle.size ?? 24.0;

    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onDel?.call(),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.buttonStyle.color ?? Colors.white,
              border: Border.all(
                width: style.buttonStyle.borderWidth ?? 1.0,
                color: style.buttonStyle.borderColor ?? Colors.grey,
              ),
            ),
            child: IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                color: style.buttonStyle.iconColor ?? Colors.grey,
                size: buttonSize * 0.6,
              ),
              child: const Icon(Icons.delete),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScaleHandle(
    BuildContext context,
    StackItemStatus status,
    MouseCursor cursor,
    HandlePosition handle,
  ) {
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
    BuildContext context,
    StackItemStatus status,
    HandlePosition handle,
  ) {
    final CaseStyle style = _caseStyle(context);
    final double size =
        style.resizeHandleStyle?.size ?? style.buttonStyle.size ?? 24.0;
    return ResizeHandle(
      onPanStart: (d) => onPanStart(d, context, StackItemStatus.resizing),
      onPanUpdate: (d) => onResizeUpdate(d, context, status, handle),
      onPanEnd: (_) => onPanEnd(context, status),
      cursor: SystemMouseCursors.resizeColumn,
      caseStyle: style,
      width: size,
      height: size,
    );
  }

  Widget _buildResizeYHandle(
    BuildContext context,
    StackItemStatus status,
    HandlePosition handle,
  ) {
    final CaseStyle style = _caseStyle(context);
    final double size =
        style.resizeHandleStyle?.size ?? style.buttonStyle.size ?? 24.0;
    return ResizeHandle(
      onPanStart: (d) => onPanStart(d, context, StackItemStatus.resizing),
      onPanUpdate: (d) => onResizeUpdate(d, context, status, handle),
      onPanEnd: (_) => onPanEnd(context, status),
      cursor: SystemMouseCursors.resizeRow,
      caseStyle: style,
      width: size,
      height: size,
    );
  }
}
