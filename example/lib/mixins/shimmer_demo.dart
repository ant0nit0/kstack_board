import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ShimmerDemo extends StatefulWidget {
  const ShimmerDemo({super.key});

  @override
  _ShimmerDemoState createState() => _ShimmerDemoState();
}

class _ShimmerDemoState extends State<ShimmerDemo> {
  late StackBoardPlusController _boardController;

  @override
  void initState() {
    super.initState();
    _boardController = StackBoardPlusController();
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  void _addNetworkImage() {
    final networkItem = StackImageItem.url(
      url: 'https://picsum.photos/300/200?random=${DateTime.now().millisecondsSinceEpoch}',
      size: const Size(200, 150),
      offset: const Offset(50, 50),
    );
    _boardController.addItem(networkItem);
  }

  void _addLargeNetworkImage() {
    final largeImageItem = StackImageItem.url(
      url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&q=80',
      size: const Size(250, 200),
      offset: const Offset(100, 200),
    );
    _boardController.addItem(largeImageItem);
  }

  void _addNetworkSvg() {
    final svgItem = StackImageItem.url(
      url: 'https://www.vectorlogo.zone/logos/dartlang/dartlang-official.svg',
      size: const Size(100, 100),
      offset: const Offset(300, 50),
    );
    _boardController.addItem(svgItem);
  }

  void _addSlowLoadingImage() {
    // Add an image with slow loading to test shimmer behavior
    final slowItem = StackImageItem.url(
      url: 'https://httpbin.org/delay/2?url=https://picsum.photos/200/150',
      size: const Size(180, 120),
      offset: const Offset(200, 350),
    );
    _boardController.addItem(slowItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shimmer Fix Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _addNetworkImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Random Image'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addLargeNetworkImage,
                    icon: const Icon(Icons.landscape),
                    label: const Text('Large Image'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addNetworkSvg,
                    icon: const Icon(Icons.code),
                    label: const Text('SVG Image'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addSlowLoadingImage,
                    icon: const Icon(Icons.hourglass_empty),
                    label: const Text('Slow Load'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: StackBoardPlus(
                controller: _boardController,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue[50]!, Colors.white],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Testing Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('1. Add images using the buttons above'),
                Text('2. Once images load, try dragging and moving them'),
                Text('3. The shimmer should NOT flicker during movement'),
                Text('4. Shimmer should only appear during initial loading'),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const ShimmerDemo(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    ),
  ));
}
