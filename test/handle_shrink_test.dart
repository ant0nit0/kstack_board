import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board_plus/src/stack_item_case/stack_item_case.dart';

/// The rule these tests protect: a selected item must always keep a strip of
/// its own body bare, because that strip is the only thing the drag detector
/// underneath the handles can be grabbed by.
///
/// Handles are sized against the zoom rather than against the item, so on a
/// small item the corners meet in the middle and the item becomes impossible
/// to move — the checkbox at its old 30pt insert size was exactly that.
void main() {
  /// What JuJo actually configures on a small phone at zoom 1.
  const double kScaleHandle = 40.0;
  const double kHitPadding = 6.0;

  /// Body left bare between the two corners on a diagonal, for a handle
  /// scaled by [shrink]. Mirrors the arithmetic in `_childrenStack`: each
  /// corner eats half its own size plus its hit padding, and the rotate corner
  /// is 1.3x the plain one.
  double bareBody(double side, double shrink) {
    final double scale = kScaleHandle * shrink;
    final double padding = kHitPadding * shrink;
    return side - (scale / 2 + padding) - (scale * 1.3 / 2 + padding);
  }

  test('leaves ordinary items completely alone', () {
    for (final double side in <double>[120, 200, 600]) {
      expect(
        handleShrinkFactor(
          itemSize: Size(side, side),
          scaleHandleSize: kScaleHandle,
          hitAreaPadding: kHitPadding,
        ),
        1.0,
        reason: 'a ${side}pt item has room to spare',
      );
    }
  });

  test('shrinks just enough, and no further, at the threshold', () {
    // 40pt handles + 6pt padding spend 58pt between the two corners, so the
    // first size that needs no help is 24 + 58 = 82.
    expect(
      handleShrinkFactor(
        itemSize: const Size(82, 82),
        scaleHandleSize: kScaleHandle,
        hitAreaPadding: kHitPadding,
      ),
      1.0,
    );
    expect(
      handleShrinkFactor(
        itemSize: const Size(81, 81),
        scaleHandleSize: kScaleHandle,
        hitAreaPadding: kHitPadding,
      ),
      lessThan(1.0),
    );
  });

  test('keeps 24pt of body bare wherever it can', () {
    for (final double side in <double>[82, 90, 110, 200]) {
      final double shrink = handleShrinkFactor(
        itemSize: Size(side, side),
        scaleHandleSize: kScaleHandle,
        hitAreaPadding: kHitPadding,
      );
      expect(
        bareBody(side, shrink),
        greaterThanOrEqualTo(24.0 - 0.001),
        reason: '${side}pt item at shrink $shrink',
      );
    }
  });

  test('a too-small item gets grabbable handles rather than nothing', () {
    // 30pt is the size the checkbox used to be inserted at. There is no way to
    // fit 24pt of bare body under two corners here, so the floor applies: the
    // handles stay large enough to hit, and the scale corner is how the reader
    // gets out of being this small.
    final double shrink = handleShrinkFactor(
      itemSize: const Size(30, 30),
      scaleHandleSize: kScaleHandle,
      hitAreaPadding: kHitPadding,
    );
    expect(shrink, 0.35);
    expect(kScaleHandle * shrink, greaterThanOrEqualTo(12.0));
  });

  test('measures the shortest side, not the longest', () {
    // A wide, short item is as hard to grab as a small square one.
    expect(
      handleShrinkFactor(
        itemSize: const Size(400, 30),
        scaleHandleSize: kScaleHandle,
        hitAreaPadding: kHitPadding,
      ),
      handleShrinkFactor(
        itemSize: const Size(30, 30),
        scaleHandleSize: kScaleHandle,
        hitAreaPadding: kHitPadding,
      ),
    );
  });

  test('never divides by zero when the style has no handles at all', () {
    expect(
      handleShrinkFactor(
        itemSize: const Size(10, 10),
        scaleHandleSize: 0,
        hitAreaPadding: 0,
      ),
      1.0,
    );
  });
}
