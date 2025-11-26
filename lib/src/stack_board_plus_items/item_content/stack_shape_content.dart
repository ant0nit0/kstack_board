import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class StackShapeContent extends StatelessWidget {
  final StackShapeData data;

  const StackShapeContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(data.tilt * math.pi / 180)
        ..scaleByVector3(
          vm.Vector3(
            data.flipHorizontal ? -1.0 : 1.0,
            data.flipVertical ? -1.0 : 1.0,
            1.0,
          ),
        ),
      child: Opacity(
        opacity: data.opacity.clamp(0.0, 1.0),
        child: CustomPaint(
          size: Size(data.width, data.height),
          painter: _ShapePainter(data),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    // You can implement this for serialization if needed
    return {};
  }
}

class _ShapePainter extends CustomPainter {
  final StackShapeData data;
  _ShapePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = data.fillColor.withAlpha((data.opacity * 255).toInt())
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = data.strokeColor.withAlpha((data.opacity * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.strokeWidth;

    switch (data.type) {
      case StackShapeType.rectangle:
        canvas.drawRect(Offset.zero & size, fillPaint);
        canvas.drawRect(Offset.zero & size, strokePaint);
        break;
      case StackShapeType.roundedRectangle:
        final radius = Radius.circular(math.min(size.width, size.height) * 0.2);
        final rrect = RRect.fromRectAndRadius(Offset.zero & size, radius);
        canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, strokePaint);
        break;
      case StackShapeType.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = math.min(size.width, size.height) / 2;
        canvas.drawCircle(center, radius, fillPaint);
        canvas.drawCircle(center, radius, strokePaint);
        break;
      case StackShapeType.line:
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          strokePaint,
        );
        break;
      case StackShapeType.star:
        _drawStar(canvas, size, data.endpoints ?? 5, fillPaint, strokePaint);
        break;
      case StackShapeType.polygon:
        _drawPolygon(canvas, size, data.endpoints ?? 5, fillPaint, strokePaint);
        break;
      case StackShapeType.heart:
        _drawHeart(canvas, size, fillPaint, strokePaint);
        break;
      case StackShapeType.halfMoon:
        _drawHalfMoon(canvas, size, fillPaint, strokePaint);
        break;
    }
  }

  void _drawPolygon(
      Canvas canvas, Size size, int sides, Paint fill, Paint stroke) {
    final path = Path();
    final angle = (2 * math.pi) / sides;
    final radius = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < sides; i++) {
      final x = center.dx + radius * math.cos(angle * i - math.pi / 2);
      final y = center.dy + radius * math.sin(angle * i - math.pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawStar(
      Canvas canvas, Size size, int points, Paint fill, Paint stroke) {
    final path = Path();
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.5;
    final center = Offset(size.width / 2, size.height / 2);
    final angle = math.pi / points;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + r * math.cos(i * angle - math.pi / 2);
      final y = center.dy + r * math.sin(i * angle - math.pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawHeart(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    path.moveTo(width / 2, height * 0.8);
    path.cubicTo(
      width * 1.2,
      height * 0.6,
      width * 0.8,
      height * 0.1,
      width / 2,
      height * 0.3,
    );
    path.cubicTo(
      width * 0.2,
      height * 0.1,
      -width * 0.2,
      height * 0.6,
      width / 2,
      height * 0.8,
    );
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawHalfMoon(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Improved crescent: sharper tip, thinner arc
    final innerRadius = radius * 0.7;
    final offsetAmount = radius * 0.7;

    final bigCircle = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final smallCircle = Path()
      ..addOval(Rect.fromCircle(
          center: Offset(center.dx + offsetAmount, center.dy),
          radius: innerRadius));
    final crescent =
        Path.combine(PathOperation.difference, bigCircle, smallCircle);

    canvas.drawPath(crescent, fill);
    canvas.drawPath(crescent, stroke);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
