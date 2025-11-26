import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// Dialog for configuring snap behavior
class SnapConfigDialog extends StatefulWidget {
  const SnapConfigDialog({
    super.key,
    required this.initialConfig,
    required this.onSave,
  });

  final SnapConfig initialConfig;
  final void Function(SnapConfig) onSave;

  @override
  State<SnapConfigDialog> createState() => _SnapConfigDialogState();
}

class _SnapConfigDialogState extends State<SnapConfigDialog> {
  late bool _enabled;
  late double _snapThreshold;
  late int _horizontalDivisions;
  late int _verticalDivisions;
  late bool _snapToItems;
  late bool _snapToBoardEdges;
  late bool _snapToGrid;
  late bool _showAllSnapLines;
  late Color _snapLineColor;
  late double _snapLineWidth;
  late double _snapLineOpacity;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialConfig.enabled;
    _snapThreshold = widget.initialConfig.snapThreshold;
    _horizontalDivisions = widget.initialConfig.horizontalDivisions;
    _verticalDivisions = widget.initialConfig.verticalDivisions;
    _snapToItems = widget.initialConfig.snapToItems;
    _snapToBoardEdges = widget.initialConfig.snapToBoardEdges;
    _snapToGrid = widget.initialConfig.snapToGrid;
    _showAllSnapLines = widget.initialConfig.showAllSnapLines;
    _snapLineColor = widget.initialConfig.snapLineColor;
    _snapLineWidth = widget.initialConfig.snapLineWidth;
    _snapLineOpacity = widget.initialConfig.snapLineOpacity;
  }

  void _save() {
    widget.onSave(
      SnapConfig(
        enabled: _enabled,
        snapThreshold: _snapThreshold,
        horizontalDivisions: _horizontalDivisions,
        verticalDivisions: _verticalDivisions,
        snapToItems: _snapToItems,
        snapToBoardEdges: _snapToBoardEdges,
        snapToGrid: _snapToGrid,
        showAllSnapLines: _showAllSnapLines,
        snapLineColor: _snapLineColor,
        snapLineWidth: _snapLineWidth,
        snapLineOpacity: _snapLineOpacity,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.grid_on, color: Colors.blue[600], size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Snap Configuration',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Enable/Disable toggle
              SwitchListTile(
                title: const Text(
                  'Enable Snap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Enable or disable snap functionality',
                  style: TextStyle(fontSize: 12),
                ),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),

              // Snap Threshold
              _buildSectionTitle('Snap Threshold'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _snapThreshold,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      label: _snapThreshold.toStringAsFixed(1),
                      onChanged: _enabled
                          ? (value) => setState(() => _snapThreshold = value)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Text(
                      _snapThreshold.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  'Distance threshold for snapping (0 = no snap, larger = more lenient)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              // Grid Divisions
              _buildSectionTitle('Grid Divisions'),
              const SizedBox(height: 8),

              // Horizontal Divisions
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Horizontal Divisions:',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: Slider(
                      value: _horizontalDivisions.toDouble(),
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: _horizontalDivisions.toString(),
                      onChanged: _enabled && _snapToGrid
                          ? (value) => setState(
                                () => _horizontalDivisions = value.toInt(),
                              )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: Text(
                      _horizontalDivisions.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              // Vertical Divisions
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Vertical Divisions:',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: Slider(
                      value: _verticalDivisions.toDouble(),
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: _verticalDivisions.toString(),
                      onChanged: _enabled && _snapToGrid
                          ? (value) => setState(
                                () => _verticalDivisions = value.toInt(),
                              )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 50,
                    child: Text(
                      _verticalDivisions.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Snap Options
              _buildSectionTitle('Snap Options'),
              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text(
                  'Snap to Items',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Snap to edges of other items',
                  style: TextStyle(fontSize: 12),
                ),
                value: _snapToItems,
                onChanged: _enabled
                    ? (value) => setState(() => _snapToItems = value)
                    : null,
                contentPadding: EdgeInsets.zero,
              ),

              SwitchListTile(
                title: const Text(
                  'Snap to Board Edges',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Snap to board boundaries',
                  style: TextStyle(fontSize: 12),
                ),
                value: _snapToBoardEdges,
                onChanged: _enabled
                    ? (value) => setState(() => _snapToBoardEdges = value)
                    : null,
                contentPadding: EdgeInsets.zero,
              ),

              SwitchListTile(
                title: const Text(
                  'Snap to Grid',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Snap to grid divisions',
                  style: TextStyle(fontSize: 12),
                ),
                value: _snapToGrid,
                onChanged: _enabled
                    ? (value) => setState(() => _snapToGrid = value)
                    : null,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Display All Snap Lines Section
              _buildSectionTitle('Display All Snap Lines'),
              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text(
                  'Show All Snap Lines',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Display all potential snap lines as a grid overlay',
                  style: TextStyle(fontSize: 12),
                ),
                value: _showAllSnapLines,
                onChanged: _enabled
                    ? (value) => setState(() => _showAllSnapLines = value)
                    : null,
                contentPadding: EdgeInsets.zero,
              ),

              if (_showAllSnapLines) ...[
                const SizedBox(height: 16),

                // Line Color
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Line Color:',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showColorPicker(),
                      child: Container(
                        width: 50,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _snapLineColor,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Line Width
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Line Width:',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _snapLineWidth,
                        min: 0.5,
                        max: 5.0,
                        divisions: 45,
                        label: _snapLineWidth.toStringAsFixed(1),
                        onChanged: _showAllSnapLines
                            ? (value) => setState(() => _snapLineWidth = value)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        _snapLineWidth.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Line Opacity
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Line Opacity:',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _snapLineOpacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label:
                            (_snapLineOpacity * 100).toStringAsFixed(0) + '%',
                        onChanged: _showAllSnapLines
                            ? (value) =>
                                setState(() => _snapLineOpacity = value)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        (_snapLineOpacity * 100).toStringAsFixed(0) + '%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Line Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Common colors
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildColorOption(const Color(0xFFE0E0E0), 'Light Grey'),
                  _buildColorOption(const Color(0xFFBDBDBD), 'Grey'),
                  _buildColorOption(const Color(0xFF9E9E9E), 'Dark Grey'),
                  _buildColorOption(const Color(0xFF2196F3), 'Blue'),
                  _buildColorOption(const Color(0xFF4CAF50), 'Green'),
                  _buildColorOption(const Color(0xFFFF9800), 'Orange'),
                  _buildColorOption(const Color(0xFFF44336), 'Red'),
                  _buildColorOption(const Color(0xFF9C27B0), 'Purple'),
                  _buildColorOption(const Color(0xFF00BCD4), 'Cyan'),
                  _buildColorOption(const Color(0xFFFFEB3B), 'Yellow'),
                  _buildColorOption(Colors.black, 'Black'),
                  _buildColorOption(Colors.white, 'White'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, String label) {
    final bool isSelected = _snapLineColor.toARGB32() == color.toARGB32();
    return GestureDetector(
      onTap: () {
        setState(() {
          _snapLineColor = color;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        width: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
