import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
// ignore: unnecessary_import
import 'package:stack_board_plus/src/helpers/history_controller_mixin.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import '../helpers/group_helpers.dart';
import '../stack_board_plus_items/items/stack_group_item.dart';
import '../stack_board_plus_items/item_content/stack_group_content.dart';

class StackConfig {
  StackConfig({
    required this.data,
    required this.indexMap,
  });

  factory StackConfig.init() => StackConfig(
        data: <StackItem<StackItemContent>>[],
        indexMap: <String, int>{},
      );

  final List<StackItem<StackItemContent>> data;

  final Map<String, int> indexMap;

  StackItem<StackItemContent> operator [](String id) => data[indexMap[id]!];

  StackConfig copyWith({
    List<StackItem<StackItemContent>>? data,
    Map<String, int>? indexMap,
  }) {
    return StackConfig(
      data: data ?? this.data,
      indexMap: indexMap ?? this.indexMap,
    );
  }

  @override
  String toString() {
    return 'StackConfig(data: $data, indexMap: $indexMap)';
  }
}

@immutable
// ignore: must_be_immutable
class StackBoardPlusController extends SafeValueNotifier<StackConfig>
    with HistoryControllerMixin<StackConfig> {
  StackBoardPlusController({String? tag})
      : assert(tag != 'def', 'tag can not be "def"'),
        _tag = tag,
        super(StackConfig.init());

  factory StackBoardPlusController.def() => _defaultController;

  final String? _tag;

  final Map<String, int> _indexMap = <String, int>{};

  // Group-item relationship maps
  final Map<String, String> _itemToGroupMap = <String, String>{};
  final Map<String, List<String>> _groupToItemsMap = <String, List<String>>{};

  static final StackBoardPlusController _defaultController =
      StackBoardPlusController(tag: 'def');

  List<StackItem<StackItemContent>> get innerData => value.data;

  Map<String, int> get _newIndexMap => Map<String, int>.from(_indexMap);

  StackItem<StackItemContent>? get selectedItem => innerData.firstWhereOrNull(
        (StackItem<StackItemContent> item) =>
            item.status == StackItemStatus.selected,
      );
  StackItem<StackItemContent>? get activeItem => innerData.firstWhereOrNull(
        (StackItem<StackItemContent> item) =>
            item.status != StackItemStatus.idle,
      );

  bool get isGrouping =>
      innerData.any((item) => item.status == StackItemStatus.grouping);

  /// * get item by id
  StackItem<StackItemContent>? getById(String id) {
    if (!_indexMap.containsKey(id)) return null;
    return innerData[_indexMap[id]!];
  }

  /// * get index by id
  int getIndexById(String id) {
    return _indexMap[id]!;
  }

  /// * reorder index
  List<StackItem<StackItemContent>> _reorder(
      List<StackItem<StackItemContent>> data) {
    for (int i = 0; i < data.length; i++) {
      _indexMap[data[i].id] = i;
    }

    return data;
  }

  /// * add item
  /// If status is provided, the item will be added with the status
  /// If offset is provided, the item will be added with the offset
  void addItem(
    StackItem<StackItemContent> item, {
    StackItemStatus? status,
    Offset? offset,
    bool addToHistory = true,
  }) {
    if (innerData.contains(item)) {
      print('StackBoardController addItem: item already exists');
      return;
    }

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    // Set items status to idle
    data.asMap().forEach((int index, StackItem<StackItemContent> item) {
      data[index] = item.copyWith(status: StackItemStatus.idle);
    });

    // Normalize item status - grouping status should not be preserved from JSON
    // Grouping status should only be set by user interaction
    StackItemStatus normalizedStatus = status ?? item.status;
    if (normalizedStatus == StackItemStatus.grouping) {
      normalizedStatus = StackItemStatus.selected;
    }

    data.add(
      item.copyWith(
        status: normalizedStatus,
        offset: offset ??
            (item.offset == Offset.zero
                ? Offset(
                    40 + item.size.width / 2,
                    40 + item.size.height / 2,
                  )
                : item.offset),
      ),
    );

    _indexMap[item.id] = data.length - 1;

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * remove item
  void removeItem(StackItem<StackItemContent> item,
      {bool addToHistory = true}) {
    // If removing a group, also remove all items in the group
    if (item is StackGroupItem) {
      // Get all child items recursively (handles nested groups)
      final List<StackItem<StackItemContent>> childItems =
          getGroupItemsRecursive(item, innerData);

      // Remove group from maps
      _groupToItemsMap.remove(item.id);

      // Remove all child items from data and maps
      final List<StackItem<StackItemContent>> data =
          List<StackItem<StackItemContent>>.from(innerData);

      for (final childItem in childItems) {
        data.remove(childItem);
        _indexMap.remove(childItem.id);
        _itemToGroupMap.remove(childItem.id);
        // If child is also a group, remove it from group maps
        if (childItem is StackGroupItem) {
          _groupToItemsMap.remove(childItem.id);
        }
      }

      _reorder(data);
      if (addToHistory) commit();
      value = value.copyWith(data: data, indexMap: _newIndexMap);
    } else if (isItemInGroup(item.id)) {
      // If removing an item that's in a group, remove it from the group
      final groupId = _itemToGroupMap[item.id];
      if (groupId != null) {
        final itemIds = _groupToItemsMap[groupId];
        if (itemIds != null) {
          itemIds.remove(item.id);
          if (itemIds.length < 2) {
            // If group has less than 2 items, ungroup it
            ungroup(groupId, addToHistory: addToHistory);
          } else {
            // Update group content
            final group = getGroupById(groupId);
            if (group != null) {
              final List<StackItem<StackItemContent>> data =
                  List<StackItem<StackItemContent>>.from(innerData);
              final groupIndex = _indexMap[groupId]!;
              final updatedContent = group.content!.copyWith(
                itemIds: itemIds,
              );
              data[groupIndex] = group.copyWith(content: updatedContent);
              if (addToHistory) commit();
              value = value.copyWith(data: data);
            }
          }
        }
        _itemToGroupMap.remove(item.id);
      }
    }

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    data.remove(item);
    _indexMap.remove(item.id);

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * remove item by id
  void removeById(String id, {bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final item = innerData[_indexMap[id]!];
    removeItem(item, addToHistory: addToHistory);
  }

  /// * select only item
  void selectOne(String id,
      {bool forceMoveToTop = false, bool addToHistory = false}) {
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    // If clicking an item that's in a group, select the group instead
    String? targetId = id;
    if (isItemInGroup(id)) {
      targetId = getGroupForItem(id);
      if (targetId == null) return;
    }

    // If in grouping mode, toggle grouping status instead of selecting
    if (isGrouping) {
      toggleGroupingStatus(targetId, addToHistory: addToHistory);
      return;
    }

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      final bool selectedOne = item.id == targetId;

      // If this item is in the selected group, keep it idle (don't show individual borders)
      if (selectedOne && item is StackGroupItem) {
        // Set all child items to idle
        final childItems = getItemsInGroup(item.id);
        for (final childItem in childItems) {
          final childIndex = _indexMap[childItem.id];
          if (childIndex != null) {
            data[childIndex] = childItem.copyWith(status: StackItemStatus.idle);
          }
        }
      }

      // Clear grouping status when selecting (unless the selected item is in grouping status)
      final newStatus = selectedOne
          ? StackItemStatus.selected
          : (item.status == StackItemStatus.grouping
              ? StackItemStatus.grouping
              : StackItemStatus.idle);

      data[i] = item.copyWith(status: newStatus);
    }

    if (_indexMap.containsKey(targetId)) {
      final StackItem<StackItemContent> item = data[_indexMap[targetId]!];
      if (!item.lockZOrder || forceMoveToTop) {
        data.removeAt(_indexMap[targetId]!);
        data.add(item);
      }
    }

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  void toggleLockItem(String id, {bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final currentItem = data[_indexMap[id]!];
    final wasLocked = currentItem.lockZOrder;

    // If locking a group, lock all child items as well
    if (currentItem is StackGroupItem) {
      final childItems = getItemsInGroup(id);
      for (final childItem in childItems) {
        final childIndex = _indexMap[childItem.id];
        if (childIndex != null) {
          if (wasLocked) {
            data[childIndex] = childItem.copyWith(
              lockZOrder: false,
              locked: false,
            );
          } else {
            data[childIndex] = childItem.copyWith(
              lockZOrder: false,
              locked: false,
            );
          }
        }
      }
    }

    if (wasLocked) {
      data[_indexMap[id]!] =
          data[_indexMap[id]!].copyWith(lockZOrder: false, locked: false);
    } else {
      data[_indexMap[id]!] =
          data[_indexMap[id]!].copyWith(lockZOrder: true, locked: true);
    }

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * update one item status
  void setItemStatus(String id, StackItemStatus status,
      {bool addToHistory = false}) {
    if (!_indexMap.containsKey(id)) return;

    final int index = _indexMap[id]!;

    final StackItem<StackItemContent> item = innerData[index];

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    data[index] = item.copyWith(status: status);

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }

  /// * update all item status
  void setAllItemStatuses(StackItemStatus status, {bool addToHistory = true}) {
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      data[i] = item.copyWith(status: status);
    }

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * move item on top
  void moveItemOnTop(String id,
      {bool force = false, bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final StackItem<StackItemContent> item = data[_indexMap[id]!];

    if (!item.lockZOrder || force) {
      data.removeAt(_indexMap[id]!);
      data.add(item);
    }

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * move item to bottom (index 0)
  void moveItemToBottom(String id,
      {bool force = false, bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final StackItem<StackItemContent> item = data[_indexMap[id]!];

    if (!item.lockZOrder || force) {
      data.removeAt(_indexMap[id]!);
      data.insert(0, item);
    }

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * move item one step forward (toward top)
  void moveItemForward(String id,
      {bool force = false, bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final int currentIndex = _indexMap[id]!;
    final StackItem<StackItemContent> item = data[currentIndex];
    if (currentIndex >= data.length - 1) return; // already at top

    if (!item.lockZOrder || force) {
      data.removeAt(currentIndex);
      data.insert(currentIndex + 1, item);
    }

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * move item one step backward (toward bottom)
  void moveItemBackward(String id,
      {bool force = false, bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final int currentIndex = _indexMap[id]!;
    final StackItem<StackItemContent> item = data[currentIndex];
    if (currentIndex <= 0) return; // already at bottom

    if (!item.lockZOrder || force) {
      data.removeAt(currentIndex);
      data.insert(currentIndex - 1, item);
    }

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * move item to a specific index (0..length-1)
  void moveItemToIndex(String id, int newIndex,
      {bool force = false, bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    if (newIndex < 0 || newIndex >= data.length) return;

    final int currentIndex = _indexMap[id]!;
    final StackItem<StackItemContent> item = data[currentIndex];

    if (!item.lockZOrder || force) {
      data.removeAt(currentIndex);
      data.insert(newIndex, item);
    }

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * unselect all items
  /// [force] is used to unselect all items even if they are editing.<br/>
  /// Default to false: if not provided, calling this method will pass all editing items to selected instead of idle (and other items will be idle)<br/>
  void unSelectAll({bool addToHistory = true, bool force = false}) {
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      // if (!item.locked) {
      data[i] = item.copyWith(
          status: item.status == StackItemStatus.editing && !force
              ? StackItemStatus.selected
              : StackItemStatus.idle);
      // }
    }

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }

  /// * Toggle grouping status for an item
  /// Allows multiple items to be in grouping status simultaneously
  void toggleGroupingStatus(String id, {bool addToHistory = false}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final item = data[_indexMap[id]!];
    final newStatus = item.status == StackItemStatus.grouping
        ? StackItemStatus.idle
        : StackItemStatus.grouping;

    data[_indexMap[id]!] = item.copyWith(status: newStatus);

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }

  /// * Get all items in grouping status
  List<StackItem<StackItemContent>> getGroupingItems() {
    return innerData
        .where((item) => item.status == StackItemStatus.grouping)
        .toList();
  }

  /// * Clear all grouping statuses
  void clearGroupingStatus({bool addToHistory = false}) {
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      if (item.status == StackItemStatus.grouping) {
        data[i] = item.copyWith(status: StackItemStatus.idle);
      }
    }

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }

  /// * update basic config
  void updateBasic(String id,
      {Size? size,
      Offset? offset,
      double? angle,
      StackItemStatus? status,
      bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final item = data[_indexMap[id]!];

    // If this is a group, update group transform
    if (item is StackGroupItem) {
      updateGroupTransform(id,
          offset: offset, angle: angle, size: size, addToHistory: addToHistory);
      if (status != null) {
        data[_indexMap[id]!] = item.copyWith(status: status);
        if (addToHistory) commit();
        value = value.copyWith(data: data);
      }
      return;
    }

    data[_indexMap[id]!] = item.copyWith(
      size: size,
      offset: offset,
      angle: angle,
      status: status,
    );

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }

  /// * update item
  void updateItem(StackItem<StackItemContent> item,
      {bool addToHistory = true}) {
    if (!_indexMap.containsKey(item.id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    data[_indexMap[item.id]!] = item;

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }

  void flipItem(String id,
      {bool flipX = false, bool flipY = false, bool addToHistory = true}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final currentItem = data[_indexMap[id]!];
    final newFlipX = flipX ? !currentItem.flipX : currentItem.flipX;
    final newFlipY = flipY ? !currentItem.flipY : currentItem.flipY;

    data[_indexMap[id]!] =
        currentItem.copyWith(flipX: newFlipX, flipY: newFlipY);

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }

  /// * clear
  void clear({bool addToHistory = true}) {
    if (addToHistory) commit();
    value = StackConfig.init();
    _indexMap.clear();
  }

  /// * get selected item json data
  Map<String, dynamic>? getSelectedData() {
    return innerData
        .firstWhereOrNull(
          (StackItem<StackItemContent> item) =>
              item.status == StackItemStatus.selected,
        )
        ?.toJson();
  }

  /// * get data json by id
  Map<String, dynamic>? getDataById(String id) {
    return innerData
        .firstWhereOrNull((StackItem<StackItemContent> item) => item.id == id)
        ?.toJson();
  }

  /// * get data json list by type
  List<Map<String, dynamic>>
      getTypeData<T extends StackItem<StackItemContent>>() {
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      if (item is T) {
        final Map<String, dynamic> map = item.toJson();
        list.add(map);
      }
    }

    return list;
  }

  /// * get data json list
  List<Map<String, dynamic>> getAllData() {
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      final Map<String, dynamic> map = item.toJson();
      list.add(map);
    }

    return list;
  }

  @override
  int get hashCode => _tag.hashCode;

  @override
  bool operator ==(Object other) =>
      other is StackBoardPlusController && _tag == other._tag;

  @override
  void dispose() {
    if (_tag == 'def') {
      assert(false, 'default StackBoardController can not be disposed');
      return;
    }

    super.dispose();
  }

  @override
  set value(StackConfig newValue) {
    // Rebuild index map when value is set (e.g. from undo/redo)
    if (super.value != newValue) {
      _indexMap.clear();
      for (int i = 0; i < newValue.data.length; i++) {
        _indexMap[newValue.data[i].id] = i;
      }
      // Rebuild group maps
      _rebuildGroupMaps(newValue.data);
      super.value = newValue;
    }
  }

  // Group management methods

  /// Rebuild group-item relationship maps from data
  void _rebuildGroupMaps(List<StackItem<StackItemContent>> data) {
    _itemToGroupMap.clear();
    _groupToItemsMap.clear();

    for (final item in data) {
      if (item is StackGroupItem && item.content != null) {
        final groupId = item.id;
        final itemIds = item.content!.itemIds;
        _groupToItemsMap[groupId] = List<String>.from(itemIds);
        for (final itemId in itemIds) {
          _itemToGroupMap[itemId] = groupId;
        }
      }
    }
  }

  /// Check if an item is in a group
  bool isItemInGroup(String itemId) {
    return _itemToGroupMap.containsKey(itemId);
  }

  /// Get the group ID for an item
  String? getGroupForItem(String itemId) {
    return _itemToGroupMap[itemId];
  }

  /// Get group by ID
  StackGroupItem? getGroupById(String groupId) {
    final item = getById(groupId);
    return item is StackGroupItem ? item : null;
  }

  /// Get all items in a group (direct children only)
  List<StackItem<StackItemContent>> getItemsInGroup(String groupId) {
    final itemIds = _groupToItemsMap[groupId];
    if (itemIds == null) return [];

    return itemIds
        .map((id) => getById(id))
        .whereType<StackItem<StackItemContent>>()
        .toList();
  }

  /// Calculate bounds for items, handling nested groups
  Rect _calculateBoundsForGroupItems(List<StackItem<StackItemContent>> items) {
    final allItems = <StackItem<StackItemContent>>[];
    for (final item in items) {
      if (item is StackGroupItem) {
        // Recursively get all items from nested group
        allItems.addAll(getGroupItemsRecursive(item, innerData));
      } else {
        allItems.add(item);
      }
    }
    return calculateGroupBounds(allItems);
  }

  /// Create a group from items in grouping status, or from provided item IDs (supports nested groups)
  void createGroup({List<String>? itemIds, bool addToHistory = true}) {
    // If no itemIds provided, use items in grouping status
    final List<String> idsToGroup =
        itemIds ?? getGroupingItems().map((item) => item.id).toList();

    if (idsToGroup.length < 2) return; // Need at least 2 items to group

    // Create group using the provided or grouping items
    _createGroupFromIds(idsToGroup, addToHistory: addToHistory);

    // Clear grouping status after creating group
    if (itemIds == null) {
      clearGroupingStatus(addToHistory: false);
    }
  }

  /// Internal method to create a group from a list of item IDs
  void _createGroupFromIds(List<String> itemIds, {bool addToHistory = true}) {
    if (itemIds.length < 2) return; // Need at least 2 items to group

    // Filter out items that don't exist
    // Allow items that are already in groups (for nested groups)
    final validItems = <StackItem<StackItemContent>>[];
    for (final itemId in itemIds) {
      if (!_indexMap.containsKey(itemId)) continue;
      final item = innerData[_indexMap[itemId]!];
      validItems.add(item);
    }

    if (validItems.length < 2) return; // Need at least 2 valid items

    // For nested groups, use recursive bounds calculation
    final bounds = _calculateBoundsForGroupItems(validItems);
    final groupSize = Size(bounds.width, bounds.height);
    final groupCenter = Offset(
      bounds.left + bounds.width / 2,
      bounds.top + bounds.height / 2,
    );

    // Create group item
    final groupItem = StackGroupItem(
      size: groupSize,
      offset: groupCenter,
      angle: 0,
      status: StackItemStatus.selected,
      content: GroupItemContent(
        itemIds: validItems.map((item) => item.id).toList(),
        groupCenter: groupCenter,
      ),
    );

    // Add group to data
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    // Set all items to idle and store their relative positions
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      if (validItems.contains(item)) {
        data[i] = item.copyWith(status: StackItemStatus.idle);
      }
    }

    data.add(groupItem);
    _indexMap[groupItem.id] = data.length - 1;

    // Update group maps
    // For nested groups, we need to handle items that are already in groups
    final allItemIds = <String>[];
    for (final item in validItems) {
      if (item is StackGroupItem) {
        // If item is a group, get all its child items recursively
        final childItems = getGroupItemsRecursive(item, innerData);
        allItemIds.addAll(childItems.map((i) => i.id));
      } else {
        allItemIds.add(item.id);
      }
    }
    _groupToItemsMap[groupItem.id] = validItems.map((item) => item.id).toList();
    // Only map direct children, not nested children
    for (final item in validItems) {
      // If item is already in a group, don't overwrite its mapping
      // (it's now in a nested group)
      if (!_itemToGroupMap.containsKey(item.id)) {
        _itemToGroupMap[item.id] = groupItem.id;
      }
    }

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// Ungroup a group
  void ungroup(String groupId, {bool addToHistory = true}) {
    final group = getGroupById(groupId);
    if (group == null) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    // Remove group from data
    data.removeAt(_indexMap[groupId]!);
    _indexMap.remove(groupId);

    // Remove from group maps
    final itemIds = _groupToItemsMap.remove(groupId) ?? [];
    for (final itemId in itemIds) {
      _itemToGroupMap.remove(itemId);
    }

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// Update group transform and apply to all child items (handles nested groups)
  void updateGroupTransform(String groupId,
      {Offset? offset, double? angle, Size? size, bool addToHistory = true}) {
    final group = getGroupById(groupId);
    if (group == null) return;

    // Get all child items recursively (including nested groups)
    final childItems = getGroupItemsRecursive(group, innerData);
    if (childItems.isEmpty) return;

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    final oldGroup = data[_indexMap[groupId]!] as StackGroupItem;
    final oldCenter = oldGroup.offset;
    final oldAngle = oldGroup.angle;
    final oldSize = oldGroup.size;

    final newOffset = offset ?? oldCenter;
    final newAngle = angle ?? oldAngle;
    final newSize = size ?? oldSize;

    // Calculate scale factors
    final scaleX = newSize.width / oldSize.width;
    final scaleY = newSize.height / oldSize.height;

    // Update child items relative to group center
    for (final childItem in childItems) {
      final childIndex = _indexMap[childItem.id]!;
      final oldChildOffset = childItem.offset;
      final oldChildAngle = childItem.angle;
      final oldChildSize = childItem.size;

      // Calculate relative position from old group center
      final relativeOffset = oldChildOffset - oldCenter;

      // Apply rotation around old center
      final cosOld = math.cos(-oldAngle);
      final sinOld = math.sin(-oldAngle);
      final rotatedX = relativeOffset.dx * cosOld - relativeOffset.dy * sinOld;
      final rotatedY = relativeOffset.dx * sinOld + relativeOffset.dy * cosOld;

      // Apply scale
      final scaledX = rotatedX * scaleX;
      final scaledY = rotatedY * scaleY;

      // Rotate back around new center with new angle
      final cosNew = math.cos(newAngle);
      final sinNew = math.sin(newAngle);
      final finalX = scaledX * cosNew - scaledY * sinNew;
      final finalY = scaledX * sinNew + scaledY * cosNew;

      // Calculate new child offset
      final newChildOffset = newOffset + Offset(finalX, finalY);

      // Update child angle (relative to group)
      final newChildAngle = oldChildAngle - oldAngle + newAngle;

      // Update child size
      final newChildSize = Size(
        oldChildSize.width * scaleX,
        oldChildSize.height * scaleY,
      );

      data[childIndex] = childItem.copyWith(
        offset: newChildOffset,
        angle: newChildAngle,
        size: newChildSize,
      );
    }

    // Update group
    data[_indexMap[groupId]!] = oldGroup.copyWith(
      offset: newOffset,
      angle: newAngle,
      size: newSize,
    );

    if (addToHistory) commit();
    value = value.copyWith(data: data);
  }
}
