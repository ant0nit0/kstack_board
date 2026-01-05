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

  // Cached snap points for performance optimization
  List<SnapPoint>? _cachedHorizontalSnaps;
  List<SnapPoint>? _cachedVerticalSnaps;
  Size? _cachedBoardSize;
  Size? _cachedItemSize;
  SnapConfig? _cachedSnapConfig;

  // Callbacks that can be overridden or hooked into
  void onStatusChanged(StackItemStatus status);
  void onOffsetChanged(Offset offset);
  void onSizeChanged(Size size);
  void onAngleChanged(double angle);
  double getMinSize(BuildContext context);

  /// Check if item is in a group and that group is selected
  bool _isItemInSelectedGroup(StackItem<StackItemContent> item) {
    if (!controller.isItemInGroup(item.id)) return false;
    final groupId = controller.getGroupForItem(item.id);
    if (groupId == null) return false;
    final group = controller.getGroupById(groupId);
    return group?.status == StackItemStatus.selected;
  }

  void onPanStart(
    DragStartDetails details,
    BuildContext context,
    StackItemStatus newStatus,
  ) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;

    if (item.locked) return;

    // Commit state before starting gesture
    controller.commit();

    if (item.status != newStatus) {
      if (item.status == StackItemStatus.editing) return;
      if (item.status != StackItemStatus.selected) {
        controller.selectOne(itemId, addToHistory: false);
      }
      controller.updateBasic(itemId, status: newStatus, addToHistory: false);
      controller.moveItemOnTop(itemId, addToHistory: false);
      onStatusChanged(newStatus);
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    centerPoint = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );
    startGlobalPoint = details.globalPosition;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;

    // Cache snap points when drag starts
    _cacheSnapPoints(context, item.size);
  }

  void onPanEnd(BuildContext context, StackItemStatus status) {
    try {
      context.updateSnapGuideLines(<SnapGuideLine>[]);
    } catch (_) {}

    _wasSnapping = false;
    _wasRotationSnapping = false;

    // Clear cached snap points when drag ends
    _clearSnapCache();

    if (status != StackItemStatus.selected) {
      if (status == StackItemStatus.editing) return;
      status = StackItemStatus.selected;
      controller.updateBasic(itemId, status: status, addToHistory: false);
      onStatusChanged(status);
    }
  }

  void onPanUpdate(DragUpdateDetails dud, BuildContext context) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;
    if (item.status == StackItemStatus.editing) return;
    if (item.status == StackItemStatus.drawing) return;
    if (item.locked) return;
    // Prevent individual item manipulation when in a selected group
    if (_isItemInSelectedGroup(item)) return;

    final double angle = item.angle;
    final double sina = math.sin(-angle);
    final double cosa = math.cos(-angle);

    final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);

    double zoom = config.zoomLevel ?? 1;
    if (zoom < 1) zoom = 1;
    final double fittedBoxScale = config.fittedBoxScale ?? 1;

    Offset d = Offset(
      dud.delta.dx / zoom * fittedBoxScale,
      dud.delta.dy / zoom * fittedBoxScale,
    );

    d = Offset(sina * d.dy + cosa * d.dx, cosa * d.dy - sina * d.dx);

    Offset realOffset = item.offset.translate(d.dx, d.dy);

    _applySnapping(context, realOffset, item.size, (snappedOffset) {
      realOffset = snappedOffset;
    });

    onOffsetChanged(realOffset);
    controller.updateBasic(itemId, offset: realOffset, addToHistory: false);
  }

  /// Cache snap points to avoid recalculating them on every pan update
  void _cacheSnapPoints(BuildContext context, Size itemSize) {
    try {
      final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
      final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();

      if (!snapConfig.enabled) {
        _clearSnapCache();
        return;
      }

      final RenderBox? boardBox = context
          .findAncestorRenderObjectOfType<RenderBox>();
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

          // Cache snap points and related data
          _cachedHorizontalSnaps = calculator.getHorizontalSnapPoints(itemSize);
          _cachedVerticalSnaps = calculator.getVerticalSnapPoints(itemSize);
          _cachedBoardSize = boardSize;
          _cachedItemSize = itemSize;
          _cachedSnapConfig = snapConfig;
        }
      }
    } catch (_) {
      _clearSnapCache();
    }
  }

  /// Clear cached snap points
  void _clearSnapCache() {
    _cachedHorizontalSnaps = null;
    _cachedVerticalSnaps = null;
    _cachedBoardSize = null;
    _cachedItemSize = null;
    _cachedSnapConfig = null;
  }

  /// Check if cached snap points are still valid
  bool _isSnapCacheValid(BuildContext context, Size currentSize) {
    if (_cachedHorizontalSnaps == null ||
        _cachedVerticalSnaps == null ||
        _cachedBoardSize == null ||
        _cachedSnapConfig == null) {
      return false;
    }

    // Check if snap config changed
    final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
    final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();
    if (_cachedSnapConfig != snapConfig) {
      return false;
    }

    // Check if board size changed
    final RenderBox? boardBox = context
        .findAncestorRenderObjectOfType<RenderBox>();
    if (boardBox == null || !boardBox.hasSize) {
      return false;
    }
    final Size boardSize = boardBox.size;
    if (_cachedBoardSize != boardSize) {
      return false;
    }

    // Check if item size changed significantly (snap points depend on item size for grid calculations)
    // We allow small differences to avoid recalculating on minor size changes
    if (_cachedItemSize != null) {
      const double sizeTolerance = 0.1;
      if ((_cachedItemSize!.width - currentSize.width).abs() > sizeTolerance ||
          (_cachedItemSize!.height - currentSize.height).abs() >
              sizeTolerance) {
        return false;
      }
    }

    return true;
  }

  void _applySnapping(
    BuildContext context,
    Offset currentOffset,
    Size currentSize,
    Function(Offset) onSnapped,
  ) {
    try {
      final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
      final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();

      if (!snapConfig.enabled) {
        context.updateSnapGuideLines(<SnapGuideLine>[]);
        return;
      }

      final RenderBox? boardBox = context
          .findAncestorRenderObjectOfType<RenderBox>();
      if (boardBox != null && boardBox.hasSize) {
        final Size boardSize = boardBox.size;
        if (boardSize.width > 0 && boardSize.height > 0) {
          // Use cached snap points if available and valid
          List<SnapPoint> horizontalSnaps;
          List<SnapPoint> verticalSnaps;

          if (_isSnapCacheValid(context, currentSize) &&
              _cachedHorizontalSnaps != null &&
              _cachedVerticalSnaps != null &&
              _cachedBoardSize != null) {
            // Use cached snap points
            horizontalSnaps = _cachedHorizontalSnaps!;
            verticalSnaps = _cachedVerticalSnaps!;
          } else {
            // Recalculate and cache snap points
            final List<StackItem<StackItemContent>> allItems =
                controller.innerData;

            final SnapCalculator calculator = SnapCalculator(
              boardSize: boardSize,
              allItems: allItems,
              movingItemId: itemId,
              config: snapConfig,
            );

            horizontalSnaps = calculator.getHorizontalSnapPoints(currentSize);
            verticalSnaps = calculator.getVerticalSnapPoints(currentSize);

            // Update cache
            _cachedHorizontalSnaps = horizontalSnaps;
            _cachedVerticalSnaps = verticalSnaps;
            _cachedBoardSize = boardSize;
            _cachedItemSize = currentSize;
            _cachedSnapConfig = snapConfig;
          }

          // Calculate snap result using cached or fresh snap points
          final SnapResult snapResult = _calculateSnapWithPoints(
            currentOffset,
            currentSize,
            horizontalSnaps,
            verticalSnaps,
            boardSize,
            snapConfig,
          );

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

  /// Calculate snap result using pre-computed snap points
  SnapResult _calculateSnapWithPoints(
    Offset currentOffset,
    Size itemSize,
    List<SnapPoint> horizontalSnaps,
    List<SnapPoint> verticalSnaps,
    Size boardSize,
    SnapConfig snapConfig,
  ) {
    final List<SnapGuideLine> guideLines = <SnapGuideLine>[];

    // Calculate item edges in global coordinates
    final double itemLeft = currentOffset.dx - itemSize.width / 2;
    final double itemRight = currentOffset.dx + itemSize.width / 2;
    final double itemTop = currentOffset.dy - itemSize.height / 2;
    final double itemBottom = currentOffset.dy + itemSize.height / 2;

    // Find nearest horizontal snap (for vertical alignment)
    double snappedY = currentOffset.dy;
    SnapPoint? nearestVerticalSnap;
    double minVerticalDistance = double.infinity;

    for (final SnapPoint snap in verticalSnaps) {
      // Check if item's top edge should snap
      final double topDistance = (itemTop - snap.position).abs();
      if (topDistance < snapConfig.snapThreshold &&
          topDistance < minVerticalDistance) {
        minVerticalDistance = topDistance;
        nearestVerticalSnap = snap;
        snappedY = snap.position + itemSize.height / 2;
      }

      // Check if item's bottom edge should snap
      final double bottomDistance = (itemBottom - snap.position).abs();
      if (bottomDistance < snapConfig.snapThreshold &&
          bottomDistance < minVerticalDistance) {
        minVerticalDistance = bottomDistance;
        nearestVerticalSnap = snap;
        snappedY = snap.position - itemSize.height / 2;
      }

      // Check if item's center should snap
      final double centerDistance = (currentOffset.dy - snap.position).abs();
      if (centerDistance < snapConfig.snapThreshold &&
          centerDistance < minVerticalDistance) {
        minVerticalDistance = centerDistance;
        nearestVerticalSnap = snap;
        snappedY = snap.position;
      }
    }

    // Find nearest horizontal snap (for horizontal alignment)
    double snappedX = currentOffset.dx;
    SnapPoint? nearestHorizontalSnap;
    double minHorizontalDistance = double.infinity;

    for (final SnapPoint snap in horizontalSnaps) {
      // Check if item's left edge should snap
      final double leftDistance = (itemLeft - snap.position).abs();
      if (leftDistance < snapConfig.snapThreshold &&
          leftDistance < minHorizontalDistance) {
        minHorizontalDistance = leftDistance;
        nearestHorizontalSnap = snap;
        snappedX = snap.position + itemSize.width / 2;
      }

      // Check if item's right edge should snap
      final double rightDistance = (itemRight - snap.position).abs();
      if (rightDistance < snapConfig.snapThreshold &&
          rightDistance < minHorizontalDistance) {
        minHorizontalDistance = rightDistance;
        nearestHorizontalSnap = snap;
        snappedX = snap.position - itemSize.width / 2;
      }

      // Check if item's center should snap
      final double centerDistance = (currentOffset.dx - snap.position).abs();
      if (centerDistance < snapConfig.snapThreshold &&
          centerDistance < minHorizontalDistance) {
        minHorizontalDistance = centerDistance;
        nearestHorizontalSnap = snap;
        snappedX = snap.position;
      }
    }

    // Create guide lines if snapping occurred
    if (nearestVerticalSnap != null) {
      guideLines.add(
        SnapGuideLine(
          start: Offset(0, nearestVerticalSnap.position),
          end: Offset(boardSize.width, nearestVerticalSnap.position),
          orientation: LineOrientation.horizontal,
        ),
      );
    }

    if (nearestHorizontalSnap != null) {
      guideLines.add(
        SnapGuideLine(
          start: Offset(nearestHorizontalSnap.position, 0),
          end: Offset(nearestHorizontalSnap.position, boardSize.height),
          orientation: LineOrientation.vertical,
        ),
      );
    }

    return SnapResult(
      offset: Offset(snappedX, snappedY),
      guideLines: guideLines,
    );
  }

  void onScaleUpdate(
    DragUpdateDetails dud,
    BuildContext context,
    StackItemStatus status,
    HandlePosition handle,
  ) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;
    if (item.locked) return;
    // Groups can be scaled, but individual items in selected groups cannot
    if (!isGroupItem(item) && _isItemInSelectedGroup(item)) return;

    // Anchor is the opposite corner of the handle being dragged
    double anchorLocalX = 0;
    double anchorLocalY = 0;
    final double w2 = startSize.width / 2;
    final double h2 = startSize.height / 2;

    // Direction multipliers: determines which direction increases scale
    // For bottomRight: dragging right (+X) or down (+Y) should increase scale
    // For topLeft: dragging left (-X) or up (-Y) should increase scale
    double dirX = 1;
    double dirY = 1;

    switch (handle) {
      case HandlePosition.topLeft:
        anchorLocalX = w2;
        anchorLocalY = h2;
        dirX = -1; // dragging left increases scale
        dirY = -1; // dragging up increases scale
        break;
      case HandlePosition.topRight:
        anchorLocalX = -w2;
        anchorLocalY = h2;
        dirX = 1; // dragging right increases scale
        dirY = -1; // dragging up increases scale
        break;
      case HandlePosition.bottomLeft:
        anchorLocalX = w2;
        anchorLocalY = -h2;
        dirX = -1; // dragging left increases scale
        dirY = 1; // dragging down increases scale
        break;
      case HandlePosition.bottomRight:
        anchorLocalX = -w2;
        anchorLocalY = -h2;
        dirX = 1; // dragging right increases scale
        dirY = 1; // dragging down increases scale
        break;
      default:
        return;
    }

    final double sinA = math.sin(startAngle);
    final double cosA = math.cos(startAngle);
    final double anchorDx = anchorLocalX * cosA - anchorLocalY * sinA;
    final double anchorDy = anchorLocalX * sinA + anchorLocalY * cosA;
    final Offset anchorGlobal = startOffset + Offset(anchorDx, anchorDy);

    // Calculate the global delta from start position to current position
    final Offset globalDelta = dud.globalPosition - startGlobalPoint;

    // Transform global delta to local (unrotated) coordinates
    // Using inverse rotation: rotate by -startAngle
    final double localDeltaX = globalDelta.dx * cosA + globalDelta.dy * sinA;
    final double localDeltaY = -globalDelta.dx * sinA + globalDelta.dy * cosA;

    // Calculate scale contribution from each axis
    // Apply direction multipliers so that the correct direction increases scale
    final double deltaX = localDeltaX * dirX;
    final double deltaY = localDeltaY * dirY;

    // The initial distance from anchor to handle in local coordinates is the full diagonal
    // which equals sqrt(width^2 + height^2)
    // But we want uniform scaling based on both axes contributing equally
    // So we calculate scale based on how much each axis has moved relative to its dimension

    // Scale contribution from X axis: how much the width should change
    final double scaleFromX = 1.0 + (deltaX / startSize.width);
    // Scale contribution from Y axis: how much the height should change
    final double scaleFromY = 1.0 + (deltaY / startSize.height);

    // Average the two scale contributions for uniform scaling
    // This ensures that dragging 100px right has the same effect as dragging 100px down
    // (proportional to their respective dimensions)
    double scale = (scaleFromX + scaleFromY) / 2.0;

    // Ensure scale doesn't go negative
    if (scale <= 0.01) {
      scale = 0.01;
    }

    // Apply Snapping
    final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
    final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();
    final List<SnapGuideLine> guideLines = <SnapGuideLine>[];

    if (snapConfig.enabled && snapConfig.snapToScale) {
      final RenderBox? boardBox = context
          .findAncestorRenderObjectOfType<RenderBox>();
      if (boardBox != null && boardBox.hasSize) {
        final SnapCalculator calculator = SnapCalculator(
          boardSize: boardBox.size,
          allItems: controller.innerData,
          movingItemId: itemId,
          config: snapConfig,
        );

        // Candidate size
        final double candidateWidth = startSize.width * scale;
        final double candidateHeight = startSize.height * scale;

        // Check horizontal snaps
        final List<SnapPoint> hSnaps = calculator.getHorizontalSnapPoints(
          Size(candidateWidth, candidateHeight),
        );

        double? scaleX;
        SnapPoint? snapX;

        double fixedX;
        double movingX;

        if (handle == HandlePosition.topRight ||
            handle == HandlePosition.bottomRight) {
          fixedX = startOffset.dx - startSize.width / 2;
          movingX = fixedX + candidateWidth;
          snapX = calculator.checkSnap(movingX, hSnaps);
          if (snapX != null) {
            final double targetWidth = snapX.position - fixedX;
            scaleX = targetWidth / startSize.width;
          }
        } else {
          fixedX = startOffset.dx + startSize.width / 2;
          movingX = fixedX - candidateWidth;
          snapX = calculator.checkSnap(movingX, hSnaps);
          if (snapX != null) {
            final double targetWidth = fixedX - snapX.position;
            scaleX = targetWidth / startSize.width;
          }
        }

        // Check vertical snaps
        final List<SnapPoint> vSnaps = calculator.getVerticalSnapPoints(
          Size(candidateWidth, candidateHeight),
        );

        double? scaleY;
        SnapPoint? snapY;

        double fixedY;
        double movingY;

        if (handle == HandlePosition.bottomLeft ||
            handle == HandlePosition.bottomRight) {
          fixedY = startOffset.dy - startSize.height / 2;
          movingY = fixedY + candidateHeight;
          snapY = calculator.checkSnap(movingY, vSnaps);
          if (snapY != null) {
            final double targetHeight = snapY.position - fixedY;
            scaleY = targetHeight / startSize.height;
          }
        } else {
          fixedY = startOffset.dy + startSize.height / 2;
          movingY = fixedY - candidateHeight;
          snapY = calculator.checkSnap(movingY, vSnaps);
          if (snapY != null) {
            final double targetHeight = fixedY - snapY.position;
            scaleY = targetHeight / startSize.height;
          }
        }

        double? bestScale;
        if (scaleX != null && scaleY != null) {
          if ((scale - scaleX).abs() < (scale - scaleY).abs()) {
            bestScale = scaleX;
            if (snapX != null) {
              guideLines.add(
                SnapGuideLine(
                  start: Offset(snapX.position, 0),
                  end: Offset(snapX.position, boardBox.size.height),
                  orientation: LineOrientation.vertical,
                ),
              );
            }
          } else {
            bestScale = scaleY;
            if (snapY != null) {
              guideLines.add(
                SnapGuideLine(
                  start: Offset(0, snapY.position),
                  end: Offset(boardBox.size.width, snapY.position),
                  orientation: LineOrientation.horizontal,
                ),
              );
            }
          }
        } else if (scaleX != null) {
          bestScale = scaleX;
          if (snapX != null) {
            guideLines.add(
              SnapGuideLine(
                start: Offset(snapX.position, 0),
                end: Offset(snapX.position, boardBox.size.height),
                orientation: LineOrientation.vertical,
              ),
            );
          }
        } else if (scaleY != null) {
          bestScale = scaleY;
          if (snapY != null) {
            guideLines.add(
              SnapGuideLine(
                start: Offset(0, snapY.position),
                end: Offset(boardBox.size.width, snapY.position),
                orientation: LineOrientation.horizontal,
              ),
            );
          }
        }

        if (bestScale != null) {
          scale = bestScale;
        }

        if (guideLines.isNotEmpty && !_wasSnapping) {
          snapConfig.onSnapHapticFeedback?.call();
        }
        _wasSnapping = guideLines.isNotEmpty;
      }
    } else {
      _wasSnapping = false;
    }

    try {
      context.updateSnapGuideLines(guideLines);
    } catch (_) {}

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

    controller.updateBasic(
      itemId,
      size: newSize,
      offset: newOffset,
      addToHistory: false,
    );
  }

  void onResizeUpdate(
    DragUpdateDetails dud,
    BuildContext context,
    StackItemStatus status,
    HandlePosition handle,
  ) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;
    if (item.locked) return;
    // Groups cannot be resized (only scaled)
    if (isGroupItem(item)) return;
    // Individual items in selected groups cannot be resized
    if (_isItemInSelectedGroup(item)) return;

    final double angle = item.angle;
    final double sinA = math.sin(-angle);
    final double cosA = math.cos(-angle);

    final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
    double zoom = config.zoomLevel ?? 1;
    if (zoom < 1) zoom = 1;

    final double fittedBoxScale = config.fittedBoxScale ?? 1;

    final Offset globalDelta =
        (dud.globalPosition - startGlobalPoint) / zoom * fittedBoxScale;
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
        break;
      case HandlePosition.left:
        newWidth = math.max(minSize, startSize.width - localDx);
        break;
      case HandlePosition.top:
        newHeight = math.max(minSize, startSize.height - localDy);
        break;
      case HandlePosition.bottom:
        newHeight = math.max(minSize, startSize.height + localDy);
        break;
      default:
        return;
    }

    // Apply Snapping
    final SnapConfig snapConfig = config.snapConfig ?? const SnapConfig();
    final List<SnapGuideLine> guideLines = <SnapGuideLine>[];

    if (snapConfig.enabled && snapConfig.snapToResize) {
      final RenderBox? boardBox = context
          .findAncestorRenderObjectOfType<RenderBox>();
      if (boardBox != null && boardBox.hasSize) {
        final SnapCalculator calculator = SnapCalculator(
          boardSize: boardBox.size,
          allItems: controller.innerData,
          movingItemId: itemId,
          config: snapConfig,
        );

        // Horizontal snaps (Vertical lines) - affects Width/X
        if (handle == HandlePosition.left || handle == HandlePosition.right) {
          final List<SnapPoint> hSnaps = calculator.getHorizontalSnapPoints(
            Size(newWidth, newHeight),
          );
          SnapPoint? snap;

          if (handle == HandlePosition.right) {
            // Snap Right Edge
            // Unrotated Right Edge X = startOffset.dx - startSize.width/2 + newWidth
            // (assuming anchor is left edge)
            final double fixedLeft = startOffset.dx - startSize.width / 2;
            final double movingRight = fixedLeft + newWidth;
            snap = calculator.checkSnap(movingRight, hSnaps);
            if (snap != null) {
              newWidth = snap.position - fixedLeft;
              guideLines.add(
                SnapGuideLine(
                  start: Offset(snap.position, 0),
                  end: Offset(snap.position, boardBox.size.height),
                  orientation: LineOrientation.vertical,
                ),
              );
            }
          } else {
            // Snap Left Edge
            // Right Edge (Fixed) = startOffset.dx + startSize.width/2
            final double fixedRight = startOffset.dx + startSize.width / 2;
            final double movingLeft = fixedRight - newWidth;
            snap = calculator.checkSnap(movingLeft, hSnaps);
            if (snap != null) {
              newWidth = fixedRight - snap.position;
              guideLines.add(
                SnapGuideLine(
                  start: Offset(snap.position, 0),
                  end: Offset(snap.position, boardBox.size.height),
                  orientation: LineOrientation.vertical,
                ),
              );
            }
          }
          if (newWidth < minSize) newWidth = minSize;
        }

        // Vertical snaps (Horizontal lines) - affects Height/Y
        if (handle == HandlePosition.top || handle == HandlePosition.bottom) {
          final List<SnapPoint> vSnaps = calculator.getVerticalSnapPoints(
            Size(newWidth, newHeight),
          );
          SnapPoint? snap;

          if (handle == HandlePosition.bottom) {
            final double fixedTop = startOffset.dy - startSize.height / 2;
            final double movingBottom = fixedTop + newHeight;
            snap = calculator.checkSnap(movingBottom, vSnaps);
            if (snap != null) {
              newHeight = snap.position - fixedTop;
              guideLines.add(
                SnapGuideLine(
                  start: Offset(0, snap.position),
                  end: Offset(boardBox.size.width, snap.position),
                  orientation: LineOrientation.horizontal,
                ),
              );
            }
          } else {
            final double fixedBottom = startOffset.dy + startSize.height / 2;
            final double movingTop = fixedBottom - newHeight;
            snap = calculator.checkSnap(movingTop, vSnaps);
            if (snap != null) {
              newHeight = fixedBottom - snap.position;
              guideLines.add(
                SnapGuideLine(
                  start: Offset(0, snap.position),
                  end: Offset(boardBox.size.width, snap.position),
                  orientation: LineOrientation.horizontal,
                ),
              );
            }
          }
          if (newHeight < minSize) newHeight = minSize;
        }

        if (guideLines.isNotEmpty && !_wasSnapping) {
          snapConfig.onSnapHapticFeedback?.call();
        }
        _wasSnapping = guideLines.isNotEmpty;
      }
    } else {
      _wasSnapping = false;
    }

    try {
      context.updateSnapGuideLines(guideLines);
    } catch (_) {}

    if (handle == HandlePosition.right || handle == HandlePosition.left) {
      limitWx = newWidth - startSize.width;
    } else {
      limitHy = newHeight - startSize.height;
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

    // debugPrint('newSize: $newSize');
    // debugPrint('newOffset: $newOffset');
    // debugPrint('min size: $minSize');

    controller.updateBasic(
      itemId,
      size: newSize,
      offset: newOffset,
      addToHistory: false,
    );
  }

  // Helper to snap angle to nearest multiple of snapAngle
  // If the difference is within tolerance, snap it.
  double _snapAngle(
    double angle,
    RotationSnapConfig snapConfig,
    BuildContext context,
  ) {
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
    DragUpdateDetails dud,
    BuildContext context,
    StackItemStatus status,
  ) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;
    if (item.locked) return;

    final double startToCenterX = startGlobalPoint.dx - centerPoint.dx;
    final double startToCenterY = startGlobalPoint.dy - centerPoint.dy;
    final double endToCenterX = dud.globalPosition.dx - centerPoint.dx;
    final double endToCenterY = dud.globalPosition.dy - centerPoint.dy;
    final double direct =
        startToCenterX * endToCenterY - startToCenterY * endToCenterX;
    final double startToCenter = math.sqrt(
      math.pow(centerPoint.dx - startGlobalPoint.dx, 2) +
          math.pow(centerPoint.dy - startGlobalPoint.dy, 2),
    );
    final double endToCenter = math.sqrt(
      math.pow(centerPoint.dx - dud.globalPosition.dx, 2) +
          math.pow(centerPoint.dy - dud.globalPosition.dy, 2),
    );
    final double startToEnd = math.sqrt(
      math.pow(startGlobalPoint.dx - dud.globalPosition.dx, 2) +
          math.pow(startGlobalPoint.dy - dud.globalPosition.dy, 2),
    );
    final double cosA =
        (math.pow(startToCenter, 2) +
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
    final RotationSnapConfig? rotationSnapConfig = StackBoardPlusConfig.of(
      context,
    ).rotationSnapConfig;
    if (rotationSnapConfig != null) {
      angle = _snapAngle(angle, rotationSnapConfig, context);
    }

    onAngleChanged(angle);
    controller.updateBasic(itemId, angle: angle, addToHistory: false);
  }

  void onGestureStart(ScaleStartDetails details, BuildContext context) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;

    if (item.locked) return;

    // Check if selection is required for interaction
    final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
    if (config.requireSelectionForInteraction) {
      // If selection is required, only allow interaction if item is already selected
      if (item.status != StackItemStatus.selected &&
          item.status != StackItemStatus.moving &&
          item.status != StackItemStatus.scaling &&
          item.status != StackItemStatus.resizing &&
          item.status != StackItemStatus.roating) {
        // Item is not selected, ignore the gesture
        return;
      }
    }

    // Commit state before starting gesture
    controller.commit();

    StackItemStatus newStatus = StackItemStatus.moving;
    if (item.status != StackItemStatus.editing) {
      if (item.status != StackItemStatus.selected) {
        // Only auto-select if selection is not required for interaction
        if (!config.requireSelectionForInteraction) {
          controller.selectOne(itemId, addToHistory: false);
        }
      }
      controller.updateBasic(itemId, status: newStatus, addToHistory: false);
      controller.moveItemOnTop(itemId, addToHistory: false);
      onStatusChanged(newStatus);
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    centerPoint = renderBox.localToGlobal(
      Offset(renderBox.size.width / 2, renderBox.size.height / 2),
    );
    startGlobalPoint = details.focalPoint;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;

    // Cache snap points when gesture starts
    _cacheSnapPoints(context, item.size);
  }

  void onGestureUpdate(ScaleUpdateDetails details, BuildContext context) {
    final StackItem<StackItemContent>? item = controller.getById(itemId);
    if (item == null) return;
    if (item.status == StackItemStatus.editing) return;
    if (item.status == StackItemStatus.drawing) return;
    if (item.locked) return;
    // Prevent individual item manipulation when in a selected group
    if (!isGroupItem(item) && _isItemInSelectedGroup(item)) return;

    // Check if selection is required for interaction
    final StackBoardPlusConfig config = StackBoardPlusConfig.of(context);
    if (config.requireSelectionForInteraction) {
      // If selection is required, only allow interaction if item is in an active state
      if (item.status != StackItemStatus.selected &&
          item.status != StackItemStatus.moving &&
          item.status != StackItemStatus.scaling &&
          item.status != StackItemStatus.resizing &&
          item.status != StackItemStatus.roating) {
        // Item is not selected, ignore the gesture update
        return;
      }
    }

    double newAngle = startAngle + details.rotation;

    // Snap to 45 degrees (pi/4) if within tolerance
    if (details.pointerCount > 1) {
      final RotationSnapConfig? rotationSnapConfig = config.rotationSnapConfig;
      if (rotationSnapConfig != null) {
        newAngle = _snapAngle(newAngle, rotationSnapConfig, context);
      }
    }
    double zoom = config.zoomLevel ?? 1;
    if (zoom < 1) zoom = 1;
    final double fittedBoxScale = config.fittedBoxScale ?? 1;

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

    final Offset delta =
        (details.focalPoint - startGlobalPoint) / zoom * fittedBoxScale;
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

    controller.updateBasic(
      itemId,
      angle: newAngle,
      size: newSize,
      offset: newOffset,
      addToHistory: false,
    );
  }

  void onGestureEnd(ScaleEndDetails details, BuildContext context) {
    onPanEnd(context, StackItemStatus.moving);
  }
}
