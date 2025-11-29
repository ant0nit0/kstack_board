import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

import '../common/constants.dart';
import '../models/color_stack_item.dart';

mixin StackItemManagerMixin {
  late StackBoardPlusController boardController;

  /// Add text item
  void addTextItem() {
    boardController.addItem(
      StackTextItem(
        size: const Size(200, 100),
        content: TextItemContent(
          data: 'Sample Text',
        ),
      ),
      offset: Offset(300, 40),
    );
  }

  /// Add custom item
  void addCustomItem() {
    final Color color =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];
    boardController.addItem(
      ColorStackItem(
        size: const Size.square(100),
        content: ColorContent(color: color),
      ),
    );
  }

  /// Add custom item
  Future<void> generateFromJson(BuildContext context) async {
    final String jsonString =
        (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (jsonString.isEmpty) {
      _showAlertDialog(
          context: context,
          title: 'Clipboard is empty',
          content: 'Please copy the json string to the clipboard first');
      return;
    }
    try {
      final List<dynamic> items = jsonDecode(jsonString) as List<dynamic>;

      for (final dynamic item in items) {
        if (item['type'] == 'StackTextItem') {
          boardController.addItem(
            StackTextItem.fromJson(item),
          );
        } else if (item['type'] == 'StackImageItem') {
          boardController.addItem(
            StackImageItem.fromJson(item),
          );
        }
      }
    } catch (e) {
      _showAlertDialog(context: context, title: 'Error', content: e.toString());
    }
  }

  /// get json
  Future<void> getJson(BuildContext context) async {
    final String json = jsonEncode(boardController.getAllData());
    Clipboard.setData(ClipboardData(text: json));
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.code, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text(
                'Export JSON Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'JSON data copied to clipboard!',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Preview:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        json,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addImageFromGalleryItem() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedImage == null) return;

      final File imageFile = File(pickedImage.path);

      final imageItem = StackImageItem(
        size: const Size(300, 300),
        content: ImageItemContent(
          file: imageFile,
        ),
      );

      boardController.addItem(imageItem);
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void addSvgItem() {
    // Example SVG string - a simple star * replace the image in constants.dart with this
    String svgString = SVG_ASSET_IMAGE_NAME;

    final svgItem = StackImageItem.svg(
      svgString: svgString,
      size: const Size(150, 150),
      fit: BoxFit.contain,
      semanticLabel: 'Golden Star',
    );

    boardController.addItem(svgItem);
  }

  /// Example SVG from network
  void addSvgNetworkItem() {
    final svgNetworkItem = StackImageItem(
      size: const Size(120, 120),
      content: ImageItemContent(
        url: SVG_NETWORK_IMAGE_URL,
      ),
    );

    boardController.addItem(svgNetworkItem);
  }

  /// Example SVG from asset
  void addAssetItem() {
    final svgAssetItem = StackImageItem(
      size: const Size(120, 120),
      content: ImageItemContent(
        assetName: ASSET_IMAGE_NAME,
      ),
    );

    boardController.addItem(svgAssetItem);
  }

  /// Example for image from Network
  void addNetworkItem() {
    final networkItem = StackImageItem(
      size: const Size(120, 120),
      content: ImageItemContent(
        url: NETWORK_IMAGE_URL,
      ),
    );

    boardController.addItem(networkItem);
  }

  /// Add shape item with customizable properties
  void addShapeItem() {
    // Create a default shape item with random color and size variation
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber
    ];

    final shapes = [
      StackShapeType.rectangle,
      StackShapeType.circle,
      StackShapeType.roundedRectangle,
      StackShapeType.star,
      StackShapeType.polygon,
      StackShapeType.heart,
      StackShapeType.halfMoon,
    ];

    final random = Random();
    final selectedColor = colors[random.nextInt(colors.length)];
    final selectedShape = shapes[random.nextInt(shapes.length)];
    final size = 80.0 + random.nextDouble() * 40; // Random size between 80-120

    final shapeData = StackShapeContent(
      type: selectedShape,
      fillColor: selectedColor.withValues(alpha: 0.7),
      strokeColor: selectedColor,
      strokeWidth: 2.0,
      opacity: 1.0,
      tilt: 0.0,
      width: size,
      height: size,
      endpoints: selectedShape == StackShapeType.star ||
              selectedShape == StackShapeType.polygon
          ? 5 // Default 5 points for star/polygon
          : null,
    );

    final shapeItem = StackShapeItem(
      content: shapeData,
      size: Size(size, size),
      offset: Offset.zero, // Will be auto-positioned by controller
    );

    boardController.addItem(shapeItem);
  }

  void addDrawingItem() {
    final drawingController = DrawingController();
    final drawContent = StackDrawContent(controller: drawingController);
    final drawItem = StackDrawItem(
      size: const Size(200, 200),
      content: drawContent,
      // Customize DrawingBoard behavior - these are examples of what users can control
      // showDefaultActions: false,           // Don't show default toolbar
      // showDefaultTools: false,             // Don't show default tool palette
      // boardPanEnabled: true,               // Allow panning the drawing canvas
      // boardScaleEnabled: true,             // Allow zooming the drawing canvas
      maxScale: 5.0, // Maximum zoom level
      minScale: 0.5, // Minimum zoom level
      // boardScaleFactor: 200.0,             // Zoom sensitivity
      // clipBehavior: Clip.antiAlias,        // How to clip the drawing area
      // boardClipBehavior: Clip.hardEdge,    // How to clip the board
      // panAxis: PanAxis.free,               // Allow free panning in all directions
      // boardConstrained: false,             // Don't constrain drawing to board bounds
      // alignment: Alignment.topCenter,      // Align drawing content

      // You can also use gradient backgrounds:
      // gradient: LinearGradient(
      //   colors: [Colors.white, Colors.grey[100]!],
      //   begin: Alignment.topLeft,
      //   end: Alignment.bottomRight,
      // ),
      // Or background images:
      // backgroundImage: DecorationImage(
      //   image: AssetImage('assets/paper_texture.png'),
      //   fit: BoxFit.cover,
      //   opacity: 0.1,
      // ),
      // For circular drawing areas:
      // shape: BoxShape.circle,

      // You can also add pointer event callbacks:
      // onPointerDown: (event) => print('Pointer down: ${event.localPosition}'),
      // onPointerMove: (event) => print('Pointer move: ${event.localPosition}'),
      // onPointerUp: (event) => print('Pointer up: ${event.localPosition}'),
      // Scale interaction callbacks:
      // onInteractionStart: (details) => print('Scale start: ${details.focalPoint}'),
      // onInteractionUpdate: (details) => print('Scale update: ${details.scale}'),
      // onInteractionEnd: (details) => print('Scale end: ${details.velocity}'),
    );
    boardController.addItem(drawItem, status: StackItemStatus.editing);
  }

  void _showAlertDialog(
      {required BuildContext context,
      required String title,
      required String content}) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
