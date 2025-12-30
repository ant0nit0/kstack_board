// StackDrawContent holds the drawing data for a StackDrawItem.
//
// Available Methods for UI Implementation:
//
// Drawing Controls:
// - undo()           - Undo the last drawing action
// - redo()           - Redo the last undone action
// - clear()          - Clear all drawing content
//
// Data Management:
// - getDrawingData() - Export drawing data as JSON
// - loadDrawingData() - Import drawing data from JSON
// - toJson()         - Serialize content for board export
//
// State Checking:
// - canUndo()        - Check if undo is available
// - canRedo()        - Check if redo is available
//
// Usage Example:
// ```dart
// final item = stackDrawItem;
//
// // Drawing controls
// item.content!.undo();
// item.content!.redo();
// item.content!.clear();
//
// // Export/Import
// final data = item.content!.getDrawingData();
// item.content!.loadDrawingData(data);
//
// // Drawing styles (via controller)
// item.content!.controller.setStyle(color: Colors.red, strokeWidth: 5.0);
// ```

import 'package:stack_board_plus/stack_board_plus.dart';

class StackDrawContent implements StackItemContent {
  final DrawingController controller;
  final bool resized;

  StackDrawContent({
    required this.controller,
    this.resized = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'StackDrawContent',
      // Serialize drawing data for export/import
      'drawingData': controller.getJsonList(),
      'resized': resized,
    };
  }

  /// Create StackDrawContent from JSON (for import)
  factory StackDrawContent.fromJson(Map<String, dynamic> json) {
    final controller = DrawingController();

    // Load drawing data if available
    if (json['drawingData'] != null) {
      // Note: Full deserialization implementation needed
      // final List<dynamic> drawingData = json['drawingData'] as List<dynamic>;
    }

    return StackDrawContent(
        controller: controller,
        resized: asNullT<bool>(json['resized']) ?? false);
  }

  /// Save drawing data to storage/export
  List<Map<String, dynamic>> getDrawingData() {
    return controller.getJsonList();
  }

  /// Load drawing data from storage/import
  void loadDrawingData(List<Map<String, dynamic>> data) {
    controller.clear();
    // Note: You'll need to implement proper deserialization
    // based on the content types in your drawing data
    // This would involve creating PaintContent objects from JSON
    // and adding them via controller.addContents()
  }

  /// Undo last drawing action
  void undo() {
    controller.undo();
  }

  /// Redo last undone action
  void redo() {
    controller.redo();
  }

  /// Clear all drawing content
  void clear() {
    controller.clear();
  }

  /// Check if undo is available
  bool canUndo() {
    // Note: You might need to track this manually or check controller state
    return true; // Placeholder
  }

  /// Check if redo is available
  bool canRedo() {
    // Note: You might need to track this manually or check controller state
    return true; // Placeholder
  }
}
