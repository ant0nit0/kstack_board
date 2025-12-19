library;

// Core
export 'src/core/case_style.dart';
export 'src/stack_item_case/widgets/wiggle_animation.dart';
export 'src/core/snap_config.dart';
export 'src/core/stack_board_plus_controller.dart';
export 'src/core/stack_board_plus_item/stack_item.dart';
export 'src/core/stack_board_plus_item/stack_item_content.dart';
export 'src/core/stack_board_plus_item/stack_item_status.dart';
export 'src/core/rotation_snap_config.dart';

// Main widget
export 'src/stack_board_plus.dart';

// Item cases (UI wrappers)
export 'src/stack_item_case/stack_item_case.dart';
export 'src/stack_item_case/config_builder.dart';
export 'src/helpers/stack_item_action_helper.dart';
export 'src/stack_board_plus_items/item_case/stack_image_case.dart';
export 'src/stack_board_plus_items/item_case/stack_text_case.dart';
export 'src/stack_board_plus_items/item_case/stack_draw_case.dart';
export 'src/stack_board_plus_items/item_case/stack_shape_case.dart';

// Items (data models)
export 'src/stack_board_plus_items/items/stack_draw_item.dart';
export 'src/stack_board_plus_items/items/stack_image_item.dart';
export 'src/stack_board_plus_items/items/stack_text_item.dart';
export 'src/stack_board_plus_items/items/stack_shape_item.dart';
export 'src/stack_board_plus_items/items/stack_group_item.dart';

// Item content (data for items)
export 'src/stack_board_plus_items/item_content/stack_draw_content.dart';
export 'src/stack_board_plus_items/item_content/stack_shape_content.dart';
export 'src/stack_board_plus_items/item_content/stack_group_content.dart';

// Shape controls UI

// Helpers
export 'src/helpers/stack_item_action_helpers.dart'
    hide StackItemType, getItemType;
export 'src/helpers/safe_value_notifier.dart';
export 'src/helpers/safe_state.dart';
export 'src/helpers/ex_list.dart';
export 'src/helpers/ex_enum.dart';
export 'src/helpers/as_t.dart';
export 'src/helpers/snap_calculator.dart';
export 'src/helpers/history_controller_mixin.dart';

// Widgets
export 'src/widgets/ex_builder.dart';
export 'src/widgets/get_size.dart';

// Extensions
export 'src/widget_style_extension/ex_locale.dart';
export 'src/widget_style_extension/ex_offset.dart';
export 'src/widget_style_extension/ex_size.dart';
export 'src/widget_style_extension/ex_text_height_behavior.dart';
export 'src/widget_style_extension/ex_text_style.dart';
export 'src/widget_style_extension/stack_text_strut_style.dart';

// External dependencies
export 'package:flutter_drawing_board/flutter_drawing_board.dart'
    show DrawingController;
export 'package:flutter_drawing_board/flutter_drawing_board.dart';
