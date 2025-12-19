import 'dart:math' as math;
import 'package:flutter/painting.dart';
import '../core/stack_board_plus_item/stack_item.dart';
import '../core/stack_board_plus_item/stack_item_content.dart';
import '../stack_board_plus_items/items/stack_group_item.dart';

/// Calculate the bounding rectangle for a list of items
/// Takes into account item rotations by calculating corners
Rect calculateGroupBounds(List<StackItem<StackItemContent>> items) {
  if (items.isEmpty) {
    return Rect.zero;
  }

  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;

  for (final item in items) {
    // Get all four corners of the item (considering rotation)
    final corners = _getItemCorners(item);

    for (final corner in corners) {
      minX = math.min(minX, corner.dx);
      minY = math.min(minY, corner.dy);
      maxX = math.max(maxX, corner.dx);
      maxY = math.max(maxY, corner.dy);
    }
  }

  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Get the four corners of an item after rotation
List<Offset> _getItemCorners(StackItem<StackItemContent> item) {
  final halfWidth = item.size.width / 2;
  final halfHeight = item.size.height / 2;

  // Local corners (relative to item center)
  final localCorners = [
    Offset(-halfWidth, -halfHeight), // top-left
    Offset(halfWidth, -halfHeight), // top-right
    Offset(-halfWidth, halfHeight), // bottom-left
    Offset(halfWidth, halfHeight), // bottom-right
  ];

  // Apply rotation
  final angle = item.angle;
  final cosA = math.cos(angle);
  final sinA = math.sin(angle);

  // Transform corners to global coordinates
  return localCorners.map((corner) {
    // Rotate around origin
    final rotatedX = corner.dx * cosA - corner.dy * sinA;
    final rotatedY = corner.dx * sinA + corner.dy * cosA;

    // Translate to item's position
    return Offset(
      item.offset.dx + rotatedX,
      item.offset.dy + rotatedY,
    );
  }).toList();
}

/// Calculate the center point of a group
Offset calculateGroupCenter(List<StackItem<StackItemContent>> items) {
  if (items.isEmpty) {
    return Offset.zero;
  }

  final bounds = calculateGroupBounds(items);
  return Offset(
    bounds.left + bounds.width / 2,
    bounds.top + bounds.height / 2,
  );
}

/// Calculate the size of a group from its bounding box
Size calculateGroupSize(List<StackItem<StackItemContent>> items) {
  if (items.isEmpty) {
    return Size.zero;
  }

  final bounds = calculateGroupBounds(items);
  return Size(bounds.width, bounds.height);
}

/// Calculate the offset (top-left) of a group from its bounding box
Offset calculateGroupOffset(List<StackItem<StackItemContent>> items) {
  if (items.isEmpty) {
    return Offset.zero;
  }

  final bounds = calculateGroupBounds(items);
  return Offset(bounds.left, bounds.top);
}

/// Check if an item is a group
bool isGroupItem(StackItem<StackItemContent> item) {
  return item is StackGroupItem;
}

/// Get all items recursively from a group (handles nested groups)
List<StackItem<StackItemContent>> getGroupItemsRecursive(
  StackGroupItem group,
  List<StackItem<StackItemContent>> allItems,
) {
  final List<StackItem<StackItemContent>> result = [];

  for (final itemId in group.content?.itemIds ?? []) {
    final item = allItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw StateError('Item $itemId not found in group'),
    );

    if (item is StackGroupItem) {
      result.add(item);
      // Recursively get items from nested group
      result.addAll(getGroupItemsRecursive(item, allItems));
    } else {
      result.add(item);
    }
  }

  return result;
}

/// Calculate bounds for a group, including nested groups
Rect calculateGroupBoundsRecursive(
  StackGroupItem group,
  List<StackItem<StackItemContent>> allItems,
) {
  final items = getGroupItemsRecursive(group, allItems);
  return calculateGroupBounds(items);
}
