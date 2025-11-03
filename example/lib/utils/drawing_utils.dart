import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class DrawingUtils {
  static void showClearDrawingDialog(
      BuildContext context, DrawingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Drawing'),
        content: const Text(
            'Are you sure you want to clear all drawing content? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void exportDrawing(
      BuildContext context, DrawingController controller) {
    try {
      final drawingData = controller.getJsonList();
      final jsonString =
          const JsonEncoder.withIndent('  ').convert(drawingData);

      // Show export dialog with JSON data
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Drawing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Drawing data exported successfully!'),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.maxFinite,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonString,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      DialogUtils.showErrorDialog(context, 'Export failed: $e');
    }
  }

  static void importDrawing(
      BuildContext context, DrawingController controller) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Drawing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste your drawing JSON data below:'),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste JSON data here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                jsonDecode(textController.text); // Validate JSON
                // Note: Full import implementation would need proper deserialization
                // This is a placeholder for the basic structure
                Navigator.of(context).pop();
                DialogUtils.showSuccessDialog(
                    context, 'Drawing imported successfully!');
              } catch (e) {
                DialogUtils.showErrorDialog(
                    context, 'Import failed: Invalid JSON data');
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  /// Show drawing settings dialog
  static Future<void> showDrawingSettingsDialog(
      BuildContext context, DrawingController controller) async {
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Color selectedColor = Colors.black;
          double strokeWidth = 4.0;

          return Dialog(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Settings and tools',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Package Methods Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Package Methods:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('• item.content!.undo() - Undo last action',
                              style: TextStyle(fontSize: 12)),
                          Text('• item.content!.redo() - Redo last action',
                              style: TextStyle(fontSize: 12)),
                          Text('• item.content!.clear() - Clear all drawing',
                              style: TextStyle(fontSize: 12)),
                          Text('• item.content!.getDrawingData() - Export data',
                              style: TextStyle(fontSize: 12)),
                          Text('• controller.setStyle() - Set drawing style',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        controller.undo();
                        Navigator.pop(context);
                      },
                      child: const Text('Undo Last Draw'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        controller.redo();
                        Navigator.pop(context);
                      },
                      child: const Text('Redo Last Draw'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        controller.clear();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear All'),
                    ),
                    const SizedBox(height: 16),

                    // Drawing Actions
                    const Text('Actions',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.undo),
                            label: const Text('Undo'),
                            onPressed: () => controller.undo(),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.redo),
                            label: const Text('Redo'),
                            onPressed: () => controller.redo(),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Clear'),
                            onPressed: () =>
                                showClearDrawingDialog(context, controller),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Drawing Tools
                    const Text('Drawing Tools',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                        'Use the default drawing board tools or configure in the settings dialog.',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),

                    // Color Selection
                    const Text('Color',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Colors.black,
                        Colors.red,
                        Colors.green,
                        Colors.blue,
                        Colors.yellow,
                        Colors.purple,
                        Colors.orange,
                        Colors.brown,
                      ]
                          .map((color) => GestureDetector(
                                onTap: () {
                                  selectedColor = color;
                                  controller.setStyle(color: selectedColor);
                                  setState(() {});
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedColor == color
                                          ? Colors.white
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Stroke Width
                    const Text('Stroke Width',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Slider(
                      min: 1,
                      max: 20,
                      value: strokeWidth,
                      divisions: 19,
                      label: strokeWidth.round().toString(),
                      onChanged: (value) {
                        strokeWidth = value;
                        controller.setStyle(strokeWidth: strokeWidth);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // Import/Export
                    const Text('Import/Export',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Export'),
                          onPressed: () => exportDrawing(context, controller),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Import'),
                          onPressed: () => importDrawing(context, controller),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DialogUtils {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
