import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import '../widgets/snap_guide_provider.dart';
import 'stack_item_types.dart';

mixin StackItemGestures<T extends StatefulWidget> on State<T> {
  StackBoardPlusController get controller;
  StackItem<StackItemContent> get stackItem;
  String get itemId => stackItem.id;

  // State variables that need to be managed by the mixin
  Offset centerPoint = Offset.zero;
  Offset startGlobalPoint = Offset.zero;
  Offset startOffset = Offset.zero;
  Size startSize = Size.zero;
  double startAngle = 0;
  bool _wasSnapping = false;
  bool _wasRotationSnapping = false;

  // Callbacks that can be overridden or hooked into
  void onStatusChanged(StackItemStatus status);
  void onOffsetChanged(Offset offset);
  void onSizeChanged(Size size);
  void onAngleChanged(double angle);
  double getMinSize(BuildContext context);

  void onPanStart(DragStartDetails details, BuildContext context,
      StackItemStatus newStatus) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;

    if (item.status != newStatus) {
      if (item.status == StackItemStatus.editing) return;
      if (item.status != StackItemStatus.selected) {
        controller.selectOne(itemId);
      }
      controller.updateBasic(itemId, status: newStatus);
      controller.moveItemOnTop(itemId);
      onStatusChanged(newStatus);
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    centerPoint = renderBox.localToGlobal(
        Offset(renderBox.size.width / 2, renderBox.size.height / 2));
    startGlobalPoint = details.globalPosition;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;
  }

  void onPanEnd(BuildContext context, StackItemStatus status) {
    try {
      context.updateSnapGuideLines(<SnapGuideLine>[]);
    } catch (_) {}

    _wasSnapping = false;
    _wasRotationSnapping = false;

    if (status != StackItemStatus.selected) {
      if (status == StackItemStatus.editing) return;
      status = StackItemStatus.selected;
      controller.updateBasic(itemId, status: status);
      onStatusChanged(status);
    }
  }

  void onPanUpdate(DragUpdateDetails dud, BuildContext context) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;
    if (item.status == StackItemStatus.editing) return;
    if (item.status == StackItemStatus.drawing) return;

    final double angle = item.angle;
    final double sina = math.sin(-angle);
    final double cosa = math.cos(-angle);

    Offset d = dud.delta;
    d = Offset(sina * d.dy + cosa * d.dx, cosa * d.dy - sina * d.dx);

    Offset realOffset = item.offset.translate(d.dx, d.dy);

    _applySnapping(context, realOffset, item.size, (snappedOffset) {
      realOffset = snappedOffset;
    });

    onOffsetChanged(realOffset);
    controller.updateBasic(itemId, offset: realOffset);
  }

  void _applySnapping(BuildContext context, Offset currentOffset,
      Size currentSize, Function(Offset) onSnapped) {
    try {
      final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
      final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();

      if (!snapConfig.enabled) {
        context.updateSnapGuideLines(<SnapGuideLine>[]);
        return;
      }

      final RenderBox? boardBox =
          context.findAncestorRenderObjectOfType<RenderBox>();
      if (boardBox != null && boardBox.hasSize) {
        final Size boardSize = boardBox.size;
        if (boardSize.width > 0 && boardSize.height > 0) {
          final List<StackItem<StackItemContent>> allItems =
              controller.innerData;

          final SnapCalculator calculator = SnapCalculator(
            boardSize: boardSize,
            allItems: allItems,
            movingItemId: itemId,
            config: snapConfig,
          );

          final SnapResult snapResult =
              calculator.calculateSnap(currentOffset, currentSize);

          onSnapped(snapResult.offset);
          context.updateSnapGuideLines(snapResult.guideLines);

          if (snapResult.isSnapped && !_wasSnapping) {
            snapConfig.onSnapHapticFeedback?.call();
          }
          _wasSnapping = snapResult.isSnapped;
        }
      }
    } catch (_) {
      try {
        context.updateSnapGuideLines(<SnapGuideLine>[]);
      } catch (_) {}
    }
  }

  void onScaleUpdate(DragUpdateDetails dud, BuildContext context,
      StackItemStatus status, HandlePosition handle) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;

    double anchorLocalX = 0;
    double anchorLocalY = 0;
    final double w2 = startSize.width / 2;
    final double h2 = startSize.height / 2;

    switch (handle) {
      case HandlePosition.topLeft:
        anchorLocalX = w2;
        anchorLocalY = h2;
        break;
      case HandlePosition.topRight:
        anchorLocalX = -w2;
        anchorLocalY = h2;
        break;
      case HandlePosition.bottomLeft:
        anchorLocalX = w2;
        anchorLocalY = -h2;
        break;
      case HandlePosition.bottomRight:
        anchorLocalX = -w2;
        anchorLocalY = -h2;
        break;
      default:
        return;
    }

    final double sinA = math.sin(startAngle);
    final double cosA = math.cos(startAngle);
    final double anchorDx = anchorLocalX * cosA - anchorLocalY * sinA;
    final double anchorDy = anchorLocalX * sinA + anchorLocalY * cosA;
    final Offset anchorGlobal = startOffset + Offset(anchorDx, anchorDy);

    final double distStart = (startGlobalPoint - anchorGlobal).distance;
    if (distStart == 0) return;

    final Offset vStart = startGlobalPoint - anchorGlobal;
    final Offset vCurr = dud.globalPosition - anchorGlobal;
    final double dot = vCurr.dx * vStart.dx + vCurr.dy * vStart.dy;

    double scale = 0;
    if (dot > 0) {
      scale = dot / (distStart * distStart);
    }

    double newWidth = startSize.width * scale;
    double newHeight = startSize.height * scale;

    final double minSize = getMinSize(context);
    if (newWidth < minSize || newHeight < minSize) {
      final double scaleW = minSize / startSize.width;
      final double scaleH = minSize / startSize.height;
      scale = math.max(scale, math.max(scaleW, scaleH));
      newWidth = startSize.width * scale;
      newHeight = startSize.height * scale;
    }

    final Size newSize = Size(newWidth, newHeight);
    final Offset anchorToCenterStart = startOffset - anchorGlobal;
    final Offset anchorToCenterNew = anchorToCenterStart * scale;
    final Offset newOffset = anchorGlobal + anchorToCenterNew;

    onSizeChanged(newSize);
    onOffsetChanged(newOffset);

    debugPrint('newSize: $newSize');
    debugPrint('newOffset: $newOffset');

    debugPrint('min size: $minSize');

    controller.updateBasic(itemId, size: newSize, offset: newOffset);
  }

  void onResizeUpdate(DragUpdateDetails dud, BuildContext context,
      StackItemStatus status, HandlePosition handle) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
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

    final double minSize = getMinSize(context);

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

    onSizeChanged(newSize);
    onOffsetChanged(newOffset);

    debugPrint('newSize: $newSize');
    debugPrint('newOffset: $newOffset');
    debugPrint('min size: $minSize');

    controller.updateBasic(itemId, size: newSize, offset: newOffset);
  }

  // Helper to snap angle to nearest multiple of snapAngle
  // If the difference is within tolerance, snap it.
  double _snapAngle(
      double angle, RotationSnapConfig snapConfig, BuildContext context) {
    if (!snapConfig.enabled) return angle;

    final double snapIncrement = snapConfig.snapIncrement;
    final double tolerance = snapConfig.tolerance;

    final double remainder = angle % snapIncrement;
    double snapped = angle;
    bool isSnapped = false;

    if (remainder.abs() < tolerance) {
      snapped = angle - remainder;
      isSnapped = true;
    } else if ((remainder - snapIncrement).abs() < tolerance) {
      snapped = angle - remainder + snapIncrement;
      isSnapped = true;
    } else if ((remainder + snapIncrement).abs() < tolerance) {
      snapped = angle - remainder - snapIncrement;
      isSnapped = true;
    }

    if (isSnapped) {
      if (!_wasRotationSnapping) {
        snapConfig.onSnapHapticFeedback?.call();
        _wasRotationSnapping = true;
      }
      return snapped;
    } else {
      _wasRotationSnapping = false;
      return angle;
    }
  }

  void onRotateUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final double startToCenterX = startGlobalPoint.dx - centerPoint.dx;
    final double startToCenterY = startGlobalPoint.dy - centerPoint.dy;
    final double endToCenterX = dud.globalPosition.dx - centerPoint.dx;
    final double endToCenterY = dud.globalPosition.dy - centerPoint.dy;
    final double direct =
        startToCenterX * endToCenterY - startToCenterY * endToCenterX;
    final double startToCenter = math.sqrt(
        math.pow(centerPoint.dx - startGlobalPoint.dx, 2) +
            math.pow(centerPoint.dy - startGlobalPoint.dy, 2));
    final double endToCenter = math.sqrt(
        math.pow(centerPoint.dx - dud.globalPosition.dx, 2) +
            math.pow(centerPoint.dy - dud.globalPosition.dy, 2));
    final double startToEnd = math.sqrt(
        math.pow(startGlobalPoint.dx - dud.globalPosition.dx, 2) +
            math.pow(startGlobalPoint.dy - dud.globalPosition.dy, 2));
    final double cosA = (math.pow(startToCenter, 2) +
            math.pow(endToCenter, 2) -
            math.pow(startToEnd, 2)) /
        (2 * startToCenter * endToCenter);
    double angle = math.acos(cosA);
    if (direct < 0) {
      angle = startAngle - angle;
    } else {
      angle = startAngle + angle;
    }

    // Apply rotation snap
    final RotationSnapConfig? rotationSnapConfig =
        StackBoardPlusConfig.of(context).rotationSnapConfig;
    if (rotationSnapConfig != null) {
      angle = _snapAngle(angle, rotationSnapConfig, context);
    }

    onAngleChanged(angle);
    controller.updateBasic(itemId, angle: angle);
  }

  void onGestureStart(ScaleStartDetails details, BuildContext context) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;

    StackItemStatus newStatus = StackItemStatus.moving;
    if (item.status != StackItemStatus.editing) {
      if (item.status != StackItemStatus.selected) {
        controller.selectOne(itemId);
      }
      controller.updateBasic(itemId, status: newStatus);
      controller.moveItemOnTop(itemId);
      onStatusChanged(newStatus);
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    centerPoint = renderBox.localToGlobal(
        Offset(renderBox.size.width / 2, renderBox.size.height / 2));
    startGlobalPoint = details.focalPoint;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;
  }

  void onGestureUpdate(ScaleUpdateDetails details, BuildContext context) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;
    if (item.status == StackItemStatus.editing) return;
    if (item.status == StackItemStatus.drawing) return;

    double newAngle = startAngle + details.rotation;

    // Snap to 45 degrees (pi/4) if within tolerance
    if (details.pointerCount > 1) {
      final RotationSnapConfig? rotationSnapConfig =
          StackBoardPlusConfig.of(context).rotationSnapConfig;
      if (rotationSnapConfig != null) {
        newAngle = _snapAngle(newAngle, rotationSnapConfig, context);
      }
    }

    double newScale = details.scale;
    double newWidth = startSize.width * newScale;
    double newHeight = startSize.height * newScale;

    final double minSize = getMinSize(context);
    if (newWidth < minSize || newHeight < minSize) {
      final double scaleW = minSize / startSize.width;
      final double scaleH = minSize / startSize.height;
      newScale = math.max(newScale, math.max(scaleW, scaleH));
      newWidth = startSize.width * newScale;
      newHeight = startSize.height * newScale;
    }
    final Size newSize = Size(newWidth, newHeight);

    final Offset delta = details.focalPoint - startGlobalPoint;
    Offset newOffset = startOffset + delta;

    if (details.pointerCount == 1) {
      _applySnapping(context, newOffset, newSize, (snappedOffset) {
        newOffset = snappedOffset;
      });
    } else {
      try {
        context.updateSnapGuideLines(<SnapGuideLine>[]);
      } catch (_) {}
    }

    onAngleChanged(newAngle);
    onSizeChanged(newSize);
    onOffsetChanged(newOffset);

    controller.updateBasic(itemId,
        angle: newAngle, size: newSize, offset: newOffset);
  }

  void onGestureEnd(ScaleEndDetails details, BuildContext context) {
    onPanEnd(context, StackItemStatus.moving);
  }
}
