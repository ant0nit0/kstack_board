import 'dart:math' as math;

/// Configuration for rotation snap behavior
class RotationSnapConfig {
  const RotationSnapConfig({
    this.enabled = true,
    this.snapIncrement = math.pi / 6, // 30 degrees
    this.tolerance = 3 * math.pi / 180, // 3 degrees
    this.onSnapHapticFeedback,
  });

  /// Whether rotation snap is enabled
  final bool enabled;

  /// The angle increment to snap to (in radians)
  /// Default is pi/4 (45 degrees)
  final double snapIncrement;

  /// The tolerance window for snapping (in radians)
  /// Default is 5 degrees
  final double tolerance;

  /// Optional callback for haptic feedback when snapping occurs
  final void Function()? onSnapHapticFeedback;

  RotationSnapConfig copyWith({
    bool? enabled,
    double? snapIncrement,
    double? tolerance,
    void Function()? onSnapHapticFeedback,
  }) {
    return RotationSnapConfig(
      enabled: enabled ?? this.enabled,
      snapIncrement: snapIncrement ?? this.snapIncrement,
      tolerance: tolerance ?? this.tolerance,
      onSnapHapticFeedback: onSnapHapticFeedback ?? this.onSnapHapticFeedback,
    );
  }
}
