import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import 'widgets/snap_guide_provider.dart';
import 'widgets/all_snap_lines_overlay.dart';
import 'core/rotation_snap_config.dart';

class StackBoardPlusConfig extends InheritedWidget {
  const StackBoardPlusConfig({
    super.key,
    required this.controller,
    this.caseStyle,
    this.snapConfig,
    this.rotationSnapConfig,
    this.snapGuideLines = const [],
    required super.child,
  });

  final StackBoardPlusController controller;
  final CaseStyle? caseStyle;
  final SnapConfig? snapConfig;
  final RotationSnapConfig? rotationSnapConfig;
  final List<SnapGuideLine> snapGuideLines;

  static StackBoardPlusConfig of(BuildContext context) {
    final StackBoardPlusConfig? result =
        context.dependOnInheritedWidgetOfExactType<StackBoardPlusConfig>();
    assert(result != null, 'No StackBoardPlusConfig found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant StackBoardPlusConfig oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.caseStyle != caseStyle ||
      oldWidget.snapConfig != snapConfig ||
      oldWidget.rotationSnapConfig != rotationSnapConfig ||
      oldWidget.snapGuideLines != snapGuideLines;
}

/// StackBoardPlus
class StackBoardPlus extends StatelessWidget {
  const StackBoardPlus({
    super.key,
    this.controller,
    this.background,
    this.caseStyle,
    this.customBuilder,
    this.onDel,
    this.onTap,
    this.onSizeChanged,
    this.onOffsetChanged,
    this.onAngleChanged,
    this.onStatusChanged,
    this.actionsBuilder,
    this.borderBuilder,
    this.customActionsBuilder,
    this.snapConfig,
    this.rotationSnapConfig,
    this.elevation = 1.0,
  });

  final StackBoardPlusController? controller;

  /// * background
  final Widget? background;

  /// * case style
  final CaseStyle? caseStyle;

  /// * custom builder
  final Widget? Function(StackItem<StackItemContent> item)? customBuilder;

  /// * delete intercept
  final void Function(StackItem<StackItemContent> item)? onDel;

  /// * onTap item
  final void Function(StackItem<StackItemContent> item)? onTap;

  /// * size changed callback
  /// * return value can control whether to continue
  final bool? Function(StackItem<StackItemContent> item, Size size)?
      onSizeChanged;

  /// * offset changed callback
  /// * return value can control whether to continue
  final bool? Function(StackItem<StackItemContent> item, Offset offset)?
      onOffsetChanged;

  /// * angle changed callback
  /// * return value can control whether to continue
  final bool? Function(StackItem<StackItemContent> item, double angle)?
      onAngleChanged;

  /// * edit status changed callback
  /// * return value can control whether to continue
  final bool? Function(
          StackItem<StackItemContent> item, StackItemStatus operatState)?
      onStatusChanged;

  /// * actions builder
  final Widget Function(StackItemStatus operatState, CaseStyle caseStyle)?
      actionsBuilder;

  /// * border builder
  final Widget Function(StackItemStatus operatState)? borderBuilder;

  final List<Widget> Function(
          StackItem<StackItemContent> item, BuildContext context)?
      customActionsBuilder;

  /// * Snap configuration
  final SnapConfig? snapConfig;

  /// * Rotation snap configuration
  final RotationSnapConfig? rotationSnapConfig;

  /// * elevation for the whole canvas container
  /// defaults to 1.0
  final double elevation;

  StackBoardPlusController get _controller =>
      controller ?? StackBoardPlusController.def();

  @override
  Widget build(BuildContext context) {
    return SnapGuideProvider(
      child: StackBoardPlusConfig(
        controller: _controller,
        caseStyle: caseStyle,
        snapConfig: snapConfig,
        rotationSnapConfig: rotationSnapConfig,
        child: Material(
          elevation: elevation,
          child: GestureDetector(
            onTap: () => _controller.unSelectAll(),
            behavior: HitTestBehavior.opaque,
            child: ExBuilder<StackConfig>(
              valueListenable: _controller,
              shouldRebuild: (StackConfig p, StackConfig n) =>
                  p.indexMap != n.indexMap,
              builder: (StackConfig sc) {
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final Size boardSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final SnapConfig? snapConfig =
                        StackBoardPlusConfig.of(context).snapConfig;
                    return Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        const SizedBox.expand(),
                        if (background != null) background!,
                        // All snap lines overlay (behind items)
                        if (snapConfig != null)
                          AllSnapLinesOverlay(
                            boardSize: boardSize,
                            config: snapConfig,
                            allItems: sc.data,
                          ),
                        for (final StackItem<StackItemContent> item in sc.data)
                          _itemBuilder(item),
                        const SnapGuideLayer(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemBuilder(StackItem<StackItemContent> item) {
    return StackItemCase(
      key: ValueKey<String>(item.id),
      stackItem: item,
      childBuilder: customBuilder,
      caseStyle: caseStyle,
      onDel: () => onDel?.call(item),
      onTap: () => onTap?.call(item),
      onSizeChanged: (Size size) => onSizeChanged?.call(item, size) ?? true,
      onOffsetChanged: (Offset offset) =>
          onOffsetChanged?.call(item, offset) ?? true,
      onAngleChanged: (double angle) =>
          onAngleChanged?.call(item, angle) ?? true,
      onStatusChanged: (StackItemStatus operatState) =>
          onStatusChanged?.call(item, operatState) ?? true,
      actionsBuilder: actionsBuilder,
      borderBuilder: borderBuilder,
      customActionsBuilder: customActionsBuilder,
    );
  }
}
