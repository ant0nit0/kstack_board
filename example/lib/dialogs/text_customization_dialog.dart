import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class TextCustomizationDialog extends StatefulWidget {
  final StackTextItem item;
  final Function(TextItemContent) onSave;

  const TextCustomizationDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  _TextCustomizationDialogState createState() =>
      _TextCustomizationDialogState();
}

class _TextCustomizationDialogState extends State<TextCustomizationDialog> {
  late TextEditingController _textController;

  // Text properties
  String _fontFamily = 'Roboto';
  double _fontSize = 16.0;
  FontWeight _fontWeight = FontWeight.normal;
  FontStyle _fontStyle = FontStyle.normal;
  bool _isUnderlined = false;
  Color _textColor = Colors.black;
  bool _useGradientText = false;
  Gradient? _textGradient;

  // Stroke
  Color _strokeColor = Colors.transparent;
  double _strokeWidth = 0.0;

  // Shadow
  Color _shadowColor = Colors.black54;
  Offset _shadowOffset = const Offset(1, 1);
  double _shadowBlurRadius = 2.0;
  double _shadowSpreadRadius = 0.0;

  // Arc and spacing
  double _arcDegree = 0.0;
  double _letterSpacing = 0.0;
  double _wordSpacing = 0.0;
  double _lineHeight = 1.0;

  // Background and border
  Color? _backgroundColor;
  Color? _borderColor;
  double _borderWidth = 0.0;

  // Transform and alignment
  double _opacity = 1.0;
  EdgeInsets _padding = EdgeInsets.zero;
  EdgeInsets _margin = EdgeInsets.zero;
  double _skewX = 0.0;
  double _skewY = 0.0;
  TextAlign _horizontalAlignment = TextAlign.center;
  MainAxisAlignment _verticalAlignment = MainAxisAlignment.center;
  bool _flipHorizontally = false;
  bool _flipVertically = false;

  int _selectedTab = 0;

  // Google Fonts list (20 popular fonts)
  final List<String> _fontFamilies = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Oswald',
    'Raleway',
    'Poppins',
    'Merriweather',
    'Ubuntu',
    'Playfair Display',
    'Nunito',
    'PT Sans',
    'Crimson Text',
    'Libre Baskerville',
    'Dancing Script',
    'Pacifico',
    'Lobster',
    'Great Vibes',
    'Indie Flower'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromItem();
  }

  void _initializeFromItem() {
    final content = widget.item.content;
    if (content != null) {
      _textController = TextEditingController(text: content.data ?? '');
      _fontFamily = content.fontFamily ?? 'Roboto';
      _fontSize = content.fontSize;
      _fontWeight = content.fontWeight ?? FontWeight.normal;
      _fontStyle = content.fontStyle ?? FontStyle.normal;
      _isUnderlined = content.isUnderlined;
      _textColor = content.textColor ?? Colors.black;
      _textGradient = content.textGradient;
      _useGradientText = content.textGradient != null;
      _strokeColor = content.strokeColor ?? Colors.transparent;
      _strokeWidth = content.strokeWidth;
      _shadowColor = content.shadowColor ?? Colors.black54;
      _shadowOffset = content.shadowOffset ?? const Offset(1, 1);
      _shadowBlurRadius = content.shadowBlurRadius;
      _shadowSpreadRadius = content.shadowSpreadRadius;
      _arcDegree = content.arcDegree;
      _letterSpacing = content.letterSpacing;
      _wordSpacing = content.wordSpacing;
      _lineHeight = content.lineHeight;
      _backgroundColor = content.backgroundColor;
      _borderColor = content.borderColor;
      _borderWidth = content.borderWidth;
      _opacity = content.opacity;
      _padding = content.padding ?? EdgeInsets.zero;
      _margin = content.margin ?? EdgeInsets.zero;
      _skewX = content.skewX;
      _skewY = content.skewY;
      _horizontalAlignment = content.horizontalAlignment;
      _verticalAlignment = content.verticalAlignment;
      _flipHorizontally = content.flipHorizontally;
      _flipVertically = content.flipVertically;
    } else {
      _textController = TextEditingController(text: 'Sample Text');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Text Customization',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Text Input
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Text Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Preview
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(child: _buildPreviewText()),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTabButton('Font', 0, Icons.font_download),
                  _buildTabButton('Style', 1, Icons.format_paint),
                  _buildTabButton('Effects', 2, Icons.auto_awesome),
                  _buildTabButton('Layout', 3, Icons.view_agenda),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _buildTabContent(),
            ),

            // Buttons
            const SizedBox(height: 16),
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
        return _buildFontTab();
      case 1:
        return _buildStyleTab();
      case 2:
        return _buildEffectsTab();
      case 3:
        return _buildLayoutTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFontTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font Family
          const Text('Font Family',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _fontFamilies.length,
              itemBuilder: (context, index) {
                final font = _fontFamilies[index];
                return GestureDetector(
                  onTap: () => setState(() => _fontFamily = font),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _fontFamily == font
                            ? Colors.blue
                            : Colors.grey[300]!,
                        width: _fontFamily == font ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        font,
                        style: GoogleFonts.getFont(font, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Font Size
          const Text('Font Size',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 8,
                  max: 100,
                  divisions: 92,
                  label: _fontSize.toInt().toString(),
                  onChanged: (value) => setState(() => _fontSize = value),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text('${_fontSize.toInt()}px'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Font Weight
          const Text('Font Weight',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FontWeight.w100,
              FontWeight.w300,
              FontWeight.normal,
              FontWeight.w500,
              FontWeight.w600,
              FontWeight.bold,
              FontWeight.w800,
              FontWeight.w900,
            ]
                .map((weight) => ChoiceChip(
                      label: Text('${weight.index + 1}00'),
                      selected: _fontWeight == weight,
                      onSelected: (selected) =>
                          setState(() => _fontWeight = weight),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format Options
          const Text('Format', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Bold'),
            value: _fontWeight == FontWeight.bold,
            onChanged: (value) => setState(() =>
                _fontWeight = value! ? FontWeight.bold : FontWeight.normal),
          ),
          CheckboxListTile(
            title: const Text('Italic'),
            value: _fontStyle == FontStyle.italic,
            onChanged: (value) => setState(() =>
                _fontStyle = value! ? FontStyle.italic : FontStyle.normal),
          ),
          CheckboxListTile(
            title: const Text('Underline'),
            value: _isUnderlined,
            onChanged: (value) => setState(() => _isUnderlined = value!),
          ),
          const SizedBox(height: 16),

          // Text Color
          const Text('Text Color',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: _useGradientText,
                onChanged: (value) => setState(() => _useGradientText = value),
              ),
              Text(_useGradientText ? 'Gradient' : 'Solid Color'),
            ],
          ),
          const SizedBox(height: 8),

          if (!_useGradientText) ...[
            // Solid Colors
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.black,
                Colors.white,
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
              ]
                  .map((color) => GestureDetector(
                        onTap: () => setState(() => _textColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _textColor == color
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: _textColor == color ? 3 : 1,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ] else ...[
            // Gradient Options
            Text('Gradient Presets'),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  final gradients = [
                    const LinearGradient(colors: [Colors.red, Colors.orange]),
                    const LinearGradient(colors: [Colors.blue, Colors.purple]),
                    const LinearGradient(colors: [Colors.green, Colors.teal]),
                    const LinearGradient(colors: [Colors.pink, Colors.purple]),
                    const LinearGradient(
                        colors: [Colors.yellow, Colors.orange]),
                    const LinearGradient(colors: [Colors.indigo, Colors.blue]),
                  ];
                  final gradient = gradients[index];
                  return GestureDetector(
                    onTap: () => setState(() => _textGradient = gradient),
                    child: Container(
                      width: 60,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _textGradient == gradient
                              ? Colors.blue
                              : Colors.grey[300]!,
                          width: _textGradient == gradient ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Opacity
          const Text('Opacity', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _opacity,
            min: 0.1,
            max: 1.0,
            divisions: 18,
            label: '${(_opacity * 100).toInt()}%',
            onChanged: (value) => setState(() => _opacity = value),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stroke
          const Text('Stroke', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Width:'),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: _strokeWidth.toStringAsFixed(1),
                  onChanged: (value) => setState(() => _strokeWidth = value),
                ),
              ),
            ],
          ),
          if (_strokeWidth > 0) ...[
            const Text('Stroke Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Colors.black,
                Colors.white,
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
              ]
                  .map((color) => GestureDetector(
                        onTap: () => setState(() => _strokeColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _strokeColor == color
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: _strokeColor == color ? 2 : 1,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),

          // Shadow
          const Text('Shadow', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Blur:'),
              Expanded(
                child: Slider(
                  value: _shadowBlurRadius,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: _shadowBlurRadius.toStringAsFixed(1),
                  onChanged: (value) =>
                      setState(() => _shadowBlurRadius = value),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Spread:'),
              Expanded(
                child: Slider(
                  value: _shadowSpreadRadius,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: _shadowSpreadRadius.toStringAsFixed(1),
                  onChanged: (value) =>
                      setState(() => _shadowSpreadRadius = value),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Offset X:'),
              Expanded(
                child: Slider(
                  value: _shadowOffset.dx,
                  min: -10,
                  max: 10,
                  divisions: 20,
                  label: _shadowOffset.dx.toStringAsFixed(1),
                  onChanged: (value) => setState(
                      () => _shadowOffset = Offset(value, _shadowOffset.dy)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Offset Y:'),
              Expanded(
                child: Slider(
                  value: _shadowOffset.dy,
                  min: -10,
                  max: 10,
                  divisions: 20,
                  label: _shadowOffset.dy.toStringAsFixed(1),
                  onChanged: (value) => setState(
                      () => _shadowOffset = Offset(_shadowOffset.dx, value)),
                ),
              ),
            ],
          ),

          // Arc
          const SizedBox(height: 16),
          const Text('Text Arc', style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _arcDegree,
            min: -180,
            max: 180,
            divisions: 72,
            label: '${_arcDegree.toInt()}°',
            onChanged: (value) => setState(() => _arcDegree = value),
          ),

          // Spacing
          const SizedBox(height: 16),
          const Text('Letter Spacing',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _letterSpacing,
            min: -5,
            max: 10,
            divisions: 30,
            label: _letterSpacing.toStringAsFixed(1),
            onChanged: (value) => setState(() => _letterSpacing = value),
          ),

          const Text('Word Spacing',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _wordSpacing,
            min: -5,
            max: 10,
            divisions: 30,
            label: _wordSpacing.toStringAsFixed(1),
            onChanged: (value) => setState(() => _wordSpacing = value),
          ),

          const Text('Line Height',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _lineHeight,
            min: 0.5,
            max: 3.0,
            divisions: 25,
            label: _lineHeight.toStringAsFixed(1),
            onChanged: (value) => setState(() => _lineHeight = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Background
          const Text('Background Color',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _backgroundColor = null),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.clear, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                ...([
                  Colors.white,
                  Colors.black.withValues(alpha: 0.1),
                  Colors.red.withValues(alpha: 0.1),
                  Colors.green.withValues(alpha: 0.1),
                  Colors.blue.withValues(alpha: 0.1),
                  Colors.yellow.withValues(alpha: 0.1),
                ].map((color) => GestureDetector(
                      onTap: () => setState(() => _backgroundColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _backgroundColor == color
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: _backgroundColor == color ? 2 : 1,
                          ),
                        ),
                      ),
                    ))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Border
          const Text('Border', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Width:'),
              Expanded(
                child: Slider(
                  value: _borderWidth,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: _borderWidth.toStringAsFixed(1),
                  onChanged: (value) => setState(() => _borderWidth = value),
                ),
              ),
            ],
          ),
          if (_borderWidth > 0) ...[
            const Text('Border Color:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Colors.black,
                Colors.grey,
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.purple,
              ]
                  .map((color) => GestureDetector(
                        onTap: () => setState(() => _borderColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _borderColor == color
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: _borderColor == color ? 2 : 1,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),

          // Padding & Margin
          const Text('Padding', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('All'),
                    Slider(
                      value: _padding.left,
                      min: 0,
                      max: 20,
                      divisions: 20,
                      onChanged: (value) =>
                          setState(() => _padding = EdgeInsets.all(value)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transform
          const Text('Transform',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Skew X:'),
              Expanded(
                child: Slider(
                  value: _skewX,
                  min: -1,
                  max: 1,
                  divisions: 20,
                  label: _skewX.toStringAsFixed(2),
                  onChanged: (value) => setState(() => _skewX = value),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Skew Y:'),
              Expanded(
                child: Slider(
                  value: _skewY,
                  min: -1,
                  max: 1,
                  divisions: 20,
                  label: _skewY.toStringAsFixed(2),
                  onChanged: (value) => setState(() => _skewY = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Alignment
          const Text('Alignment',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Horizontal:'),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TextAlign.left,
                      TextAlign.center,
                      TextAlign.right,
                      TextAlign.start,
                      TextAlign.end,
                      TextAlign.justify
                    ]
                        .map(
                          (align) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(align.toString().split('.').last),
                              selected: _horizontalAlignment == align,
                              onSelected: (selected) =>
                                  setState(() => _horizontalAlignment = align),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Vertical:'),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      MainAxisAlignment.start,
                      MainAxisAlignment.center,
                      MainAxisAlignment.end
                    ]
                        .map(
                          (align) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(align.toString().split('.').last),
                              selected: _verticalAlignment == align,
                              onSelected: (selected) =>
                                  setState(() => _verticalAlignment = align),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flip
          const Text('Flip', style: TextStyle(fontWeight: FontWeight.bold)),
          Column(
            children: [
              CheckboxListTile(
                title: const Text('Horizontal'),
                value: _flipHorizontally,
                onChanged: (value) =>
                    setState(() => _flipHorizontally = value!),
              ),
              CheckboxListTile(
                title: const Text('Vertical'),
                value: _flipVertically,
                onChanged: (value) => setState(() => _flipVertically = value!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewText() {
    final textWidget = Text(
      _textController.text.isEmpty ? 'Sample Text' : _textController.text,
      style: GoogleFonts.getFont(
        _fontFamily,
        fontSize: _fontSize * 0.7, // Scale down for preview
        fontWeight: _fontWeight,
        fontStyle: _fontStyle,
        color: _useGradientText ? null : _textColor.withValues(alpha: _opacity),
        letterSpacing: _letterSpacing,
        wordSpacing: _wordSpacing,
        height: _lineHeight,
        decoration: _isUnderlined ? TextDecoration.underline : null,
        decorationColor: _textColor,
        shadows: _shadowBlurRadius > 0
            ? [
                Shadow(
                  color: _shadowColor,
                  offset: _shadowOffset,
                  blurRadius: _shadowBlurRadius,
                ),
              ]
            : null,
      ),
      textAlign: _horizontalAlignment,
    );

    Widget result = textWidget;

    // Apply gradient if enabled
    if (_useGradientText && _textGradient != null) {
      result = ShaderMask(
        shaderCallback: (bounds) => _textGradient!.createShader(bounds),
        child: Text(
          _textController.text.isEmpty ? 'Sample Text' : _textController.text,
          style: GoogleFonts.getFont(
            _fontFamily,
            fontSize: _fontSize * 0.7,
            fontWeight: _fontWeight,
            fontStyle: _fontStyle,
            color: Colors.white,
            letterSpacing: _letterSpacing,
            wordSpacing: _wordSpacing,
            height: _lineHeight,
            decoration: _isUnderlined ? TextDecoration.underline : null,
          ),
          textAlign: _horizontalAlignment,
        ),
      );
    }

    // Apply background
    if (_backgroundColor != null) {
      result = Container(
        padding: _padding,
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: _borderWidth > 0
              ? Border.all(color: _borderColor!, width: _borderWidth)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: result,
      );
    }

    // Apply transforms
    if (_skewX != 0 || _skewY != 0 || _flipHorizontally || _flipVertically) {
      result = Transform(
        transform: Matrix4.identity()
          ..setEntry(0, 1, _skewX)
          ..setEntry(1, 0, _skewY)
          ..scale(_flipHorizontally ? -1.0 : 1.0, _flipVertically ? -1.0 : 1.0),
        alignment: Alignment.center,
        child: result,
      );
    }

    return result;
  }

  void _saveSettings() {
    final content = TextItemContent(
      data: _textController.text,
      fontFamily: _fontFamily,
      fontSize: _fontSize,
      fontWeight: _fontWeight,
      fontStyle: _fontStyle,
      isUnderlined: _isUnderlined,
      textColor: _useGradientText ? null : _textColor,
      textGradient: _useGradientText ? _textGradient : null,
      strokeColor: _strokeWidth > 0 ? _strokeColor : null,
      strokeWidth: _strokeWidth,
      shadowColor: _shadowBlurRadius > 0 ? _shadowColor : null,
      shadowOffset: _shadowBlurRadius > 0 ? _shadowOffset : null,
      shadowBlurRadius: _shadowBlurRadius,
      shadowSpreadRadius: _shadowSpreadRadius,
      arcDegree: _arcDegree,
      letterSpacing: _letterSpacing,
      wordSpacing: _wordSpacing,
      lineHeight: _lineHeight,
      backgroundColor: _backgroundColor,
      borderColor: _borderWidth > 0 ? _borderColor : null,
      borderWidth: _borderWidth,
      opacity: _opacity,
      padding: _padding,
      margin: _margin,
      skewX: _skewX,
      skewY: _skewY,
      horizontalAlignment: _horizontalAlignment,
      verticalAlignment: _verticalAlignment,
      flipHorizontally: _flipHorizontally,
      flipVertically: _flipVertically,
      // Keep existing properties
      style: widget.item.content?.style,
      strutStyle: widget.item.content?.strutStyle,
      textAlign: _horizontalAlignment,
      textDirection: widget.item.content?.textDirection,
      locale: widget.item.content?.locale,
      softWrap: widget.item.content?.softWrap,
      overflow: widget.item.content?.overflow,
      textScaleFactor: widget.item.content?.textScaleFactor,
      maxLines: widget.item.content?.maxLines,
      semanticsLabel: widget.item.content?.semanticsLabel,
      textWidthBasis: widget.item.content?.textWidthBasis,
      textHeightBehavior: widget.item.content?.textHeightBehavior,
      selectionColor: widget.item.content?.selectionColor,
    );

    widget.onSave(content);
    Navigator.pop(context);
  }
}
