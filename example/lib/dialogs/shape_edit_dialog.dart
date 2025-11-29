import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ShapeEditDialog extends StatefulWidget {
  final StackShapeItem item;
  final ValueChanged<StackShapeItem> onUpdate;
  const ShapeEditDialog(
      {super.key, required this.item, required this.onUpdate});

  @override
  State<ShapeEditDialog> createState() => _ShapeEditDialogState();
}

class _ShapeEditDialogState extends State<ShapeEditDialog> {
  late StackShapeContent data;

  @override
  void initState() {
    super.initState();
    data = widget.item.content ??
        StackShapeContent(
          type: StackShapeType.rectangle,
          fillColor: Colors.white,
          strokeColor: Colors.black,
          strokeWidth: 1,
          opacity: 1,
          tilt: 0,
          width: 100,
          height: 100,
        );
  }

  void updateData(StackShapeContent newData) {
    setState(() => data = newData);
  }

  Future<void> _pickColor(Color current, ValueChanged<Color> onColor) async {
    Color color = current;
    final bool picked = await ColorPicker(
      color: color,
      onColorChanged: (Color c) => color = c,
      width: 40,
      height: 40,
      borderRadius: 20,
      heading:
          Text('Select color', style: Theme.of(context).textTheme.titleLarge),
      subheading: Text('Select color shade',
          style: Theme.of(context).textTheme.titleMedium),
      showColorCode: true,
      pickersEnabled: <ColorPickerType, bool>{
        ColorPickerType.both: true,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: true,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(context);
    if (picked) onColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Shape'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shape type
            SizedBox(
              width: 200,
              child: DropdownButton<StackShapeType>(
                value: data.type,
                onChanged: (type) {
                  if (type != null) updateData(data.copyWith(type: type));
                },
                items: StackShapeType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
              ),
            ),
            // Fill color
            Row(
              children: [
                const Text('Fill Color:'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _pickColor(data.fillColor,
                      (c) => updateData(data.copyWith(fillColor: c))),
                  child: _ColorBox(color: data.fillColor),
                ),
              ],
            ),
            // Stroke color
            Row(
              children: [
                const Text('Stroke Color:'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _pickColor(data.strokeColor,
                      (c) => updateData(data.copyWith(strokeColor: c))),
                  child: _ColorBox(color: data.strokeColor),
                ),
              ],
            ),
            // Stroke width
            Row(
              children: [
                const Text('Stroke Width:'),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 20,
                    value: data.strokeWidth,
                    onChanged: (v) => updateData(data.copyWith(strokeWidth: v)),
                  ),
                ),
                Text(data.strokeWidth.toStringAsFixed(1)),
              ],
            ),
            // Opacity
            Row(
              children: [
                const Text('Opacity:'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 1,
                    divisions: 100,
                    value: data.opacity,
                    onChanged: (v) => updateData(data.copyWith(opacity: v)),
                  ),
                ),
                Text('${(data.opacity * 100).toStringAsFixed(0)}%'),
              ],
            ),
            // Tilt
            Row(
              children: [
                const Text('Tilt (deg):'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 360,
                    value: data.tilt,
                    onChanged: (v) => updateData(data.copyWith(tilt: v)),
                  ),
                ),
                Text(data.tilt.toStringAsFixed(0)),
              ],
            ),
            // Size
            Row(
              children: [
                const Text('Width:'),
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 500,
                    value: data.width,
                    onChanged: (v) => updateData(data.copyWith(width: v)),
                  ),
                ),
                Text(data.width.toStringAsFixed(0)),
              ],
            ),
            Row(
              children: [
                const Text('Height:'),
                Expanded(
                  child: Slider(
                    min: 10,
                    max: 500,
                    value: data.height,
                    onChanged: (v) => updateData(data.copyWith(height: v)),
                  ),
                ),
                Text(data.height.toStringAsFixed(0)),
              ],
            ),
            // Flip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Flip:'),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: widget.item.flipX,
                          // Update item directly instead of content
                          onChanged: (v) => widget.onUpdate(
                              widget.item.copyWith(flipX: v ?? false)),
                        ),
                        const Text('Horizontal'),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: widget.item.flipY,
                            onChanged: (v) => widget.onUpdate(
                                widget.item.copyWith(flipY: v ?? false))),
                        const Text('Vertical'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Endpoints (for polygon/star)
            if (data.type == StackShapeType.polygon ||
                data.type == StackShapeType.star)
              Row(
                children: [
                  const Text('Endpoints:'),
                  Expanded(
                    child: Slider(
                      min: 3,
                      max: 12,
                      divisions: 9,
                      value: (data.endpoints ?? 5).toDouble(),
                      onChanged: (v) =>
                          updateData(data.copyWith(endpoints: v.toInt())),
                    ),
                  ),
                  Text((data.endpoints ?? 5).toString()),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(widget.item
                .copyWith(content: data, size: Size(data.width, data.height)));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  const _ColorBox({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
