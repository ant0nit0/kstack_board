import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

/// Configuration for wiggle animation
@immutable
class WiggleAnimationConfig {
  const WiggleAnimationConfig({
    this.enabled = true,
    this.duration = const Duration(milliseconds: 500),
    this.rotationAmplitude = 0.05, // radians (about 3 degrees)
    this.translationAmplitude = 2.0, // pixels
    this.curve = Curves.easeInOut,
  });

  /// Whether the wiggle animation is enabled
  final bool enabled;

  /// Duration of one wiggle cycle
  final Duration duration;

  /// Maximum rotation angle in radians (wiggles between -amplitude and +amplitude)
  final double rotationAmplitude;

  /// Maximum translation distance in pixels (wiggles between -amplitude and +amplitude)
  final double translationAmplitude;

  /// Animation curve
  final Curve curve;

  WiggleAnimationConfig copyWith({
    bool? enabled,
    Duration? duration,
    double? rotationAmplitude,
    double? translationAmplitude,
    Curve? curve,
  }) {
    return WiggleAnimationConfig(
      enabled: enabled ?? this.enabled,
      duration: duration ?? this.duration,
      rotationAmplitude: rotationAmplitude ?? this.rotationAmplitude,
      translationAmplitude: translationAmplitude ?? this.translationAmplitude,
      curve: curve ?? this.curve,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiggleAnimationConfig &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          duration == other.duration &&
          rotationAmplitude == other.rotationAmplitude &&
          translationAmplitude == other.translationAmplitude &&
          curve == other.curve;

  @override
  int get hashCode => Object.hash(
      enabled, duration, rotationAmplitude, translationAmplitude, curve);
}

/// Widget that applies a wiggle animation to its child
class WiggleAnimation extends StatefulWidget {
  const WiggleAnimation({
    super.key,
    required this.child,
    required this.config,
    required this.isAnimating,
  });

  final Widget child;
  final WiggleAnimationConfig config;
  final bool isAnimating;

  @override
  State<WiggleAnimation> createState() => _WiggleAnimationState();
}

class _WiggleAnimationState extends State<WiggleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    // Use a sine wave for smoother oscillation
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(WiggleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.duration != oldWidget.config.duration) {
      _controller.duration = widget.config.duration;
    }
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating && widget.config.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.enabled || !widget.isAnimating) {
      return widget.child;
    }

    // Start animation if not already running
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }

    // Calculate current values using sine wave for smooth oscillation
    final double t = _controller.value;
    final double rotation =
        math.sin(t * 2 * math.pi) * widget.config.rotationAmplitude;
    final double translationX = math.sin(t * 2 * math.pi + math.pi / 4) *
        widget.config.translationAmplitude;
    final double translationY = math.cos(t * 2 * math.pi + math.pi / 4) *
        widget.config.translationAmplitude;

    return Transform(
      transform: Matrix4.identity()
        ..rotateZ(rotation)
        ..translateByVector3(Vector3(translationX, translationY, 0)),
      alignment: Alignment.center,
      child: widget.child,
    );
  }
}
