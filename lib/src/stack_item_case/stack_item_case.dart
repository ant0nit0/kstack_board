import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
// Add this import for the dialog
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

  final List<Widget> Function(StackItem<StackItemContent> item, BuildContext context)? customActionsBuilder; // NEW

  @override
  State<StatefulWidget> createState() {
    return _StackItemCaseState();
  }
}

class _StackItemCaseState extends State<StackItemCase> {
  Offset centerPoint = Offset.zero;
  Offset startGlobalPoint = Offset.zero;
  Offset startOffset = Offset.zero;
  Size startSize = Size.zero;
  double startAngle = 0;

  String get itemId => widget.stackItem.id;

  StackBoardPlusController _controller(BuildContext context) =>
      StackBoardPlusConfig.of(context).controller;

  /// * Outer frame style
  CaseStyle _caseStyle(BuildContext context) =>
      widget.caseStyle ??
      StackBoardPlusConfig.of(context).caseStyle ??
      const CaseStyle();

  double _minSize(BuildContext context) => _caseStyle(context).buttonSize * 2;

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
    _controller(context).selectOne(itemId);
    widget.onStatusChanged?.call(StackItemStatus.selected);
  }

  /// * Click edit
  void _onEdit(BuildContext context, StackItemStatus status) {
    if (status == StackItemStatus.editing) return;

    final StackBoardPlusController stackController = _controller(context);
    status = StackItemStatus.editing;
    stackController.selectOne(itemId);
    stackController.updateBasic(itemId, status: status);
    widget.onStatusChanged?.call(status);
  }

  void _onPanStart(DragStartDetails details, BuildContext context,
      StackItemStatus newStatus) {
    final StackBoardPlusController stackController = _controller(context);
    final StackItem<StackItemContent>? item = stackController.getById(itemId);
    if (item == null) return;

    if (item.status != newStatus) {
      if (item.status == StackItemStatus.editing) return;
      if (item.status != StackItemStatus.selected) {
        stackController.selectOne(itemId);
      }
      stackController.updateBasic(itemId, status: newStatus);
      stackController.moveItemOnTop(itemId);
      widget.onStatusChanged?.call(newStatus);
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    
    // Use the widget's visual center (in global coordinates) as the pivot
    // Use the widget's visual center (in global coordinates) as the pivot
    centerPoint = renderBox
        .localToGlobal(Offset(renderBox.size.width / 2, renderBox.size.height / 2));
    startGlobalPoint = details.globalPosition;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;
  }

  /// * Drag end
  void _onPanEnd(BuildContext context, StackItemStatus status) {
    if (status != StackItemStatus.selected) {
      if (status == StackItemStatus.editing) return;
      status = StackItemStatus.selected;
      _controller(context).updateBasic(itemId, status: status);
      widget.onStatusChanged?.call(status);
    }
  }

  /// * Move operation
  void _onPanUpdate(DragUpdateDetails dud, BuildContext context) {
    final StackBoardPlusController stackController = _controller(context);

    final StackItem<StackItemContent>? item = stackController.getById(itemId);
    if (item == null) return;
    if (item.status == StackItemStatus.editing) return;
    if (item.status == StackItemStatus.drawing) return;
    final double angle = item.angle;
    final double sina = math.sin(-angle);
    final double cosa = math.cos(-angle);

    Offset d = dud.delta;
    final Offset changeTo = item.offset.translate(d.dx, d.dy);

    d = Offset(sina * d.dy + cosa * d.dx, cosa * d.dy - sina * d.dx);

    final Offset realOffset = item.offset.translate(d.dx, d.dy);

    if (!(widget.onOffsetChanged?.call(realOffset) ?? true)) return;

    stackController.updateBasic(itemId, offset: realOffset);

    widget.onOffsetChanged?.call(changeTo);
  }

  static double _caculateDistance(Offset p1, Offset p2) {
    return sqrt(
      (p1.dx - p2.dx) * (p1.dx - p2.dx) + (p1.dy - p2.dy) * (p1.dy - p2.dy),
    );
  }

  /// * Calculate the item size based on the cursor position
  Size _calculateNewSize(DragUpdateDetails dud, BuildContext context,
      final StackItemStatus status) {
    final StackBoardPlusController stackController = _controller(context);

    final StackItem<StackItemContent>? item = stackController.getById(itemId);
    if (item == null) return Size.zero;

    final double minSize = _minSize(context);

    // Compute scale based on distances in the same (global) coordinate space
    final double originalDistance =
        _caculateDistance(startGlobalPoint, centerPoint);
    final double newDistance =
        _caculateDistance(dud.globalPosition, centerPoint);
    final double scale = newDistance / originalDistance;

    final double w = startSize.width * scale;
    final double h = startSize.height * scale;

    if (w < minSize || h < minSize) return item.size;

    return Size(w, h);
  }

  /// * Scale operation
  void _onScaleUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final Size s = _calculateNewSize(dud, context, status);

    if (!(widget.onSizeChanged?.call(s) ?? true)) return;

    _controller(context).updateBasic(itemId, size: s);
  }

  /// * Horizontal resize operation
  void _onResizeXUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final Size newSize = _calculateNewSize(dud, context, status);
    final Size s = Size(newSize.width, startSize.height);

    if (!(widget.onSizeChanged?.call(s) ?? true)) return;

    _controller(context).updateBasic(itemId, size: s);
  }

  /// * Vertical resize operation
  void _onResizeYUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final Size newSize = _calculateNewSize(dud, context, status);
    final Size s = Size(startSize.width, newSize.height);

    if (!(widget.onSizeChanged?.call(s) ?? true)) return;

    _controller(context).updateBasic(itemId, size: s);
  }

  /// * Rotate operation
  void _onRotateUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final double startToCenterX = startGlobalPoint.dx - centerPoint.dx;
    final double startToCenterY = startGlobalPoint.dy - centerPoint.dy;
    final double endToCenterX = dud.globalPosition.dx - centerPoint.dx;
    final double endToCenterY = dud.globalPosition.dy - centerPoint.dy;
    final double direct =
        startToCenterX * endToCenterY - startToCenterY * endToCenterX;
    final double startToCenter = sqrt(
        pow(centerPoint.dx - startGlobalPoint.dx, 2) +
            pow(centerPoint.dy - startGlobalPoint.dy, 2));
    final double endToCenter = sqrt(
        pow(centerPoint.dx - dud.globalPosition.dx, 2) +
            pow(centerPoint.dy - dud.globalPosition.dy, 2));
    final double startToEnd = sqrt(
        pow(startGlobalPoint.dx - dud.globalPosition.dx, 2) +
            pow(startGlobalPoint.dy - dud.globalPosition.dy, 2));
    final double cosA =
        (pow(startToCenter, 2) + pow(endToCenter, 2) - pow(startToEnd, 2)) /
            (2 * startToCenter * endToCenter);
    double angle = acos(cosA);
    if (direct < 0) {
      angle = startAngle - angle;
    } else {
      angle = startAngle + angle;
    }

    if (!(widget.onAngleChanged?.call(angle) ?? true)) return;

    _controller(context).updateBasic(itemId, angle: angle);
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
              onPanStart: (DragStartDetails details) =>
                  _onPanStart(details, context, StackItemStatus.moving),
              onPanUpdate: (DragUpdateDetails dud) =>
                  _onPanUpdate(dud, context),
              onPanEnd: (_) => _onPanEnd(context, item.status),
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
        if (item.size.height > _minSize(context) * 2) {
          widgets.add(Positioned(
              bottom: style.buttonSize,
              right: 0,
              top: style.buttonSize,
              child: _resizeXHandle(context, item.status)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              top: style.buttonSize,
              child: _resizeXHandle(context, item.status)));
        }
        if (item.size.width > _minSize(context) * 2) {
          widgets.add(Positioned(
              left: 0,
              top: style.buttonSize,
              right: 0,
              child: _resizeYHandle(context, item.status)));
          widgets.add(Positioned(
              left: 0,
              bottom: style.buttonSize,
              right: 0,
              child: _resizeYHandle(context, item.status)));
        }
        if (item.size.height > _minSize(context) &&
            item.size.width > _minSize(context)) {
          widgets.add(Positioned(
              top: style.buttonSize,
              right: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpRightDownLeft)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpRightDownLeft)));
        }
        widgets.addAll(<Widget>[
          if (item.status == StackItemStatus.editing)
            _deleteHandle(context)
          else
            _toolsCase(context: context, item: item),
          Positioned(
              top: style.buttonSize,
              left: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpLeftDownRight)),
          Positioned(
              bottom: style.buttonSize,
              right: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpLeftDownRight)),
        ]);
      }
    } else {
      widgets.add(_deleteHandle(context));
    }
    return Stack(children: widgets);
  }
  Widget _toolsCase({required BuildContext context, required StackItem<StackItemContent> item}) {
    final CaseStyle style = _caseStyle(context);
    return Positioned(
      top: -style.buttonSize * 0.1, 
      left: 0,
      right: 0,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          // Inject user-defined custom actions (if any) using the helper
          ...StackItemActionHelper.buildCustomActions(
            item: item,
            context: context,
            customActionsBuilder: widget.customActionsBuilder,
            caseStyle: style,
          ),
          // Only show rotate handle when not in editing mode
          if (item.status != StackItemStatus.editing) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (DragStartDetails dud) =>
                    _onPanStart(dud, context, StackItemStatus.roating),
                onPanUpdate: (DragUpdateDetails dud) =>
                    _onRotateUpdate(dud, context, item.status),
                onPanEnd: (_) => _onPanEnd(context, item.status),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: _toolCase(
                    context,
                    style,
                    const Icon(Icons.sync),
                  ),
                ),
              ),
            ),
            // const SizedBox(width: 8), 
            // Move handle for small items
            if ((item.size.width + item.size.height < style.buttonSize * 6 ) || (item is StackDrawItem))
              MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (DragStartDetails details) =>
                      _onPanStart(details, context, StackItemStatus.moving),
                  onPanUpdate: (DragUpdateDetails dud) =>
                      _onPanUpdate(dud, context),
                  onPanEnd: (_) => _onPanEnd(context, item.status),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: _toolCase(context, style, const Icon(Icons.open_with)),
                  ),
                ),
              ),
            // const SizedBox(width: 8),
          ],
          // Delete handle (always visible)
          if ((item.size.width + item.size.height < style.buttonSize * 6) == false)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                widget.onDel?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(4), 
                child: _toolCase(context, style, const Icon(Icons.delete)),
              ),
            ),
          ),
        ],
      ),
    );
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
  Widget _deleteHandle(BuildContext context) {
    final CaseStyle style = _caseStyle(context);

    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onDel?.call(),
          child: _toolCase(context, style, const Icon(Icons.delete)),
        ),
      ),
    );
  }

  /// * Scale handle
  Widget _scaleHandle(
      BuildContext context, StackItemStatus status, MouseCursor cursor) {
    final CaseStyle style = _caseStyle(context);

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanStart: (DragStartDetails dud) =>
            _onPanStart(dud, context, StackItemStatus.scaling),
        onPanUpdate: (DragUpdateDetails dud) =>
            _onScaleUpdate(dud, context, status),
        onPanEnd: (_) => _onPanEnd(context, status),
        child: _toolCase(
          context,
          style,
          null,
        ),
      ),
    );
  }

  /// * Resize handle
  Widget _resizeHandle(
      BuildContext context,
      StackItemStatus status,
      double width,
      double height,
      MouseCursor cursor,
      Function(DragUpdateDetails, BuildContext, StackItemStatus) onPanUpdate) {
    final CaseStyle style = _caseStyle(context);
    return Center(
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (DragStartDetails dud) =>
                _onPanStart(dud, context, StackItemStatus.resizing),
            onPanUpdate: (DragUpdateDetails dud) =>
                onPanUpdate(dud, context, status),
            onPanEnd: (_) => _onPanEnd(context, status),
            child: SizedBox(
                width: width * 3,
                height: height * 3,
                child: Center(
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: style.buttonBgColor,
                      border: Border.all(
                          width: style.buttonBorderWidth,
                          color: style.buttonBorderColor),
                      borderRadius: BorderRadius.circular(style.buttonSize),
                    ),
                  ),
                ))),
      ),
    );
  }

  /// * Resize X handle
  Widget _resizeXHandle(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);
    return _resizeHandle(context, status, style.buttonSize / 3,
        style.buttonSize, SystemMouseCursors.resizeColumn, _onResizeXUpdate);
  }

  /// * Resize Y handle
  Widget _resizeYHandle(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);
    return _resizeHandle(context, status, style.buttonSize,
        style.buttonSize / 3, SystemMouseCursors.resizeRow, _onResizeYUpdate);
  }

  /// * Rotate handle
  /// * Deprecated
  // Widget _rotateAndMoveHandle(BuildContext context, StackItemStatus status,
  //     StackItem<StackItemContent> item) {
  //   final CaseStyle style = _caseStyle(context);

  //   return Positioned(
  //     bottom: 0,
  //     right: 0,
  //     left: 0,
  //     child: MouseRegion(
  //       cursor: SystemMouseCursors.click,
  //       child:
  //           Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
  //         GestureDetector(
  //           onPanStart: (DragStartDetails dud) =>
  //               _onPanStart(dud, context, StackItemStatus.roating),
  //           onPanUpdate: (DragUpdateDetails dud) =>
  //               _onRotateUpdate(dud, context, status),
  //           onPanEnd: (_) => _onPanEnd(context, status),
  //           child: _toolCase(
  //             context,
  //             style,
  //             const Icon(Icons.sync),
  //           ),
  //         ),
  //         if (item.size.width + item.size.height < style.buttonSize * 6)
  //           Padding(
  //             padding: EdgeInsets.only(left: style.buttonSize / 2),
  //             child: GestureDetector(
  //               onPanStart: (DragStartDetails details) =>
  //                   _onPanStart(details, context, StackItemStatus.moving),
  //               onPanUpdate: (DragUpdateDetails dud) =>
  //                   _onPanUpdate(dud, context),
  //               onPanEnd: (_) => _onPanEnd(context, status),
  //               child: _toolCase(context, style, const Icon(Icons.open_with)),
  //             ),
  //           )
  //       ]),
  //     ),
  //   );
  // }

  /// * Operation handle shell
  Widget _toolCase(BuildContext context, CaseStyle style, Widget? child) {
    return Container(
      width: style.buttonSize,
      height: style.buttonSize,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: style.buttonBgColor,
          border: Border.all(
              width: style.buttonBorderWidth, color: style.buttonBorderColor)),
      child: child == null
          ? null
          : IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                    color: style.buttonIconColor,
                    size: style.buttonSize * 0.6,
                  ),
              child: child,
            ),
    );
  }

}

// Enum for item types
enum StackItemType {
  drawing,
  text,
  image,
  all,
}

// Helper to get item type
StackItemType getItemType(StackItem<StackItemContent> item) {
  final type = item.runtimeType.toString();
  if (type == 'StackDrawItem') return StackItemType.drawing;
  if (type == 'StackTextItem') return StackItemType.text;
  if (type == 'StackImageItem') return StackItemType.image;
  return StackItemType.all;
}
