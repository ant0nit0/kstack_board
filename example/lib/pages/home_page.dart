import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

import '../dialogs/text_customization_dialog.dart';
import '../dialogs/snap_config_dialog.dart';
import '../mixins/background_manager_mixin.dart';
import '../mixins/stack_item_manager_mixin.dart';
import '../models/color_stack_item.dart';
import '../utils/drawing_utils.dart';
import '../widgets/action_button.dart';
import '../widgets/enhanced_stack_text_case.dart';
import '../dialogs/shape_edit_dialog.dart';

import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with BackgroundManagerMixin, StackItemManagerMixin {
  late StackBoardPlusController _boardController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SnapConfig _snapConfig = const SnapConfig();

  Widget _buildLayerPreview(StackItem<StackItemContent> item) {
    const double size = 36;
    if (item is StackTextItem) {
      final String text = (item.content?.data ?? 'Text').toString();
      return Container(
        width: size * 2,
        height: size,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
    }
    if (item is StackImageItem) {
      final content = item.content;
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: size,
          height: size,
          child: FittedBox(
            fit: BoxFit.cover,
            child: content?.svgWidget ??
                (content?.image != null
                    ? Image(image: content!.image!)
                    : const Icon(Icons.image, size: size)),
          ),
        ),
      );
    }
    if (item is ColorStackItem) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: item.content?.color ?? Colors.grey,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12),
        ),
      );
    }
    if (item is StackDrawItem) {
      return const Icon(Icons.brush, size: 20);
    }
    if (item is StackShapeItem) {
      return const Icon(Icons.category, size: 20);
    }
    return const Icon(Icons.layers);
  }

  String _layerLabel(StackItem<StackItemContent> item) {
    if (item is StackTextItem) {
      final String text = (item.content?.data ?? 'Text').toString();
      return text.isEmpty ? 'Text' : text;
    }
    if (item is StackImageItem) {
      final c = item.content;
      return c?.assetName ?? c?.url ?? c?.file?.path.split('/').last ?? 'Image';
    }
    if (item is ColorStackItem) {
      final Color color = item.content?.color ?? Colors.grey;
      String hex =
          color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
      return '#${hex.substring(2)}';
    }
    if (item is StackDrawItem) return 'Drawing';
    if (item is StackShapeItem) return 'Shape';
    return item.runtimeType.toString();
  }

  @override
  void initState() {
    super.initState();
    _boardController = StackBoardPlusController();
    boardController = _boardController; // Set the mixin's controller
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

  /// Delete intercept
  Future<void> _onDel(StackItem<StackItemContent> item) async {
    final bool? r = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                'Delete Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this item? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (r == true) {
      _boardController.removeById(item.id);
    }
  }

  // Text Customization Methods
  void _openTextCustomizationDialog(StackTextItem item) {
    showDialog(
      context: context,
      builder: (context) => TextCustomizationDialog(
        item: item,
        onSave: (updatedContent) {
          setState(() {
            // Create a new item with updated content
            final updatedItem = item.copyWith(content: updatedContent);
            _boardController.removeById(item.id);
            _boardController.addItem(updatedItem);
          });
        },
      ),
    );
  }

  void _showDrawingClearDialog(BuildContext context, StackDrawItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Drawing'),
        content:
            const Text('Are you sure you want to clear all drawing content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              item.content!.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Stack Board Plus Example',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: openBackgroundEditor,
            icon: const Icon(Icons.wallpaper, color: Colors.white),
            tooltip: 'Background Settings',
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => SnapConfigDialog(
                  initialConfig: _snapConfig,
                  onSave: (config) {
                    setState(() {
                      _snapConfig = config;
                    });
                  },
                ),
              );
            },
            icon: const Icon(Icons.grid_on, color: Colors.white),
            tooltip: 'Snap Settings',
          ),
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.layers, color: Colors.white),
            tooltip: 'Layers',
          ),
          IconButton(
            onPressed: () => _boardController.clear(),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'Delete All',
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'Layers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ValueListenableBuilder<StackConfig>(
                  valueListenable: _boardController,
                  builder: (context, stackConfig, _) {
                    final List<StackItem<StackItemContent>> items =
                        List.of(stackConfig.data);
                    // Show top-most first
                    final List<StackItem<StackItemContent>> ordered =
                        items.reversed.toList();
                    return ListView.separated(
                      itemCount: ordered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final StackItem<StackItemContent> item = ordered[index];
                        final int actualIndex =
                            items.indexOf(item); // 0 = bottom, last = top
                        final bool isTop = actualIndex == items.length - 1;
                        final bool isBottom = actualIndex == 0;
                        return ListTile(
                          dense: true,
                          leading: _buildLayerPreview(item),
                          title: Text(_layerLabel(item),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(item.runtimeType.toString(),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'To Bottom',
                                icon: const Icon(Icons.vertical_align_bottom),
                                onPressed: () {
                                  _boardController.moveItemToBottom(item.id);
                                },
                              ),
                              IconButton(
                                tooltip: 'Down',
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: isBottom
                                    ? null
                                    : () {
                                        _boardController
                                            .moveItemBackward(item.id);
                                      },
                              ),
                              IconButton(
                                tooltip: 'Up',
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: isTop
                                    ? null
                                    : () {
                                        _boardController
                                            .moveItemForward(item.id);
                                      },
                              ),
                              IconButton(
                                tooltip: 'To Top',
                                icon: const Icon(Icons.vertical_align_top),
                                onPressed: () {
                                  _boardController.moveItemOnTop(item.id);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // Select without changing z-order
                            _boardController.unSelectAll();
                            _boardController.setItemStatus(
                                item.id, StackItemStatus.selected);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.grey[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: backgroundWidth,
            height: backgroundHeight,
            child: StackBoardPlus(
              rotationSnapConfig: RotationSnapConfig(
                enabled: true,
                snapIncrement: math.pi / 6,
                tolerance: 3 * math.pi / 180,
                onSnapHapticFeedback: () {
                  HapticFeedback.lightImpact();
                },
              ),
              elevation: backgroundElevation,
              onDel: _onDel,
              controller: _boardController,
              snapConfig: _snapConfig.copyWith(
                onSnapHapticFeedback: () {
                  // Custom haptic feedback when snapping occurs
                  HapticFeedback.lightImpact();
                },
              ),
              caseStyle: CaseStyle(
                frameBorderColor: Colors.blue.withValues(alpha: 0.6),
                buttonIconColor: Colors.white,
                buttonBgColor: Colors.blue,
                buttonBorderColor: Colors.blue[700]!,
                frameBorderWidth: 2,
                showHelperButtons: false,
                scaleHandleSize: 12,
                resizeHandleSize: 8,
                scaleHandleBgColor: Colors.white,
                scaleHandleBorderColor: Colors.blue[700]!,
                resizeHandleBgColor: Colors.blue[700]!,
                isFrameDashed: true,
                dashWidth: 10,
                dashGap: 10,
              ),
              minItemSize: 20,
              background: buildBackground(),
              customBuilder: (StackItem<StackItemContent> item) {
                if (item is StackTextItem) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withValues(alpha: 0.1),
                      //     blurRadius: 8,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EnhancedStackTextCase(
                        item: item,
                        decoration: const InputDecoration.collapsed(
                            hintText: "Enter text"),
                        onTap: () => _openTextCustomizationDialog(item),
                      ),
                    ),
                  );
                } else if (item is StackImageItem) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withValues(alpha: 0.15),
                      //     blurRadius: 10,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: StackImageCase(item: item),
                    ),
                  );
                } else if (item is ColorStackItem) {
                  return Container(
                    width: item.size.width,
                    height: item.size.height,
                    decoration: BoxDecoration(
                      color: item.content?.color,
                      borderRadius: BorderRadius.circular(12),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withValues(alpha: 0.2),
                      //     blurRadius: 8,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                  );
                } else if (item is StackDrawItem) {
                  // Render the drawing canvas for drawing items with controls overlay
                  return Stack(
                    children: [
                      // Main drawing board
                      StackDrawCase(item: item),

                      // Drawing controls overlay (only show when editing)
                      if (item.status == StackItemStatus.editing)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Undo button
                                IconButton(
                                  icon: const Icon(Icons.undo,
                                      color: Colors.white, size: 18),
                                  onPressed: () => item.content!.undo(),
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                                // Redo button
                                IconButton(
                                  icon: const Icon(Icons.redo,
                                      color: Colors.white, size: 18),
                                  onPressed: () => item.content!.redo(),
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                                // Clear button
                                IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.white, size: 18),
                                  onPressed: () =>
                                      _showDrawingClearDialog(context, item),
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                } else if (item is StackShapeItem) {
                  return StackShapeCase(
                    item: item,
                    customEditorBuilder: (context, item, onUpdate) {
                      showDialog(
                        context: context,
                        builder: (context) => ShapeEditDialog(
                          item: item,
                          onUpdate: (updated) {
                            onUpdate(updated);
                          },
                        ),
                      );
                      return const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
              customActionsBuilder: (item, context) {
                // Example using StackItemActionHelper for consistent styling
                return [
                  // Drawing settings for drawing items
                  if (item is StackDrawItem)
                    StackItemActionHelper.createCustomActionButton(
                      context: context,
                      icon: const Icon(Icons.brush),
                      onTap: () => DrawingUtils.showDrawingSettingsDialog(
                          context, item.content!.controller),
                      tooltip: 'Drawing Settings',
                    ),
                ];
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  icon: Icons.text_fields,
                  label: 'Text',
                  color: Colors.blue,
                  onPressed: addTextItem,
                ),
                ActionButton(
                  icon: Icons.image,
                  label: 'Network Image',
                  color: Colors.green,
                  onPressed: addNetworkItem,
                ),
                ActionButton(
                  icon: Icons.brush_outlined,
                  label: 'Draw',
                  color: Colors.pink,
                  onPressed: addDrawingItem,
                ),
                ActionButton(
                  icon: Icons.image,
                  label: 'Asset Image',
                  color: Colors.greenAccent,
                  onPressed: addAssetItem,
                ),
                ActionButton(
                  icon: Icons.add_photo_alternate,
                  label: 'Gallery',
                  color: Colors.purple,
                  onPressed: addImageFromGalleryItem,
                ),
                ActionButton(
                  icon: Icons.star,
                  label: 'SVG',
                  color: Colors.amber,
                  onPressed: addSvgItem,
                ),
                ActionButton(
                  icon: Icons.file_upload,
                  label: 'SVG Network',
                  color: Colors.blue,
                  onPressed: addSvgNetworkItem,
                ),
                ActionButton(
                  icon: Icons.palette,
                  label: 'Color',
                  color: Colors.orange,
                  onPressed: addCustomItem,
                ),
                ActionButton(
                  icon: Icons.category,
                  label: 'Shape',
                  color: Colors.deepPurple,
                  onPressed: addShapeItem,
                ),
                ActionButton(
                  icon: Icons.file_download,
                  label: 'Export',
                  color: Colors.teal,
                  onPressed: () => getJson(context),
                ),
                ActionButton(
                  icon: Icons.file_upload,
                  label: 'Import',
                  color: Colors.indigo,
                  onPressed: () => generateFromJson(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
