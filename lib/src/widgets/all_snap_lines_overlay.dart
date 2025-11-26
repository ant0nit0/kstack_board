import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import '../core/snap_config.dart';
import '../helpers/snap_calculator.dart';

/// Widget that displays all potential snap lines based on the snap configuration
class AllSnapLinesOverlay extends StatelessWidget {
  const AllSnapLinesOverlay({
    super.key,
    required this.boardSize,
    required this.config,
    required this.allItems,
  });

  final Size boardSize;
  final SnapConfig config;
  final List<StackItem<StackItemContent>> allItems;

  @override
  Widget build(BuildContext context) {
    if (!config.showAllSnapLines || !config.enabled) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      ignoring: true,
      child: CustomPaint(
        painter: _AllSnapLinesPainter(
          boardSize: boardSize,
          config: config,
          allItems: allItems,
        ),
        size: boardSize,
      ),
    );
  }
}

class _AllSnapLinesPainter extends CustomPainter {
  const _AllSnapLinesPainter({
    required this.boardSize,
    required this.config,
    required this.allItems,
  });

  final Size boardSize;
  final SnapConfig config;
  final List<StackItem<StackItemContent>> allItems;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = config.snapLineColor.withOpacity(config.snapLineOpacity)
      ..strokeWidth = config.snapLineWidth
      ..style = PaintingStyle.stroke;

    final List<SnapGuideLine> lines = <SnapGuideLine>[];

    // Board edges
    if (config.snapToBoardEdges) {
      lines.add(SnapGuideLine(
        start: Offset(0, 0),
        end: Offset(boardSize.width, 0),
        orientation: LineOrientation.horizontal,
      ));
      lines.add(SnapGuideLine(
        start: Offset(0, boardSize.height),
        end: Offset(boardSize.width, boardSize.height),
        orientation: LineOrientation.horizontal,
      ));
      lines.add(SnapGuideLine(
        start: Offset(0, 0),
        end: Offset(0, boardSize.height),
        orientation: LineOrientation.vertical,
      ));
      lines.add(SnapGuideLine(
        start: Offset(boardSize.width, 0),
        end: Offset(boardSize.width, boardSize.height),
        orientation: LineOrientation.vertical,
      ));
    }

    // Grid divisions
    if (config.snapToGrid) {
      // Horizontal grid lines (vertical divisions)
      if (config.horizontalDivisions > 0) {
        for (int i = 1; i < config.horizontalDivisions; i++) {
          final double x = boardSize.width * i / config.horizontalDivisions;
          lines.add(SnapGuideLine(
            start: Offset(x, 0),
            end: Offset(x, boardSize.height),
            orientation: LineOrientation.vertical,
          ));
        }
      }

      // Vertical grid lines (horizontal divisions)
      if (config.verticalDivisions > 0) {
        for (int i = 1; i < config.verticalDivisions; i++) {
          final double y = boardSize.height * i / config.verticalDivisions;
          lines.add(SnapGuideLine(
            start: Offset(0, y),
            end: Offset(boardSize.width, y),
            orientation: LineOrientation.horizontal,
          ));
        }
      }
    }

    // Item edges
    if (config.snapToItems) {
      for (final StackItem<StackItemContent> item in allItems) {
        final double itemLeft = item.offset.dx - item.size.width / 2;
        final double itemRight = item.offset.dx + item.size.width / 2;
        final double itemTop = item.offset.dy - item.size.height / 2;
        final double itemBottom = item.offset.dy + item.size.height / 2;
        final double itemCenterX = item.offset.dx;
        final double itemCenterY = item.offset.dy;

        // Left edge
        lines.add(SnapGuideLine(
          start: Offset(itemLeft, 0),
          end: Offset(itemLeft, boardSize.height),
          orientation: LineOrientation.vertical,
        ));

        // Right edge
        lines.add(SnapGuideLine(
          start: Offset(itemRight, 0),
          end: Offset(itemRight, boardSize.height),
          orientation: LineOrientation.vertical,
        ));

        // Center X
        lines.add(SnapGuideLine(
          start: Offset(itemCenterX, 0),
          end: Offset(itemCenterX, boardSize.height),
          orientation: LineOrientation.vertical,
        ));

        // Top edge
        lines.add(SnapGuideLine(
          start: Offset(0, itemTop),
          end: Offset(boardSize.width, itemTop),
          orientation: LineOrientation.horizontal,
        ));

        // Bottom edge
        lines.add(SnapGuideLine(
          start: Offset(0, itemBottom),
          end: Offset(boardSize.width, itemBottom),
          orientation: LineOrientation.horizontal,
        ));

        // Center Y
        lines.add(SnapGuideLine(
          start: Offset(0, itemCenterY),
          end: Offset(boardSize.width, itemCenterY),
          orientation: LineOrientation.horizontal,
        ));
      }
    }

    // Draw all lines
    for (final SnapGuideLine line in lines) {
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
  bool shouldRepaint(_AllSnapLinesPainter oldDelegate) {
    return oldDelegate.boardSize != boardSize ||
        oldDelegate.config != config ||
        oldDelegate.allItems.length != allItems.length;
  }
}
