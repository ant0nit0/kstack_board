import 'package:flutter/material.dart';

/// Configuration for snap behavior in StackBoardPlus
class SnapConfig {
  const SnapConfig({
    this.enabled = true,
    this.snapThreshold = 2.0,
    this.horizontalDivisions = 2,
    this.verticalDivisions = 2,
    this.snapToItems = true,
    this.snapToBoardEdges = true,
    this.snapToGrid = true,
    this.showAllSnapLines = false,
    this.snapLineColor = const Color(0xFFE0E0E0),
    this.snapLineWidth = 1.0,
    this.snapLineOpacity = 0.3,
    this.onSnapHapticFeedback,
  });

  /// Whether snap is enabled
  final bool enabled;

  /// Distance threshold for snapping (0 = no snap, larger = more lenient)
  /// When an item is within this distance of a snap point, it will snap
  final double snapThreshold;

  /// Number of horizontal grid divisions (1/6 by default)
  final int horizontalDivisions;

  /// Number of vertical grid divisions (1/9 by default)
  final int verticalDivisions;

  /// Whether to snap to other items' edges
  final bool snapToItems;

  /// Whether to snap to board edges
  final bool snapToBoardEdges;

  /// Whether to snap to grid divisions
  final bool snapToGrid;

  /// Whether to show all potential snap lines (grid overlay)
  final bool showAllSnapLines;

  /// Color for all snap lines
  final Color snapLineColor;

  /// Stroke width for all snap lines
  final double snapLineWidth;

  /// Opacity for all snap lines (0.0 to 1.0)
  final double snapLineOpacity;

  /// Optional callback for haptic feedback when snapping occurs
  /// Called whenever an item snaps to a snap point
  final void Function()? onSnapHapticFeedback;

  /// Create a copy with modified values
  SnapConfig copyWith({
    bool? enabled,
    double? snapThreshold,
    int? horizontalDivisions,
    int? verticalDivisions,
    bool? snapToItems,
    bool? snapToBoardEdges,
    bool? snapToGrid,
    bool? showAllSnapLines,
    Color? snapLineColor,
    double? snapLineWidth,
    double? snapLineOpacity,
    void Function()? onSnapHapticFeedback,
  }) {
    return SnapConfig(
      enabled: enabled ?? this.enabled,
      snapThreshold: snapThreshold ?? this.snapThreshold,
      horizontalDivisions: horizontalDivisions ?? this.horizontalDivisions,
      verticalDivisions: verticalDivisions ?? this.verticalDivisions,
      snapToItems: snapToItems ?? this.snapToItems,
      snapToBoardEdges: snapToBoardEdges ?? this.snapToBoardEdges,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      showAllSnapLines: showAllSnapLines ?? this.showAllSnapLines,
      snapLineColor: snapLineColor ?? this.snapLineColor,
      snapLineWidth: snapLineWidth ?? this.snapLineWidth,
      snapLineOpacity: snapLineOpacity ?? this.snapLineOpacity,
      onSnapHapticFeedback: onSnapHapticFeedback ?? this.onSnapHapticFeedback,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnapConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          snapThreshold == other.snapThreshold &&
          horizontalDivisions == other.horizontalDivisions &&
          verticalDivisions == other.verticalDivisions &&
          snapToItems == other.snapToItems &&
          snapToBoardEdges == other.snapToBoardEdges &&
          snapToGrid == other.snapToGrid &&
          showAllSnapLines == other.showAllSnapLines &&
          snapLineColor == other.snapLineColor &&
          snapLineWidth == other.snapLineWidth &&
          snapLineOpacity == other.snapLineOpacity;

  @override
  int get hashCode => Object.hash(
        enabled,
        snapThreshold,
        horizontalDivisions,
        verticalDivisions,
        snapToItems,
        snapToBoardEdges,
        snapToGrid,
        showAllSnapLines,
        snapLineColor,
        snapLineWidth,
        snapLineOpacity,
      );
}
