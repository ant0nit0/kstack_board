import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// `SafeState` posts a zero-duration timer on mount, so frames have to advance
/// real time or the binding trips its "timer still pending" check.
const Duration _frame = Duration(milliseconds: 16);

const Size _boardSize = Size(800, 600);

StackShapeItem _shape(
  String id, {
  Offset offset = const Offset(400, 300),
  Size size = const Size(200, 120),
  bool locked = false,
}) {
  return StackShapeItem(
    id: id,
    size: size,
    offset: offset,
    locked: locked,
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

const Key _badgeKey = Key('lock_badge');

Future<StackBoardPlusController> _pumpBoard(
  WidgetTester tester,
  List<StackItem<StackItemContent>> items,
) async {
  final StackBoardPlusController controller = StackBoardPlusController();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: _boardSize,
            child: StackBoardPlus(
              controller: controller,
              caseStyle: const CaseStyle(showHelperButtons: false),
              customBuilder: (StackItem<StackItemContent> _) =>
                  const ColoredBox(color: Colors.blue),
              lockedBadgeBuilder: (StackItem<StackItemContent> _) =>
                  const SizedBox(key: _badgeKey, width: 20, height: 20),
            ),
          ),
        ),
      ),
    ),
  );
  for (final StackItem<StackItemContent> item in items) {
    controller.addItem(item, status: StackItemStatus.idle);
  }
  await tester.pump(_frame);
  return controller;
}

Future<void> _drag(WidgetTester tester, Offset from, Offset by) async {
  final RenderBox board =
      tester.renderObject(find.byType(StackBoardPlus)) as RenderBox;
  final TestGesture gesture = await tester.startGesture(
    board.localToGlobal(from),
  );
  await tester.pump(_frame);
  for (int i = 0; i < 6; i++) {
    await gesture.moveBy(by / 6);
    await tester.pump(_frame);
  }
  await gesture.up();
  await tester.pump(_frame);
}

void main() {
  group('serialisation', () {
    test('locked survives toJson / fromJson', () {
      final Map<String, dynamic> json = _shape('a', locked: true).toJson();
      expect(json['locked'], isTrue);
      expect(StackShapeItem.fromJson(json).locked, isTrue);
    });

    test('a canvas saved before the lock existed loads unlocked', () {
      final Map<String, dynamic> json = _shape('a').toJson()..remove('locked');
      expect(StackShapeItem.fromJson(json).locked, isFalse);
    });

    test('copyWith keeps the lock unless told otherwise', () {
      final StackShapeItem locked = _shape('a', locked: true);
      expect(locked.copyWith(offset: Offset.zero).locked, isTrue);
      expect(locked.copyWith(locked: false).locked, isFalse);
    });
  });

  group('controller', () {
    test('setItemLocked locks only the item, and undo / redo take it back', () {
      final StackBoardPlusController controller = StackBoardPlusController();
      controller.addItem(_shape('a'));
      controller.setItemLocked('a', true);

      expect(controller.getById('a')!.locked, isTrue);
      expect(controller.getById('a')!.lockZOrder, isFalse);
      expect(controller.isItemLocked('a'), isTrue);

      controller.undo();
      expect(controller.getById('a')!.locked, isFalse);
      controller.redo();
      expect(controller.getById('a')!.locked, isTrue);
    });

    test('setting the same value adds no history step', () {
      final StackBoardPlusController controller = StackBoardPlusController();
      controller.addItem(_shape('a'), addToHistory: false);
      controller.setItemLocked('a', false);
      expect(controller.canUndo, isFalse);
    });

    test('a locked group holds its items, a locked item holds its group', () {
      final StackBoardPlusController controller = StackBoardPlusController();
      controller.addItem(_shape('a', offset: const Offset(200, 200)));
      controller.addItem(_shape('b', offset: const Offset(500, 300)));
      controller.createGroup(itemIds: <String>['a', 'b']);
      final String groupId = controller.getGroupForItem('a')!;

      expect(controller.isItemLocked(groupId), isFalse);

      controller.setItemLocked(groupId, true);
      expect(controller.isItemLocked('a'), isTrue);
      expect(controller.getById('a')!.locked, isFalse);

      controller.setItemLocked(groupId, false);
      controller.setItemLocked('b', true);
      expect(controller.isItemLocked(groupId), isTrue);
      expect(controller.isItemLocked('a'), isFalse);
    });

    test('removeItemIfUnlocked refuses a locked item and a group holding one',
        () {
      final StackBoardPlusController controller = StackBoardPlusController();
      controller.addItem(_shape('a', locked: true));
      expect(controller.removeItemIfUnlocked(controller.getById('a')!), isFalse);
      expect(controller.getById('a'), isNotNull);

      controller.addItem(_shape('b', offset: const Offset(200, 200)));
      controller.addItem(_shape('c', offset: const Offset(500, 300)));
      controller.createGroup(itemIds: <String>['a', 'b']);
      final String groupId = controller.getGroupForItem('a')!;
      expect(
        controller.removeItemIfUnlocked(controller.getById(groupId)!),
        isFalse,
      );
      expect(controller.getById('b'), isNotNull);

      expect(controller.removeItemIfUnlocked(controller.getById('c')!), isTrue);
      expect(controller.getById('c'), isNull);
    });
  });

  group('board', () {
    testWidgets('a picked locked item does not move when dragged', (
      WidgetTester tester,
    ) async {
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        <StackItem<StackItemContent>>[_shape('a', locked: true)],
      );
      controller.selectOne('a');
      await tester.pump(_frame);

      await _drag(tester, const Offset(400, 300), const Offset(120, 80));

      expect(controller.getById('a')!.offset, const Offset(400, 300));
    });

    testWidgets('the same item unlocked moves', (WidgetTester tester) async {
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        <StackItem<StackItemContent>>[_shape('a')],
      );
      controller.selectOne('a');
      await tester.pump(_frame);

      await _drag(tester, const Offset(400, 300), const Offset(120, 80));

      expect(controller.getById('a')!.offset, isNot(const Offset(400, 300)));
    });

    testWidgets('the badge shows on a picked locked item, and goes with the '
        'lock', (WidgetTester tester) async {
      final StackBoardPlusController controller = await _pumpBoard(
        tester,
        <StackItem<StackItemContent>>[_shape('a', locked: true)],
      );
      expect(find.byKey(_badgeKey), findsNothing);

      controller.selectOne('a');
      await tester.pump(_frame);
      expect(find.byKey(_badgeKey), findsOneWidget);

      controller.setItemLocked('a', false);
      await tester.pump(_frame);
      expect(find.byKey(_badgeKey), findsNothing);
    });
  });
}
