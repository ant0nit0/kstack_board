import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import '../core/snap_config.dart';

/// Represents a snap point with its position and type
class SnapPoint {
  const SnapPoint({
    required this.position,
    required this.type,
    this.itemId,
  });

  final double position;
  final SnapType type;
  final String? itemId;

  @override
  String toString() =>
      'SnapPoint(position: $position, type: $type, itemId: $itemId)';
}

/// Types of snap points
enum SnapType {
  itemEdge,
  boardEdge,
  grid,
}

/// Result of snap calculation containing the snapped offset and guide lines
class SnapResult {
  const SnapResult({
    required this.offset,
    required this.guideLines,
  });

  final Offset offset;
  final List<SnapGuideLine> guideLines;

  bool get isSnapped => guideLines.isNotEmpty;
}

/// Represents a guide line to be drawn when snapping
class SnapGuideLine {
  const SnapGuideLine({
    required this.start,
    required this.end,
    required this.orientation,
  });

  final Offset start;
  final Offset end;
  final LineOrientation orientation;

  @override
  String toString() =>
      'SnapGuideLine($orientation: ${start.dx},${start.dy} -> ${end.dx},${end.dy})';
}

/// Orientation of a guide line
enum LineOrientation {
  horizontal,
  vertical,
}

/// Helper class for calculating snap points and positions
class SnapCalculator {
  const SnapCalculator({
    required this.boardSize,
    required this.allItems,
    required this.movingItemId,
    required this.config,
  });

  final Size boardSize;
  final List<StackItem<StackItemContent>> allItems;
  final String movingItemId;
  final SnapConfig config;

  /// Calculate the snapped position for an item being moved
  SnapResult calculateSnap(Offset currentOffset, Size itemSize) {
    // If snap is disabled or threshold is 0, return original offset
    if (!config.enabled || config.snapThreshold <= 0) {
      return SnapResult(
        offset: currentOffset,
        guideLines: <SnapGuideLine>[],
      );
    }

    final List<SnapGuideLine> guideLines = <SnapGuideLine>[];

    // Get all potential snap points
    final List<SnapPoint> horizontalSnaps = _getHorizontalSnapPoints(itemSize);
    final List<SnapPoint> verticalSnaps = _getVerticalSnapPoints(itemSize);

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
      if (topDistance < config.snapThreshold &&
          topDistance < minVerticalDistance) {
        minVerticalDistance = topDistance;
        nearestVerticalSnap = snap;
        snappedY = snap.position + itemSize.height / 2;
      }

      // Check if item's bottom edge should snap
      final double bottomDistance = (itemBottom - snap.position).abs();
      if (bottomDistance < config.snapThreshold &&
          bottomDistance < minVerticalDistance) {
        minVerticalDistance = bottomDistance;
        nearestVerticalSnap = snap;
        snappedY = snap.position - itemSize.height / 2;
      }

      // Check if item's center should snap
      final double centerDistance = (currentOffset.dy - snap.position).abs();
      if (centerDistance < config.snapThreshold &&
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
      if (leftDistance < config.snapThreshold &&
          leftDistance < minHorizontalDistance) {
        minHorizontalDistance = leftDistance;
        nearestHorizontalSnap = snap;
        snappedX = snap.position + itemSize.width / 2;
      }

      // Check if item's right edge should snap
      final double rightDistance = (itemRight - snap.position).abs();
      if (rightDistance < config.snapThreshold &&
          rightDistance < minHorizontalDistance) {
        minHorizontalDistance = rightDistance;
        nearestHorizontalSnap = snap;
        snappedX = snap.position - itemSize.width / 2;
      }

      // Check if item's center should snap
      final double centerDistance = (currentOffset.dx - snap.position).abs();
      if (centerDistance < config.snapThreshold &&
          centerDistance < minHorizontalDistance) {
        minHorizontalDistance = centerDistance;
        nearestHorizontalSnap = snap;
        snappedX = snap.position;
      }
    }

    // Create guide lines if snapping occurred
    if (nearestVerticalSnap != null) {
      guideLines.add(SnapGuideLine(
        start: Offset(0, nearestVerticalSnap.position),
        end: Offset(boardSize.width, nearestVerticalSnap.position),
        orientation: LineOrientation.horizontal,
      ));
    }

    if (nearestHorizontalSnap != null) {
      guideLines.add(SnapGuideLine(
        start: Offset(nearestHorizontalSnap.position, 0),
        end: Offset(nearestHorizontalSnap.position, boardSize.height),
        orientation: LineOrientation.vertical,
      ));
    }

    return SnapResult(
      offset: Offset(snappedX, snappedY),
      guideLines: guideLines,
    );
  }

  /// Get all horizontal snap points (vertical lines)
  List<SnapPoint> _getHorizontalSnapPoints(Size itemSize) {
    final List<SnapPoint> snaps = <SnapPoint>[];

    // Board edges
    if (config.snapToBoardEdges) {
      snaps.add(SnapPoint(position: 0, type: SnapType.boardEdge));
      snaps.add(SnapPoint(position: boardSize.width, type: SnapType.boardEdge));
    }

    // Grid divisions
    if (config.snapToGrid && config.horizontalDivisions > 0) {
      for (int i = 1; i < config.horizontalDivisions; i++) {
        final double position =
            boardSize.width * i / config.horizontalDivisions;
        snaps.add(SnapPoint(position: position, type: SnapType.grid));
      }
    }

    // Other items' edges
    if (config.snapToItems) {
      for (final StackItem<StackItemContent> item in allItems) {
        if (item.id == movingItemId) continue;

        final double itemLeft = item.offset.dx - item.size.width / 2;
        final double itemRight = item.offset.dx + item.size.width / 2;
        final double itemCenter = item.offset.dx;

        snaps.add(SnapPoint(
          position: itemLeft,
          type: SnapType.itemEdge,
          itemId: item.id,
        ));
        snaps.add(SnapPoint(
          position: itemRight,
          type: SnapType.itemEdge,
          itemId: item.id,
        ));
        snaps.add(SnapPoint(
          position: itemCenter,
          type: SnapType.itemEdge,
          itemId: item.id,
        ));
      }
    }

    return snaps;
  }

  /// Get all vertical snap points (horizontal lines)
  List<SnapPoint> _getVerticalSnapPoints(Size itemSize) {
    final List<SnapPoint> snaps = <SnapPoint>[];

    // Board edges
    if (config.snapToBoardEdges) {
      snaps.add(SnapPoint(position: 0, type: SnapType.boardEdge));
      snaps
          .add(SnapPoint(position: boardSize.height, type: SnapType.boardEdge));
    }

    // Grid divisions
    if (config.snapToGrid && config.verticalDivisions > 0) {
      for (int i = 1; i < config.verticalDivisions; i++) {
        final double position = boardSize.height * i / config.verticalDivisions;
        snaps.add(SnapPoint(position: position, type: SnapType.grid));
      }
    }

    // Other items' edges
    if (config.snapToItems) {
      for (final StackItem<StackItemContent> item in allItems) {
        if (item.id == movingItemId) continue;

        final double itemTop = item.offset.dy - item.size.height / 2;
        final double itemBottom = item.offset.dy + item.size.height / 2;
        final double itemCenter = item.offset.dy;

        snaps.add(SnapPoint(
          position: itemTop,
          type: SnapType.itemEdge,
          itemId: item.id,
        ));
        snaps.add(SnapPoint(
          position: itemBottom,
          type: SnapType.itemEdge,
          itemId: item.id,
        ));
        snaps.add(SnapPoint(
          position: itemCenter,
          type: SnapType.itemEdge,
          itemId: item.id,
        ));
      }
    }

    return snaps;
  }
}
