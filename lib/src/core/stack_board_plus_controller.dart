import 'dart:ui';

import 'package:flutter/foundation.dart';
// ignore: unnecessary_import
import 'package:stack_board_plus/src/helpers/history_controller_mixin.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

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

    data.add(
      item.copyWith(
        status: status ?? item.status,
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

    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    data.removeAt(_indexMap[id]!);
    _indexMap.remove(id);

    _reorder(data);

    if (addToHistory) commit();
    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * select only item
  void selectOne(String id,
      {bool forceMoveToTop = false, bool addToHistory = true}) {
    final List<StackItem<StackItemContent>> data =
        List<StackItem<StackItemContent>>.from(innerData);

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      final bool selectedOne = item.id == id;
      // Update the status only if the item is not locked
      // if (selectedOne) {
      data[i] = item.copyWith(
          status:
              selectedOne ? StackItemStatus.selected : StackItemStatus.idle);
      // }
    }

    if (_indexMap.containsKey(id)) {
      final StackItem<StackItemContent> item = data[_indexMap[id]!];
      if (!item.lockZOrder || forceMoveToTop) {
        data.removeAt(_indexMap[id]!);
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

    data[_indexMap[id]!] = data[_indexMap[id]!].copyWith(
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
      super.value = newValue;
    }
  }
}
