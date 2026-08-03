import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// The board is laid out at [_boardSize] and then squeezed into
/// [_viewportSize], so `fittedBoxScale` is exercised on every gesture — that
/// mismatch between screen pixels and board units is what used to make corner
/// drags lag behind the finger.
const Size _boardSize = Size(800, 600);
const Size _viewportSize = Size(400, 300);
const double _fittedBoxScale = 2.0; // 800 / 400

const String _itemId = 'item';

/// Screen distance a drag must cover before `PanGestureRecognizer` claims the
/// pointer. Nothing reaches the handle until it is cleared, so every test
/// primes the gesture with a move comfortably past it and measures from there.
const double _panSlop = 40;

/// `SafeState` posts a zero-duration timer on mount, so frames have to advance
/// real time or the binding trips its "timer still pending" check.
const Duration _frame = Duration(milliseconds: 16);

StackShapeItem _shape({
  required Size size,
  required Offset offset,
  double angle = 0,
}) {
  return StackShapeItem(
    id: _itemId,
    size: size,
    offset: offset,
    angle: angle,
    content: StackShapeContent(
      type: StackShapeType.rectangle,
      fillColor: Colors.blue,
      strokeColor: Colors.black,
      strokeWidth: 1,
      opacity: 1,
      tilt: 0,
      width: size.width,
      height: size.height,
    ),
  );
}

Future<StackBoardPlusController> _pumpBoard(
  WidgetTester tester, {
  required StackShapeItem item,
}) async {
  final StackBoardPlusController controller = StackBoardPlusController();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.fromSize(
            size: _viewportSize,
            child: FittedBox(
              child: SizedBox.fromSize(
                size: _boardSize,
                child: StackBoardPlus(
                  controller: controller,
                  fittedBoxScale: _fittedBoxScale,
                  caseStyle: const CaseStyle(showHelperButtons: false),
                  customBuilder: (StackItem<StackItemContent> _) =>
                      const ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  controller.addItem(item);
  await tester.pump(_frame);
  controller.selectOne(_itemId);
  await tester.pump(_frame);
  return controller;
}

/// Screen position of a board-space point.
Offset _toScreen(WidgetTester tester, Offset boardPoint) {
  final RenderBox board =
      tester.renderObject(find.byType(StackBoardPlus)) as RenderBox;
  return board.localToGlobal(boardPoint);
}

/// One of the item's corners in board space, [unitDiagonal] being e.g.
/// `Offset(1, -1)` for the top-right one.
Offset _corner(StackItem<StackItemContent> item, Offset unitDiagonal) {
  final double x = unitDiagonal.dx * item.size.width / 2;
  final double y = unitDiagonal.dy * item.size.height / 2;
  final double sin = math.sin(item.angle);
  final double cos = math.cos(item.angle);
  return item.offset + Offset(x * cos - y * sin, x * sin + y * cos);
}

/// The board-space direction the top-right corner travels along when the item
/// is scaled uniformly.
Offset _topRightDiagonal(StackItem<StackItemContent> item) {
  final double sin = math.sin(item.angle);
  final double cos = math.cos(item.angle);
  final double x = item.size.width;
  final double y = -item.size.height;
  final Offset rotated = Offset(x * cos - y * sin, x * sin + y * cos);
  return rotated / rotated.distance;
}

void main() {
  group('corner scale', () {
    Future<void> expectCornerTracksFinger(
      WidgetTester tester, {
      required Size size,
      double angle = 0,
    }) async {
      const Offset offset = Offset(400, 300);
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        item: _shape(size: size, offset: offset, angle: angle),
      );

      final StackItem<StackItemContent> initial = controller.getById(_itemId)!;
      final Offset diagonal = _topRightDiagonal(initial);

      final TestGesture gesture = await tester.startGesture(
        _toScreen(tester, _corner(initial, const Offset(1, -1))),
      );
      await tester.pump(_frame);
      // Clear the pan slop; dragging along the diagonal also commits the
      // handle to scaling rather than rotating.
      await gesture.moveBy(diagonal * _panSlop * 1.5);
      await tester.pump(_frame);

      final Offset cornerBefore = _corner(
        controller.getById(_itemId)!,
        const Offset(1, -1),
      );

      // Now the measured leg, expressed in board units.
      final Offset boardDrag = diagonal * 60;
      await gesture.moveBy(boardDrag / _fittedBoxScale);
      await tester.pump(_frame);
      await gesture.up();
      await tester.pump(_frame);

      final StackItem<StackItemContent> after = controller.getById(_itemId)!;

      // The corner moved exactly as far as the finger did, in board units.
      expect(
        _corner(after, const Offset(1, -1)),
        within(distance: 0.01, from: cornerBefore + boardDrag),
      );
      // Uniform scaling: aspect ratio preserved, opposite corner pinned.
      expect(
        after.size.width / after.size.height,
        moreOrLessEquals(size.width / size.height),
      );
      expect(
        _corner(after, const Offset(-1, 1)),
        within(distance: 0.01, from: _corner(initial, const Offset(-1, 1))),
      );
    }

    testWidgets('corner follows the finger on a non-square item', (
      WidgetTester tester,
    ) async {
      await expectCornerTracksFinger(tester, size: const Size(240, 120));
    });

    testWidgets('corner follows the finger on a rotated item', (
      WidgetTester tester,
    ) async {
      await expectCornerTracksFinger(
        tester,
        size: const Size(200, 100),
        angle: math.pi / 5,
      );
    });

    testWidgets('a drag across the diagonal leaves the item alone', (
      WidgetTester tester,
    ) async {
      const Size size = Size(240, 120);
      const Offset offset = Offset(400, 300);
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        item: _shape(size: size, offset: offset),
      );

      final StackItem<StackItemContent> initial = controller.getById(_itemId)!;
      final Offset diagonal = _topRightDiagonal(initial);
      final Offset across = Offset(-diagonal.dy, diagonal.dx);

      final TestGesture gesture = await tester.startGesture(
        _toScreen(tester, _corner(initial, const Offset(1, -1))),
      );
      await tester.pump(_frame);
      await gesture.moveBy(diagonal * _panSlop * 1.5);
      await tester.pump(_frame);

      final Size sizeBefore = controller.getById(_itemId)!.size;

      // Perpendicular to the diagonal: nothing to project onto it.
      await gesture.moveBy(across * 60 / _fittedBoxScale);
      await tester.pump(_frame);
      await gesture.up();
      await tester.pump(_frame);

      expect(controller.getById(_itemId)!.size.width, closeTo(sizeBefore.width, 0.01));
    });
  });

  group('rotation', () {
    /// Drives the corner handle around the item centre and returns the angles
    /// the item held at each sample.
    Future<List<double>> sweep(
      WidgetTester tester, {
      required double totalSweep,
      required int steps,
      required double radius,
    }) async {
      const Offset center = Offset(400, 300);
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        item: _shape(size: const Size(200, 200), offset: center),
      );

      final Offset corner = _corner(
        controller.getById(_itemId)!,
        const Offset(1, -1),
      );
      final double cornerAngle = math.atan2(
        corner.dy - center.dy,
        corner.dx - center.dx,
      );
      Offset pointAt(double angle) =>
          center + Offset(math.cos(angle), math.sin(angle)) * radius;

      final TestGesture gesture = await tester.startGesture(
        _toScreen(tester, corner),
      );
      await tester.pump(_frame);
      // Prime tangentially — perpendicular to the corner's diagonal — so the
      // handle commits to rotating, and far enough to clear the pan slop.
      const double prime = 0.6;
      await gesture.moveTo(_toScreen(tester, pointAt(cornerAngle + prime)));
      await tester.pump(_frame);

      final double baseAngle = controller.getById(_itemId)!.angle;

      final List<double> angles = <double>[];
      for (int i = 1; i <= steps; i++) {
        final double swept = totalSweep * i / steps;
        await gesture.moveTo(
          _toScreen(tester, pointAt(cornerAngle + prime + swept)),
        );
        await tester.pump(_frame);
        angles.add(controller.getById(_itemId)!.angle - baseAngle);
      }
      await gesture.up();
      await tester.pump(_frame);
      return angles;
    }

    testWidgets('a full turn never jumps, not even at the branch cut', (
      WidgetTester tester,
    ) async {
      const int steps = 48;
      const double total = 2 * math.pi;
      final List<double> angles = await sweep(
        tester,
        totalSweep: total,
        steps: steps,
        radius: 170,
      );

      double previous = 0;
      for (int i = 0; i < angles.length; i++) {
        expect(
          angles[i] - previous,
          closeTo(total / steps, 1e-6),
          reason: 'step ${i + 1} did not advance by exactly one increment',
        );
        previous = angles[i];
      }
      expect(angles.last, moreOrLessEquals(total, epsilon: 1e-6));
    });

    testWidgets('rotating backwards past the branch cut is symmetric', (
      WidgetTester tester,
    ) async {
      const double total = -2 * math.pi;
      final List<double> angles = await sweep(
        tester,
        totalSweep: total,
        steps: 32,
        radius: 170,
      );
      expect(angles.last, moreOrLessEquals(total, epsilon: 1e-6));
    });

    testWidgets('a quarter turn close to the centre', (
      WidgetTester tester,
    ) async {
      final List<double> angles = await sweep(
        tester,
        totalSweep: math.pi / 2,
        steps: 8,
        radius: 150,
      );
      expect(angles.last, moreOrLessEquals(math.pi / 2, epsilon: 1e-6));
    });

    testWidgets('a quarter turn far from the centre turns just as far', (
      WidgetTester tester,
    ) async {
      final List<double> angles = await sweep(
        tester,
        totalSweep: math.pi / 2,
        steps: 8,
        radius: 340,
      );
      expect(angles.last, moreOrLessEquals(math.pi / 2, epsilon: 1e-6));
    });

    testWidgets('consecutive turns each start from the angle already held', (
      WidgetTester tester,
    ) async {
      const Offset center = Offset(400, 300);
      const double radius = 200;
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        item: _shape(size: const Size(200, 200), offset: center),
      );

      Future<void> quarterTurn() async {
        final double base = controller.getById(_itemId)!.angle;
        // The corner travels with the item, so re-derive it every time.
        final Offset corner = _corner(
          controller.getById(_itemId)!,
          const Offset(1, -1),
        );
        final double cornerAngle = math.atan2(
          corner.dy - center.dy,
          corner.dx - center.dx,
        );
        Offset pointAt(double angle) =>
            center + Offset(math.cos(angle), math.sin(angle)) * radius;

        final TestGesture gesture = await tester.startGesture(
          _toScreen(tester, corner),
        );
        await tester.pump(_frame);
        await gesture.moveTo(_toScreen(tester, pointAt(cornerAngle + 0.6)));
        await tester.pump(_frame);
        for (int i = 1; i <= 8; i++) {
          await gesture.moveTo(
            _toScreen(tester, pointAt(cornerAngle + 0.6 + math.pi / 2 * i / 8)),
          );
          await tester.pump(_frame);
        }
        await gesture.up();
        await tester.pump(_frame);

        expect(
          controller.getById(_itemId)!.angle - base,
          moreOrLessEquals(math.pi / 2, epsilon: 0.02),
        );
      }

      await quarterTurn();
      await quarterTurn();
      expect(
        controller.getById(_itemId)!.angle,
        moreOrLessEquals(math.pi, epsilon: 0.04),
      );
    });
  });

  group('corner handle gesture split', () {
    Future<StackItem<StackItemContent>> dragCorner(
      WidgetTester tester, {
      required Offset direction,
    }) async {
      const Size size = Size(200, 200);
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        item: _shape(size: size, offset: const Offset(400, 300)),
      );
      final Offset corner = _corner(
        controller.getById(_itemId)!,
        const Offset(1, -1),
      );

      final TestGesture gesture = await tester.startGesture(
        _toScreen(tester, corner),
      );
      await tester.pump(_frame);
      // The first move only buys the recognizer out of the pan slop; the
      // second is the one that reaches the handle.
      await gesture.moveBy(direction * _panSlop * 1.5);
      await tester.pump(_frame);
      await gesture.moveBy(direction * _panSlop * 1.5);
      await tester.pump(_frame);
      await gesture.up();
      await tester.pump(_frame);
      return controller.getById(_itemId)!;
    }

    testWidgets('a drag along the diagonal resizes', (
      WidgetTester tester,
    ) async {
      // Top-right corner of a square: out is up and to the right.
      final StackItem<StackItemContent> item = await dragCorner(
        tester,
        direction: const Offset(0.707, -0.707),
      );
      expect(item.angle, moreOrLessEquals(0));
      expect(item.size.width, greaterThan(200));
    });

    testWidgets('a drag across the diagonal rotates', (
      WidgetTester tester,
    ) async {
      final StackItem<StackItemContent> item = await dragCorner(
        tester,
        direction: const Offset(0.707, 0.707),
      );
      expect(item.size, const Size(200, 200));
      expect(item.angle.abs(), greaterThan(0.1));
    });
  });
}
