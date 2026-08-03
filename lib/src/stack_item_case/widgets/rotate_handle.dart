import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// Corner handle that both scales and rotates the item.
///
/// It sits on the corner itself, in place of a plain scale handle. A drag
/// running along the corner's diagonal — outwards or inwards — resizes the
/// item; a drag in any other direction rotates it. The choice is made once,
/// as soon as the drag clears [_directionSlop], and every later update of
/// that gesture goes to the same pair of callbacks.
class RotateHandle extends StatefulWidget {
  const RotateHandle({
    super.key,
    required this.caseStyle,
    required this.size,
    required this.diagonal,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.onRotateStart,
    required this.onRotateUpdate,
    required this.onRotateEnd,
  });

  final CaseStyle caseStyle;

  /// Diameter of the circle, hit area padding excluded.
  final double size;

  /// Outward diagonal of this corner in the item's own (unrotated) frame,
  /// e.g. `Offset(1, -1)` for the top-right corner.
  final Offset diagonal;

  final void Function(DragStartDetails) onScaleStart;
  final void Function(DragUpdateDetails) onScaleUpdate;
  final void Function(DragEndDetails) onScaleEnd;
  final void Function(DragStartDetails) onRotateStart;
  final void Function(DragUpdateDetails) onRotateUpdate;
  final void Function(DragEndDetails) onRotateEnd;

  @override
  State<RotateHandle> createState() => _RotateHandleState();
}

enum _CornerGesture { undecided, scaling, rotating }

/// Margin between the circle and the glyph, as a fraction of the diameter.
const double _glyphInset = 0.21;

class _RotateHandleState extends State<RotateHandle> {
  /// How far the finger must travel, in screen pixels, before the gesture
  /// commits to resizing or rotating. Small enough to feel immediate, large
  /// enough that the direction read is not a single jittery frame.
  static const double _directionSlop = 10;

  _CornerGesture _gesture = _CornerGesture.undecided;
  DragStartDetails? _pendingStart;

  void _onPanStart(DragStartDetails details) {
    _gesture = _CornerGesture.undecided;
    _pendingStart = details;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_gesture == _CornerGesture.undecided) {
      final DragStartDetails? start = _pendingStart;
      if (start == null) return;

      if ((details.globalPosition - start.globalPosition).distance <
          _directionSlop) {
        // Nothing is lost by waiting: both callbacks measure from the
        // gesture's start point, so this travel still counts once the
        // direction is settled.
        return;
      }

      // The threshold is a screen distance, but the direction has to be read
      // in the item's own frame.
      final Offset travel = _localTravel(
        start.globalPosition,
        details.globalPosition,
      );
      _gesture = _isAlongDiagonal(travel)
          ? _CornerGesture.scaling
          : _CornerGesture.rotating;

      // Open the gesture on the original touch-down point, not on the point
      // where the direction became clear, so the transform stays anchored to
      // where the finger actually landed.
      if (_gesture == _CornerGesture.scaling) {
        widget.onScaleStart(start);
      } else {
        widget.onRotateStart(start);
      }
      _pendingStart = null;
    }

    if (_gesture == _CornerGesture.scaling) {
      widget.onScaleUpdate(details);
    } else {
      widget.onRotateUpdate(details);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_gesture == _CornerGesture.scaling) {
      widget.onScaleEnd(details);
    } else if (_gesture == _CornerGesture.rotating) {
      widget.onRotateEnd(details);
    }
    _gesture = _CornerGesture.undecided;
    _pendingStart = null;
  }

  /// Travel between two global points expressed in this handle's own frame,
  /// which is the item's unrotated frame — so [RotateHandle.diagonal] can be
  /// stated once per corner without knowing the item's angle.
  Offset _localTravel(Offset from, Offset to) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.globalToLocal(to) - renderObject.globalToLocal(from);
    }
    return to - from;
  }

  /// Whether [travel] runs within 45° of the corner's diagonal.
  bool _isAlongDiagonal(Offset travel) {
    final double length = widget.diagonal.distance;
    if (length == 0) return false;
    final Offset axis = widget.diagonal / length;
    final double along = travel.dx * axis.dx + travel.dy * axis.dy;
    final double across = travel.dx * axis.dy - travel.dy * axis.dx;
    return along.abs() >= across.abs();
  }

  @override
  Widget build(BuildContext context) {
    final CaseStyle style = widget.caseStyle;
    final double hitAreaPadding = style.handleHitAreaPadding;
    final Color strokeColor =
        style.scaleHandleStyle?.borderColor ??
        style.buttonStyle.borderColor ??
        Colors.grey;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpRightDownLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Padding(
          padding: EdgeInsets.all(hitAreaPadding),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: style.scaleHandleStyle?.color ?? style.buttonStyle.color,
              border: Border.all(
                width:
                    style.scaleHandleStyle?.borderWidth ??
                    style.buttonStyle.borderWidth ??
                    1.0,
                color: strokeColor,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.size * _glyphInset),
              child: CustomPaint(
                painter: RotateGlyphPainter(
                  color: strokeColor,
                  strokeWidth: widget.size * (1 - 2 * _glyphInset) * 0.135,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular arrow drawn by hand rather than taken from the icon font, so its
/// stroke weight can be set independently of its size.
class RotateGlyphPainter extends CustomPainter {
  const RotateGlyphPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  /// Where the arc starts, and how much of the circle it covers. The gap left
  /// over — upper right — is what makes the glyph read as an arrow rather
  /// than a ring.
  static const double _arcStart = math.pi * 0.06;
  static const double _arcSweep = math.pi * 1.72;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2 - strokeWidth / 2;
    if (radius <= 0) return;

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _arcStart,
      _arcSweep,
      false,
      stroke,
    );

    // Arrow head at the leading end of the arc, pointing along its tangent.
    final double endAngle = _arcStart + _arcSweep;
    final Offset tip =
        center + Offset(math.cos(endAngle), math.sin(endAngle)) * radius;
    final Offset forward = Offset(-math.sin(endAngle), math.cos(endAngle));
    final Offset side = Offset(-forward.dy, forward.dx);
    // Wide enough to bury the arc's round cap, so the head reads as one shape.
    final double half = strokeWidth;
    final Offset apex = tip + forward * (half * 2.1);

    canvas.drawPath(
      Path()
        ..moveTo(apex.dx, apex.dy)
        ..lineTo(tip.dx + side.dx * half, tip.dy + side.dy * half)
        ..lineTo(tip.dx - side.dx * half, tip.dy - side.dy * half)
        ..close(),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(RotateGlyphPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
