import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// Helper class for managing custom actions on stack items
class StackItemActionHelper {
  /// Get the case style from context, similar to StackItemCase._caseStyle
  static CaseStyle getCaseStyle(BuildContext context, {CaseStyle? caseStyle}) {
    return caseStyle ??
        StackBoardPlusConfig.of(context).caseStyle ??
        const CaseStyle();
  }

  /// Check if item is small enough to need custom actions in the toolbar
  static bool shouldShowCustomActionsInToolbar(
    StackItem<StackItemContent> item,
    CaseStyle style,
  ) {
    final buttonSize = style.buttonStyle.size ?? 24.0;
    return (item.size.width + item.size.height < buttonSize * 6) == false;
  }

  /// Build custom actions that can be integrated into the toolbar
  static List<Widget> buildCustomActions({
    required StackItem<StackItemContent> item,
    required BuildContext context,
    required List<Widget> Function(StackItem<StackItemContent>, BuildContext)? customActionsBuilder,
    CaseStyle? caseStyle,
  }) {
    if (customActionsBuilder == null) return [];
    
    final style = getCaseStyle(context, caseStyle: caseStyle);
    
    // Only show custom actions if the item is large enough
    if (shouldShowCustomActionsInToolbar(item, style)) {
      return customActionsBuilder(item, context);
    }
    
    return [];
  }

  /// Create a standard tool case widget (similar to StackItemCase._toolCase)
  static Widget createToolCase(
    BuildContext context, 
    CaseStyle style, 
    Widget? child
  ) {
    final buttonSize = style.buttonStyle.size ?? 24.0;
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.buttonStyle.color ?? Colors.white,
        border: Border.all(
          width: style.buttonStyle.borderWidth ?? 1.0, 
          color: style.buttonStyle.borderColor ?? Colors.grey,
        )
      ),
      child: child == null
          ? null
          : IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                color: style.buttonStyle.iconColor ?? Colors.grey,
                size: buttonSize * 0.6,
              ),
              child: child,
            ),
    );
  }

  /// Create a custom action button that matches the design system
  static Widget createCustomActionButton({
    required BuildContext context,
    required Widget icon,
    required VoidCallback onTap,
    CaseStyle? caseStyle,
    String? tooltip,
  }) {
    final style = getCaseStyle(context, caseStyle: caseStyle);
    
    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: createToolCase(context, style, icon),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }

  /// Example: Create a duplicate action button
  static Widget createDuplicateAction({
    required StackItem<StackItemContent> item,
    required BuildContext context,
    required VoidCallback onDuplicate,
    CaseStyle? caseStyle,
  }) {
    return createCustomActionButton(
      context: context,
      icon: const Icon(Icons.content_copy),
      onTap: onDuplicate,
      caseStyle: caseStyle,
      tooltip: 'Duplicate',
    );
  }

  /// Example: Create a lock/unlock action button
  static Widget createLockAction({
    required StackItem<StackItemContent> item,
    required BuildContext context,
    required VoidCallback onToggleLock,
    CaseStyle? caseStyle,
  }) {
    final isLocked = item.status == StackItemStatus.locked;
    
    return createCustomActionButton(
      context: context,
      icon: Icon(isLocked ? Icons.lock : Icons.lock_open),
      onTap: onToggleLock,
      caseStyle: caseStyle,
      tooltip: isLocked ? 'Unlock' : 'Lock',
    );
  }

  /// Example: Create a visibility toggle action button
  static Widget createVisibilityAction({
    required StackItem<StackItemContent> item,
    required BuildContext context,
    required VoidCallback onToggleVisibility,
    CaseStyle? caseStyle,
    required bool isVisible,
  }) {
    return createCustomActionButton(
      context: context,
      icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
      onTap: onToggleVisibility,
      caseStyle: caseStyle,
      tooltip: isVisible ? 'Hide' : 'Show',
    );
  }
}
