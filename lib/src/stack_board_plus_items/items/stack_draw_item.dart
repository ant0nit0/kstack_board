import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// StackDrawItem represents a drawing item that can be added to the stack board.
/// It provides full access to all DrawingBoard customization options.

/// A drawing item that can be added to the stack board with full DrawingBoard customization.
///
/// This class exposes all the configuration options available in the underlying DrawingBoard
/// widget, allowing users to fully customize the drawing experience.
///
/// **Basic Usage:**
/// ```dart
/// final drawItem = StackDrawItem(
///   size: Size(400, 400),
///   content: StackDrawContent(controller: DrawingController()),
/// );
/// ```
///
/// **Advanced Customization:**
/// ```dart
/// final drawItem = StackDrawItem(
///   size: Size(400, 400),
///   content: StackDrawContent(controller: DrawingController()),
///   // Enable pan and zoom
///   boardPanEnabled: true,
///   boardScaleEnabled: true,
///   maxScale: 5.0,
///   minScale: 0.5,
///   // Background decoration
///   backgroundColor: Colors.grey[100],
///   borderRadius: BorderRadius.circular(12),
///   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
///   border: Border.all(color: Colors.blue, width: 2),
///   gradient: LinearGradient(colors: [Colors.white, Colors.grey[100]!]),
///   // Custom pointer events
///   onPointerDown: (event) => print('Drawing started at: ${event.localPosition}'),
///   onPointerMove: (event) => print('Drawing at: ${event.localPosition}'),
///   // Scale interaction callbacks
///   onInteractionStart: (details) => print('Scale started'),
///   onInteractionUpdate: (details) => print('Scale: ${details.scale}'),
///   // Visual options
///   clipBehavior: Clip.antiAlias,
///   boardConstrained: false,
///   alignment: Alignment.center,
/// );
/// ```
class StackDrawItem extends StackItem<StackDrawContent> {
  // DrawingBoard customization options
  final bool showDefaultActions;
  final bool showDefaultTools;
  final dynamic Function(PointerDownEvent)? onPointerDown;
  final dynamic Function(PointerMoveEvent)? onPointerMove;
  final dynamic Function(PointerUpEvent)? onPointerUp;
  final Clip clipBehavior;
  final List<DefToolItem> Function(Type, DrawingController)?
  defaultToolsBuilder;
  final Clip boardClipBehavior;
  final PanAxis panAxis;
  final EdgeInsets? boardBoundaryMargin;
  final bool boardConstrained;
  final double maxScale;
  final double minScale;
  final bool boardPanEnabled;
  final bool boardScaleEnabled;
  final double boardScaleFactor;
  final void Function(ScaleEndDetails)? onInteractionEnd;
  final void Function(ScaleStartDetails)? onInteractionStart;
  final void Function(ScaleUpdateDetails)? onInteractionUpdate;
  final TransformationController? transformationController;
  final AlignmentGeometry alignment;

  // Background decoration options
  final Color? backgroundColor;
  final DecorationImage? backgroundImage;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final BlendMode? backgroundBlendMode;
  final BoxShape shape;

  StackDrawItem({
    required StackDrawContent super.content,
    super.id,
    super.angle = null,
    required super.size,
    super.offset,
    super.lockZOrder = null,
    super.status = null,
    super.flipX = false,
    super.flipY = false,
    super.locked = false,
    super.opacity = 1,
    this.showDefaultActions = false,
    this.showDefaultTools = false,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.clipBehavior = Clip.antiAlias,
    this.defaultToolsBuilder,
    this.boardClipBehavior = Clip.hardEdge,
    this.panAxis = PanAxis.free,
    this.boardBoundaryMargin,
    this.boardConstrained = false,
    this.maxScale = 20,
    this.minScale = 0.2,
    this.boardPanEnabled = true,
    this.boardScaleEnabled = true,
    this.boardScaleFactor = 200.0,
    this.onInteractionEnd,
    this.onInteractionStart,
    this.onInteractionUpdate,
    this.transformationController,
    this.alignment = Alignment.topCenter,
    // Background decoration options
    this.backgroundColor,
    this.backgroundImage,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.backgroundBlendMode,
    this.shape = BoxShape.rectangle,
  });

  @override
  StackDrawItem copyWith({
    double? opacity,
    bool? flipX,
    bool? flipY,
    bool? locked,
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    StackDrawContent? content,
    // DrawingBoard options
    bool? showDefaultActions,
    bool? showDefaultTools,
    dynamic Function(PointerDownEvent)? onPointerDown,
    dynamic Function(PointerMoveEvent)? onPointerMove,
    dynamic Function(PointerUpEvent)? onPointerUp,
    Clip? clipBehavior,
    List<DefToolItem> Function(Type, DrawingController)? defaultToolsBuilder,
    Clip? boardClipBehavior,
    PanAxis? panAxis,
    EdgeInsets? boardBoundaryMargin,
    bool? boardConstrained,
    double? maxScale,
    double? minScale,
    bool? boardPanEnabled,
    bool? boardScaleEnabled,
    double? boardScaleFactor,
    void Function(ScaleEndDetails)? onInteractionEnd,
    void Function(ScaleStartDetails)? onInteractionStart,
    void Function(ScaleUpdateDetails)? onInteractionUpdate,
    TransformationController? transformationController,
    AlignmentGeometry? alignment,
    // Background decoration options
    Color? backgroundColor,
    DecorationImage? backgroundImage,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape? shape,
  }) {
    return StackDrawItem(
      id: id,
      opacity: opacity ?? this.opacity,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      content: content ?? this.content!,
      // DrawingBoard options
      showDefaultActions: showDefaultActions ?? this.showDefaultActions,
      showDefaultTools: showDefaultTools ?? this.showDefaultTools,
      onPointerDown: onPointerDown ?? this.onPointerDown,
      onPointerMove: onPointerMove ?? this.onPointerMove,
      onPointerUp: onPointerUp ?? this.onPointerUp,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      defaultToolsBuilder: defaultToolsBuilder ?? this.defaultToolsBuilder,
      boardClipBehavior: boardClipBehavior ?? this.boardClipBehavior,
      panAxis: panAxis ?? this.panAxis,
      boardBoundaryMargin: boardBoundaryMargin ?? this.boardBoundaryMargin,
      boardConstrained: boardConstrained ?? this.boardConstrained,
      maxScale: maxScale ?? this.maxScale,
      minScale: minScale ?? this.minScale,
      boardPanEnabled: boardPanEnabled ?? this.boardPanEnabled,
      boardScaleEnabled: boardScaleEnabled ?? this.boardScaleEnabled,
      boardScaleFactor: boardScaleFactor ?? this.boardScaleFactor,
      onInteractionEnd: onInteractionEnd ?? this.onInteractionEnd,
      onInteractionStart: onInteractionStart ?? this.onInteractionStart,
      onInteractionUpdate: onInteractionUpdate ?? this.onInteractionUpdate,
      transformationController:
          transformationController ?? this.transformationController,
      alignment: alignment ?? this.alignment,
      // Background decoration options
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
      boxShadow: boxShadow ?? this.boxShadow,
      gradient: gradient ?? this.gradient,
      backgroundBlendMode: backgroundBlendMode ?? this.backgroundBlendMode,
      shape: shape ?? this.shape,
    );
  }
}
