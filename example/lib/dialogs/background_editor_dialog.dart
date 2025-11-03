import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BackgroundEditorDialog extends StatefulWidget {
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final File? backgroundImage;
  final double backgroundWidth;
  final double backgroundHeight;
  final BoxFit backgroundFit;
  final bool useGradient;
  final bool useImage;
  final double backgroundElevation;
  final Function(Color, Gradient?, File?, double, double, double, BoxFit, bool, bool) onSave;

  const BackgroundEditorDialog({
    super.key,
    required this.backgroundColor,
    this.backgroundGradient,
    this.backgroundImage,
    required this.backgroundWidth,
    required this.backgroundHeight,
    required this.backgroundFit,
    required this.useGradient,
    required this.useImage,
    this.backgroundElevation = 1.0,
    required this.onSave,
  });

  @override
  _BackgroundEditorDialogState createState() => _BackgroundEditorDialogState();
}

class _BackgroundEditorDialogState extends State<BackgroundEditorDialog> {
  late Color _selectedColor;
  late Gradient? _selectedGradient;
  late File? _selectedImage;
  late double _width;
  late double _height;
  late double _elevation;
  late BoxFit _fit;
  late bool _useGradient;
  late bool _useImage;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.backgroundColor;
    _selectedGradient = widget.backgroundGradient;
    _selectedImage = widget.backgroundImage;
    _width = widget.backgroundWidth;
    _height = widget.backgroundHeight;
    _elevation = widget.backgroundElevation;
    _fit = widget.backgroundFit;
    _useGradient = widget.useGradient;
    _useImage = widget.useImage;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Background Editor',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTabButton('Color', 0, Icons.color_lens),
                  _buildTabButton('Gradient', 1, Icons.gradient),
                  _buildTabButton('Image', 2, Icons.image),
                  _buildTabButton('Size', 3, Icons.aspect_ratio),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Content
            Expanded(
              child: _buildTabContent(),
            ),

            // Buttons
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildColorTab();
      case 1:
        return _buildGradientTab();
      case 2:
        return _buildImageTab();
      case 3:
        return _buildSizeTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildColorTab() {
    return Column(
      children: [
        // Color Preview
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(height: 20),
        
        // Predefined Colors
        const Text('Quick Colors', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.white,
            Colors.black,
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.yellow,
            Colors.purple,
            Colors.orange,
            Colors.pink,
            Colors.teal,
            Colors.grey,
            Colors.brown,
          ].map((color) => GestureDetector(
            onTap: () => setState(() {
              _selectedColor = color;
              _useGradient = false;
              _useImage = false;
            }),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedColor == color ? Colors.blue : Colors.grey[300]!,
                  width: _selectedColor == color ? 3 : 1,
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildGradientTab() {
    final gradients = [
      const LinearGradient(colors: [Colors.blue, Colors.purple]),
      const LinearGradient(colors: [Colors.orange, Colors.red]),
      const LinearGradient(colors: [Colors.green, Colors.teal]),
      const LinearGradient(colors: [Colors.pink, Colors.purple]),
      const LinearGradient(colors: [Colors.yellow, Colors.orange]),
      const LinearGradient(colors: [Colors.indigo, Colors.blue]),
    ];

    return Column(
      children: [
        const Text('Gradient Presets', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
            ),
            itemCount: gradients.length,
            itemBuilder: (context, index) {
              final gradient = gradients[index];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedGradient = gradient;
                  _useGradient = true;
                  _useImage = false;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedGradient == gradient ? Colors.blue : Colors.grey[300]!,
                      width: _selectedGradient == gradient ? 3 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageTab() {
    return Column(
      children: [
        // Image Preview
        if (_selectedImage != null)
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: _fit,
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: Colors.grey),
                Text('No image selected', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
        
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _cropImage,
                  icon: const Icon(Icons.crop),
                  label: const Text('Crop'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 20),
        const Text('Image Fit', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        DropdownButtonFormField<BoxFit>(
          initialValue: _fit,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: BoxFit.values.map((fit) {
            return DropdownMenuItem(
              value: fit,
              child: Text(fit.toString().split('.').last),
            );
          }).toList(),
          onChanged: (value) => setState(() => _fit = value!),
        ),
      ],
    );
  }

  Widget _buildSizeTab() {
    return Column(
      children: [
        // Size Preview
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              '${_width.toInt()} × ${_height.toInt()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Width Slider
        const Text('Width', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _width,
          min: 300,
          max: 2000,
          divisions: 34,
          label: _width.toInt().toString(),
          onChanged: (value) => setState(() => _width = value),
        ),
        const SizedBox(height: 10),

        // Height Slider
        const Text('Height', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _height,
          min: 300,
          max: 2000,
          divisions: 34,
          label: _height.toInt().toString(),
          onChanged: (value) => setState(() => _height = value),
        ),
        const SizedBox(height: 5),

        // Elevation Slider
        const Text('Canvas Elevation', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _elevation,
          min: 0,
          max: 24,
          divisions: 24,
          label: _elevation.toStringAsFixed(0),
          onChanged: (value) => setState(() => _elevation = value),
        ),
        const SizedBox(height: 5),

        // Preset Sizes
        const Text('Preset Sizes', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 5,
          runSpacing: 5,

          children: [
            {'name': 'HD', 'width': 1280.0, 'height': 720.0},
            {'name': 'Full HD', 'width': 1920.0, 'height': 1080.0},
            {'name': 'Square', 'width': 800.0, 'height': 800.0},
            {'name': 'A4', 'width': 794.0, 'height': 1123.0},
          ].map((preset) => ElevatedButton(
            onPressed: () => setState(() {
              _width = preset['width'] as double;
              _height = preset['height'] as double;
            }),
            child: Text(preset['name'] as String),
          )).toList(),
        ),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _useImage = true;
        _useGradient = false;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _useImage = true;
        _useGradient = false;
      });
    }
  }

  Future<void> _cropImage() async {
    if (_selectedImage == null) return;

    // For now, we'll just show a message since image_cropper might not be installed
    // In a real implementation, you would use image_cropper package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Crop functionality requires image_cropper package'),
      ),
    );

    /* 
    Uncomment this when image_cropper is properly installed:
    
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _selectedImage!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Background',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(
          title: 'Crop Background',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _selectedImage = File(croppedFile.path);
      });
    }
    */
  }

  void _saveSettings() {
    widget.onSave(
      _selectedColor,
      _selectedGradient,
      _selectedImage,
      _width,
      _height,
      _elevation,
      _fit,
      _useGradient,
      _useImage,
    );
    Navigator.pop(context);
  }
}
