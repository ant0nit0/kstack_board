import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import '../helpers/snap_calculator.dart';
import '../widgets/snap_guide_provider.dart';
import '../core/snap_config.dart';

enum HandlePosition {
  none,
  topLeft,
  top,
  topRight,
  right,
  bottomRight,
  bottom,
  bottomLeft,
  left,
}

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

  final List<Widget> Function(
          StackItem<StackItemContent> item, BuildContext context)?
      customActionsBuilder; // NEW

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
  bool _wasSnapping = false;

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

  /// * Scale/Rotate gesture start
  void _onGestureStart(ScaleStartDetails details, BuildContext context) {
    final StackBoardPlusController stackController = _controller(context);
    final StackItem<StackItemContent>? item = stackController.getById(itemId);
    if (item == null) return;

    // Determine initial status. Default to moving.
    StackItemStatus newStatus = StackItemStatus.moving;
    // If we are not editing, and not selected, select it.
    if (item.status != StackItemStatus.editing) {
      if (item.status != StackItemStatus.selected) {
        stackController.selectOne(itemId);
      }
      stackController.updateBasic(itemId, status: newStatus);
      stackController.moveItemOnTop(itemId);
      widget.onStatusChanged?.call(newStatus);
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    centerPoint = renderBox.localToGlobal(
        Offset(renderBox.size.width / 2, renderBox.size.height / 2));
    startGlobalPoint = details.focalPoint;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;
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
    centerPoint = renderBox.localToGlobal(
        Offset(renderBox.size.width / 2, renderBox.size.height / 2));
    startGlobalPoint = details.globalPosition;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;
  }

  /// * Drag end
  void _onPanEnd(BuildContext context, StackItemStatus status) {
    // Clear snap guides when dragging ends
    try {
      context.updateSnapGuideLines(<SnapGuideLine>[]);
    } catch (_) {
      // Ignore if context doesn't have snap guide provider
    }

    // Reset snapping state
    _wasSnapping = false;

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

    // We need to transform the delta from local (rotated) coordinates to global coordinates
    final double angle = item.angle;
    final double sina = math.sin(-angle);
    final double cosa = math.cos(-angle);

    Offset d = dud.delta;
    final Offset changeTo = item.offset.translate(d.dx, d.dy);

    // Rotate delta back to global orientation
    // Note: dud.delta is in the rotated local coordinate system because GestureDetector is inside Transform.rotate
    d = Offset(sina * d.dy + cosa * d.dx, cosa * d.dy - sina * d.dx);

    Offset realOffset = item.offset.translate(d.dx, d.dy);

    // Apply snap calculation if available
    try {
      final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
      final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();

      // Check if snap is enabled
      if (!snapConfig.enabled) {
        try {
          context.updateSnapGuideLines(<SnapGuideLine>[]);
        } catch (_) {
          // Ignore
        }
      } else {
        final RenderBox? boardBox =
            context.findAncestorRenderObjectOfType<RenderBox>();
        if (boardBox != null && boardBox.hasSize) {
          final Size boardSize = boardBox.size;
          // Only apply snap if board has valid size
          if (boardSize.width > 0 && boardSize.height > 0) {
            final List<StackItem<StackItemContent>> allItems =
                stackController.innerData;

            final SnapCalculator calculator = SnapCalculator(
              boardSize: boardSize,
              allItems: allItems,
              movingItemId: itemId,
              config: snapConfig,
            );

            final SnapResult snapResult =
                calculator.calculateSnap(realOffset, item.size);
            realOffset = snapResult.offset;

            // Update snap guide lines
            context.updateSnapGuideLines(snapResult.guideLines);

            // Trigger haptic feedback when snapping occurs
            if (snapResult.isSnapped && !_wasSnapping) {
              snapConfig.onSnapHapticFeedback?.call();
            }
            _wasSnapping = snapResult.isSnapped;
          }
        }
      }
    } catch (_) {
      // Ignore if snap guide provider is not available
      try {
        context.updateSnapGuideLines(<SnapGuideLine>[]);
      } catch (_) {
        // Ignore
      }
    }

    if (!(widget.onOffsetChanged?.call(realOffset) ?? true)) return;

    stackController.updateBasic(itemId, offset: realOffset);

    widget.onOffsetChanged?.call(changeTo);
  }

  /// * Scale/Rotate/Move gesture update
  void _onGestureUpdate(ScaleUpdateDetails details, BuildContext context) {
    final StackBoardPlusController stackController = _controller(context);
    final StackItem<StackItemContent>? item = stackController.getById(itemId);
    if (item == null) return;
    if (item.status == StackItemStatus.editing) return;
    if (item.status == StackItemStatus.drawing) return;

    // 1. Calculate New Angle (Rotation)
    double newAngle = startAngle + details.rotation;

    // 2. Calculate New Size (Scale)
    double newScale = details.scale;
    double newWidth = startSize.width * newScale;
    double newHeight = startSize.height * newScale;

    // Enforce min size
    final double minSize = _minSize(context);
    if (newWidth < minSize || newHeight < minSize) {
      // If scaling down too much, clamp scale
      final double scaleW = minSize / startSize.width;
      final double scaleH = minSize / startSize.height;
      newScale = math.max(newScale, math.max(scaleW, scaleH));
      newWidth = startSize.width * newScale;
      newHeight = startSize.height * newScale;
    }
    final Size newSize = Size(newWidth, newHeight);

    // 3. Calculate New Offset (Position)
    // Movement of the focal point
    final Offset delta = details.focalPoint - startGlobalPoint;
    Offset newOffset = startOffset + delta;

    // 4. Apply Snapping (Only if single pointer - drag)
    // Snapping while rotating/scaling with 2 fingers is usually bad UX
    if (details.pointerCount == 1) {
      // Re-use snap logic from _onPanUpdate
      // We need 'realOffset' which is newOffset here.
      Offset realOffset = newOffset;

      try {
        final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
        final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();

        if (!snapConfig.enabled) {
          context.updateSnapGuideLines(<SnapGuideLine>[]);
        } else {
          final RenderBox? boardBox =
              context.findAncestorRenderObjectOfType<RenderBox>();
          if (boardBox != null && boardBox.hasSize) {
            final Size boardSize = boardBox.size;
            if (boardSize.width > 0 && boardSize.height > 0) {
              final List<StackItem<StackItemContent>> allItems =
                  stackController.innerData;

              final SnapCalculator calculator = SnapCalculator(
                boardSize: boardSize,
                allItems: allItems,
                movingItemId: itemId,
                config: snapConfig,
              );

              final SnapResult snapResult =
                  calculator.calculateSnap(realOffset, newSize); // Use newSize
              realOffset = snapResult.offset;

              context.updateSnapGuideLines(snapResult.guideLines);

              if (snapResult.isSnapped && !_wasSnapping) {
                snapConfig.onSnapHapticFeedback?.call();
              }
              _wasSnapping = snapResult.isSnapped;
              newOffset = realOffset;
            }
          }
        }
      } catch (_) {
        try {
          context.updateSnapGuideLines(<SnapGuideLine>[]);
        } catch (_) {}
      }
    } else {
      // Clear guides if multi-touch
      try {
        context.updateSnapGuideLines(<SnapGuideLine>[]);
      } catch (_) {}
    }

    // 5. Update State
    bool shouldUpdate = true;
    if (widget.onAngleChanged != null) {
      shouldUpdate = widget.onAngleChanged!(newAngle) ?? true;
    }
    if (shouldUpdate && widget.onSizeChanged != null) {
      shouldUpdate = widget.onSizeChanged!(newSize) ?? true;
    }
    if (shouldUpdate && widget.onOffsetChanged != null) {
      shouldUpdate = widget.onOffsetChanged!(newOffset) ?? true;
    }

    if (!shouldUpdate) return;

    stackController.updateBasic(itemId,
        angle: newAngle, size: newSize, offset: newOffset);
  }

  /// * Gesture end
  void _onGestureEnd(ScaleEndDetails details, BuildContext context) {
    _onPanEnd(context, StackItemStatus.moving);
  }

  /// * Scale operation
  void _onScaleUpdate(DragUpdateDetails dud, BuildContext context,
      StackItemStatus status, HandlePosition handle) {
    final StackBoardPlusController stackController = _controller(context);
    final StackItem<StackItemContent>? item = stackController.getById(itemId);
    if (item == null) return;

    // 1. Identify Anchor Point (Opposite Corner) in Local Coordinates
    double anchorLocalX = 0;
    double anchorLocalY = 0;
    // Width/Height halves
    final double w2 = startSize.width / 2;
    final double h2 = startSize.height / 2;

    switch (handle) {
      case HandlePosition.topLeft: // Anchor BottomRight
        anchorLocalX = w2;
        anchorLocalY = h2;
        break;
      case HandlePosition.topRight: // Anchor BottomLeft
        anchorLocalX = -w2;
        anchorLocalY = h2;
        break;
      case HandlePosition.bottomLeft: // Anchor TopRight
        anchorLocalX = w2;
        anchorLocalY = -h2;
        break;
      case HandlePosition.bottomRight: // Anchor TopLeft
        anchorLocalX = -w2;
        anchorLocalY = -h2;
        break;
      default:
        return;
    }

    // 2. Calculate Anchor in Global Coordinates
    final double sinA = math.sin(startAngle);
    final double cosA = math.cos(startAngle);

    // Rotate anchor local point
    final double anchorDx = anchorLocalX * cosA - anchorLocalY * sinA;
    final double anchorDy = anchorLocalX * sinA + anchorLocalY * cosA;

    final Offset anchorGlobal = startOffset + Offset(anchorDx, anchorDy);

    // 3. Calculate Distances
    final double distStart = (startGlobalPoint - anchorGlobal).distance;
    final double distCurr = (dud.globalPosition - anchorGlobal).distance;

    // 4. Calculate Scale
    // Prevent division by zero
    if (distStart == 0) return;
    double scale = distCurr / distStart;

    // 5. Calculate New Size
    double newWidth = startSize.width * scale;
    double newHeight = startSize.height * scale;

    // 6. Enforce Min Size
    final double minSize = _minSize(context);
    if (newWidth < minSize || newHeight < minSize) {
      // Clamp scale to meet min size
      final double scaleW = minSize / startSize.width;
      final double scaleH = minSize / startSize.height;
      scale = math.max(scale, math.max(scaleW, scaleH));
      newWidth = startSize.width * scale;
      newHeight = startSize.height * scale;
    }

    final Size newSize = Size(newWidth, newHeight);

    // 7. Calculate New Center
    // The new center is along the line from Anchor to OldCenter, scaled by 'scale'
    // Vector Anchor -> OldCenter
    final Offset anchorToCenterStart = startOffset - anchorGlobal;
    final Offset anchorToCenterNew = anchorToCenterStart * scale;
    final Offset newOffset = anchorGlobal + anchorToCenterNew;

    bool shouldUpdate = true;
    if (widget.onSizeChanged != null) {
      shouldUpdate = widget.onSizeChanged!(newSize) ?? true;
    }
    if (shouldUpdate && widget.onOffsetChanged != null) {
      shouldUpdate = widget.onOffsetChanged!(newOffset) ?? true;
    }

    if (!shouldUpdate) return;

    stackController.updateBasic(itemId, size: newSize, offset: newOffset);
  }

  /// * Resize operation
  void _onResizeUpdate(DragUpdateDetails dud, BuildContext context,
      StackItemStatus status, HandlePosition handle) {
    final StackBoardPlusController stackController = _controller(context);
    final StackItem<StackItemContent>? item = stackController.getById(itemId);
    if (item == null) return;

    final double angle = item.angle;
    final double sinA = math.sin(-angle);
    final double cosA = math.cos(-angle);

    final Offset globalDelta = dud.globalPosition - startGlobalPoint;

    final double localDx = globalDelta.dx * cosA - globalDelta.dy * sinA;
    final double localDy = globalDelta.dx * sinA + globalDelta.dy * cosA;

    double newWidth = startSize.width;
    double newHeight = startSize.height;
    double limitWx = 0;
    double limitHy = 0;

    final double minSize = _minSize(context);

    switch (handle) {
      case HandlePosition.right:
        newWidth = math.max(minSize, startSize.width + localDx);
        limitWx = newWidth - startSize.width;
        break;
      case HandlePosition.left:
        newWidth = math.max(minSize, startSize.width - localDx);
        limitWx = newWidth - startSize.width;
        break;
      case HandlePosition.top:
        newHeight = math.max(minSize, startSize.height - localDy);
        limitHy = newHeight - startSize.height;
        break;
      case HandlePosition.bottom:
        newHeight = math.max(minSize, startSize.height + localDy);
        limitHy = newHeight - startSize.height;
        break;
      default:
        return;
    }

    final Size newSize = Size(newWidth, newHeight);

    double shiftX = 0;
    double shiftY = 0;

    if (handle == HandlePosition.right) {
      shiftX = limitWx / 2;
    } else if (handle == HandlePosition.left) {
      shiftX = -limitWx / 2;
    } else if (handle == HandlePosition.bottom) {
      shiftY = limitHy / 2;
    } else if (handle == HandlePosition.top) {
      shiftY = -limitHy / 2;
    }

    final double sinRad = math.sin(angle);
    final double cosRad = math.cos(angle);

    final double globalShiftX = shiftX * cosRad - shiftY * sinRad;
    final double globalShiftY = shiftX * sinRad + shiftY * cosRad;

    final Offset newOffset = startOffset + Offset(globalShiftX, globalShiftY);

    bool shouldUpdate = true;
    if (widget.onSizeChanged != null) {
      shouldUpdate = widget.onSizeChanged!(newSize) ?? true;
    }
    if (shouldUpdate && widget.onOffsetChanged != null) {
      shouldUpdate = widget.onOffsetChanged!(newOffset) ?? true;
    }

    if (!shouldUpdate) return;

    stackController.updateBasic(itemId, size: newSize, offset: newOffset);
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
              onScaleStart: (ScaleStartDetails details) =>
                  _onGestureStart(details, context),
              onScaleUpdate: (ScaleUpdateDetails details) =>
                  _onGestureUpdate(details, context),
              onScaleEnd: (ScaleEndDetails details) =>
                  _onGestureEnd(details, context),
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
              child:
                  _resizeXHandle(context, item.status, HandlePosition.right)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              top: style.buttonSize,
              child:
                  _resizeXHandle(context, item.status, HandlePosition.left)));
        }
        if (item.size.width > _minSize(context) * 2) {
          widgets.add(Positioned(
              left: 0,
              top: style.buttonSize,
              right: 0,
              child: _resizeYHandle(context, item.status, HandlePosition.top)));
          widgets.add(Positioned(
              left: 0,
              bottom: style.buttonSize,
              right: 0,
              child:
                  _resizeYHandle(context, item.status, HandlePosition.bottom)));
        }
        if (item.size.height > _minSize(context) &&
            item.size.width > _minSize(context)) {
          widgets.add(Positioned(
              top: style.buttonSize,
              right: 0,
              child: _scaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpRightDownLeft,
                  HandlePosition.topRight)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              child: _scaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpRightDownLeft,
                  HandlePosition.bottomLeft)));
        }
        widgets.addAll(<Widget>[
          if (item.status == StackItemStatus.editing)
            _deleteHandle(context)
          else
            _toolsCase(context: context, item: item),
          Positioned(
              top: style.buttonSize,
              left: 0,
              child: _scaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpLeftDownRight,
                  HandlePosition.topLeft)),
          Positioned(
              bottom: style.buttonSize,
              right: 0,
              child: _scaleHandle(
                  context,
                  item.status,
                  SystemMouseCursors.resizeUpLeftDownRight,
                  HandlePosition.bottomRight)),
        ]);
      }
    } else {
      widgets.add(_deleteHandle(context));
    }
    return Stack(children: widgets);
  }

  Widget _toolsCase(
      {required BuildContext context,
      required StackItem<StackItemContent> item}) {
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
            if ((item.size.width + item.size.height < style.buttonSize * 6) ||
                (item is StackDrawItem))
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
                    child:
                        _toolCase(context, style, const Icon(Icons.open_with)),
                  ),
                ),
              ),
            // const SizedBox(width: 8),
          ],
          // Delete handle (always visible)
          if ((item.size.width + item.size.height < style.buttonSize * 6) ==
              false)
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
  Widget _scaleHandle(BuildContext context, StackItemStatus status,
      MouseCursor cursor, HandlePosition handle) {
    final CaseStyle style = _caseStyle(context);

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanStart: (DragStartDetails dud) =>
            _onPanStart(dud, context, StackItemStatus.scaling),
        onPanUpdate: (DragUpdateDetails dud) =>
            _onScaleUpdate(dud, context, status, handle),
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
  Widget _resizeHandle(BuildContext context, StackItemStatus status,
      double width, double height, MouseCursor cursor, HandlePosition handle) {
    final CaseStyle style = _caseStyle(context);
    return Center(
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (DragStartDetails dud) =>
                _onPanStart(dud, context, StackItemStatus.resizing),
            onPanUpdate: (DragUpdateDetails dud) =>
                _onResizeUpdate(dud, context, status, handle),
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
  Widget _resizeXHandle(
      BuildContext context, StackItemStatus status, HandlePosition handle) {
    final CaseStyle style = _caseStyle(context);
    return _resizeHandle(context, status, style.buttonSize / 3,
        style.buttonSize, SystemMouseCursors.resizeColumn, handle);
  }

  /// * Resize Y handle
  Widget _resizeYHandle(
      BuildContext context, StackItemStatus status, HandlePosition handle) {
    final CaseStyle style = _caseStyle(context);
    return _resizeHandle(context, status, style.buttonSize,
        style.buttonSize / 3, SystemMouseCursors.resizeRow, handle);
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
