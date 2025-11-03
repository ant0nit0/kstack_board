import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// A widget that renders a drawing canvas for [StackDrawItem].
/// 
/// This widget uses all the DrawingBoard configuration options that are stored
/// in the [StackDrawItem] to provide a fully customizable drawing experience.
/// 
/// All DrawingBoard parameters are configured through the [StackDrawItem]:
/// 
/// **Display Options:**
/// - `showDefaultActions`: Show/hide default action buttons
/// - `showDefaultTools`: Show/hide default tool palette
/// - `alignment`: How to align the drawing content
/// 
/// **Interaction Options:**
/// - `boardPanEnabled`: Enable/disable panning the canvas
/// - `boardScaleEnabled`: Enable/disable zooming the canvas
/// - `maxScale`, `minScale`: Zoom limits
/// - `boardScaleFactor`: Zoom sensitivity
/// - `panAxis`: Restrict panning to specific axes
/// 
/// **Rendering Options:**
/// - `clipBehavior`: How to clip the drawing area
/// - `boardClipBehavior`: How to clip the board
/// - `boardConstrained`: Whether to constrain drawing to board bounds
/// - `boardBoundaryMargin`: Margin around the board boundary
/// 
/// **Background Decoration:**
/// - `backgroundColor`: Background color
/// - `backgroundImage`: Background image
/// - `border`: Border around the drawing area
/// - `borderRadius`: Rounded corners
/// - `boxShadow`: Drop shadows
/// - `gradient`: Background gradient
/// - `backgroundBlendMode`: How to blend background elements
/// - `shape`: Rectangle or circle shape
/// 
/// **Event Callbacks:**
/// - `onPointerDown`, `onPointerMove`, `onPointerUp`: Pointer events
/// - `onInteractionStart`, `onInteractionUpdate`, `onInteractionEnd`: Scale events
/// - `transformationController`: For external transformation control
/// - `defaultToolsBuilder`: Custom tool builder function
/// 
/// Example usage:
/// ```dart
/// final drawItem = StackDrawItem(
///   size: Size(400, 400),
///   content: StackDrawContent(controller: DrawingController()),
///   boardScaleEnabled: true,
///   maxScale: 5.0,
///   backgroundColor: Colors.grey[100],
///   borderRadius: BorderRadius.circular(12),
///   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
///   onPointerDown: (event) => print('Drawing started'),
/// );
/// ```
class StackDrawCase extends StatelessWidget {
  final StackDrawItem item;
  final void Function(Offset)? onMove;
  final void Function(Size)? onResize;

  const StackDrawCase({
    super.key,
    required this.item,
    this.onMove,
    this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    final controller = StackBoardPlusConfig.of(context).controller;
    return SizedBox(
      width: item.size.width,
      height: item.size.height,
      child: DrawingBoard(
        controller: item.content!.controller,
        background: Container(
          width: item.size.width,
          height: item.size.height,
          decoration: BoxDecoration(
            color: item.backgroundColor ?? Colors.transparent,
            image: item.backgroundImage,
            border: item.border,
            borderRadius: item.borderRadius,
            boxShadow: item.boxShadow,
            gradient: item.gradient,
            backgroundBlendMode: item.backgroundBlendMode,
            shape: item.shape,
          ),
        ),
        showDefaultActions: item.showDefaultActions,
        showDefaultTools: item.showDefaultTools,
        // onPointerDown: (event) {
        //   controller.updateBasic(item.id, status: StackItemStatus.drawing);
        //   if (item.onPointerDown != null) item.onPointerDown!(event);
        // },
        onPointerMove: (event) {
          controller.updateBasic(item.id,status: StackItemStatus.drawing);
          if (item.onPointerMove != null) item.onPointerMove!(event);
        },
        // onPointerUp: (event) {
        //   controller.updateBasic(item.id, status: StackItemStatus.drawing);
        //   if (item.onPointerUp != null) item.onPointerUp!(event);
        // },
        
        clipBehavior: item.clipBehavior,
        defaultToolsBuilder: item.defaultToolsBuilder,
        boardClipBehavior: item.boardClipBehavior,
        panAxis: item.panAxis,
        boardBoundaryMargin: item.boardBoundaryMargin,
        boardConstrained: item.boardConstrained,
        maxScale: item.maxScale,
        minScale: item.minScale,
        boardPanEnabled: item.boardPanEnabled,
        boardScaleEnabled: item.boardScaleEnabled,
        boardScaleFactor: item.boardScaleFactor,
        onInteractionEnd: item.onInteractionEnd,
        onInteractionStart: item.onInteractionStart,
        onInteractionUpdate: item.onInteractionUpdate,
        transformationController: item.transformationController,
        alignment: item.alignment,
      ),
    );
  }
}
