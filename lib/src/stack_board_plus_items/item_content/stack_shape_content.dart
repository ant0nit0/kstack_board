import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

/// Builds the geometry [Path] for a shape content at the given size.
/// Shared by the package painter and app-level painters/previews.
Path buildStackShapePath(StackShapeContent data, Size size) {
  switch (data.type) {
    case StackShapeType.rectangle:
      final maxRadius = math.min(size.width, size.height) / 2;
      final radius = data.borderRadius.clamp(0.0, maxRadius);
      if (radius > 0) {
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Offset.zero & size,
              Radius.circular(radius),
            ),
          );
      }
      return Path()..addRect(Offset.zero & size);
    case StackShapeType.roundedRectangle:
      // Legacy type — content is migrated on load, kept as a safety net.
      final radius = math.min(size.width, size.height) * 0.2;
      return Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Offset.zero & size,
            Radius.circular(radius),
          ),
        );
    case StackShapeType.circle:
      final center = Offset(size.width / 2, size.height / 2);
      final radius = math.min(size.width, size.height) / 2;
      return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    case StackShapeType.line:
      return Path()
        ..moveTo(0, size.height / 2)
        ..lineTo(size.width, size.height / 2);
    case StackShapeType.star:
      return _buildStarPath(size, data.endpoints ?? 5);
    case StackShapeType.polygon:
      return _buildPolygonPath(size, data.endpoints ?? 5);
    case StackShapeType.heart:
      return _buildHeartPath(size);
    case StackShapeType.halfMoon:
      return _buildHalfMoonPath(size);
  }
}

Path _buildPolygonPath(Size size, int sides) {
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
  return path;
}

Path _buildStarPath(Size size, int points) {
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
  return path;
}

Path _buildHeartPath(Size size) {
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
  return path;
}

Path _buildHalfMoonPath(Size size) {
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
  return Path.combine(PathOperation.difference, bigCircle, smallCircle);
}

/// Draws the drop shadow for a shape, if configured.
/// Shared by the package painter and app-level painters.
void drawStackShapeShadow(
  Canvas canvas,
  StackShapeContent data,
  Path path,
) {
  final shadowColor = data.shadowColor;
  if (shadowColor == null) return;
  // Stroke-only shapes (lines, or a hollow shape with a transparent fill)
  // cast a shadow of their outline, not of the full silhouette.
  final bool fillIsTransparent = (data.fillColor.a * 255.0).round() == 0;
  final bool strokeShadow = data.type == StackShapeType.line ||
      (fillIsTransparent && data.strokeWidth > 0);
  final shadowPaint = Paint()
    ..color = shadowColor.withValues(
      alpha: shadowColor.a * data.opacity.clamp(0.0, 1.0),
    )
    ..style = strokeShadow ? PaintingStyle.stroke : PaintingStyle.fill;
  if (strokeShadow) {
    shadowPaint.strokeWidth = data.strokeWidth;
  }
  if (data.shadowBlurRadius > 0) {
    // Same radius -> sigma conversion Flutter uses for BoxShadow.
    final sigma = data.shadowBlurRadius * 0.57735 + 0.5;
    shadowPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
  }
  final offset = data.shadowOffset ?? Offset.zero;
  canvas.save();
  canvas.translate(offset.dx, offset.dy);
  canvas.drawPath(path, shadowPaint);
  canvas.restore();
}

class StackShapeContentWidget extends StatelessWidget {
  final StackShapeItem item;

  const StackShapeContentWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final content = item.content;
    if (content == null) return const SizedBox.shrink();
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateZ(content.tilt * math.pi / 180)
        ..scaleByVector3(
          vm.Vector3(
            item.flipX ? -1.0 : 1.0,
            item.flipY ? -1.0 : 1.0,
            1.0,
          ),
        ),
      child: Opacity(
        opacity: content.opacity.clamp(0.0, 1.0),
        child: CustomPaint(
          size: Size(content.width, content.height),
          painter: _ShapePainter(content),
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final StackShapeContent data;
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

    final path = buildStackShapePath(data, size);
    drawStackShapeShadow(canvas, data, path);
    if (data.type != StackShapeType.line) {
      canvas.drawPath(path, fillPaint);
    }
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
