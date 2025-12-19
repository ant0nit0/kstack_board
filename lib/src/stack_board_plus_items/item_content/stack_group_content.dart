import 'package:flutter/painting.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// GroupItemContent holds the data for a StackGroupItem
class GroupItemContent implements StackItemContent {
  GroupItemContent({
    required this.itemIds,
    this.groupCenter,
  });

  factory GroupItemContent.fromJson(Map<String, dynamic> data) {
    return GroupItemContent(
      itemIds: (data['itemIds'] as List<dynamic>?)
              ?.map((e) => asT<String>(e))
              .toList() ??
          <String>[],
      groupCenter: data['groupCenter'] == null
          ? null
          : jsonToOffset(asMap(data['groupCenter'])),
    );
  }

  /// List of item IDs that belong to this group
  final List<String> itemIds;

  /// Calculated center point of the group (optional, can be recalculated)
  final Offset? groupCenter;

  GroupItemContent copyWith({
    List<String>? itemIds,
    Offset? groupCenter,
  }) {
    return GroupItemContent(
      itemIds: itemIds ?? this.itemIds,
      groupCenter: groupCenter ?? this.groupCenter,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemIds': itemIds,
      if (groupCenter != null) 'groupCenter': groupCenter!.toJson(),
    };
  }
}
