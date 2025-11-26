import 'package:flutter/material.dart';
import '../helpers/snap_calculator.dart';

/// Widget that draws snap guide lines over the board
class SnapGuideOverlay extends StatelessWidget {
  const SnapGuideOverlay({
    super.key,
    required this.guideLines,
    this.color = const Color(0xFF2196F3),
    this.strokeWidth = 1.0,
    this.opacity = 0.5,
  });

  final List<SnapGuideLine> guideLines;
  final Color color;
  final double strokeWidth;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (guideLines.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: _SnapGuidePainter(
          guideLines: guideLines,
          color: color.withValues(alpha: opacity),
          strokeWidth: strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SnapGuidePainter extends CustomPainter {
  const _SnapGuidePainter({
    required this.guideLines,
    required this.color,
    required this.strokeWidth,
  });

  final List<SnapGuideLine> guideLines;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (final SnapGuideLine line in guideLines) {
      // Clamp line to board bounds
      final Offset start = Offset(
        line.start.dx.clamp(0.0, size.width),
        line.start.dy.clamp(0.0, size.height),
      );
      final Offset end = Offset(
        line.end.dx.clamp(0.0, size.width),
        line.end.dy.clamp(0.0, size.height),
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(_SnapGuidePainter oldDelegate) {
    return oldDelegate.guideLines.length != guideLines.length ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
