import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class StackTextCase extends StatelessWidget {
  const StackTextCase({
    super.key,
    required this.item,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.textAlignVertical,
    this.controller,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onTap,
    this.readOnly = false,
    this.autofocus = true,
    this.obscureText = false,
    this.maxLines,
    this.inputFormatters,
    this.focusNode,
    this.enabled = true,
  });

  final StackTextItem item;

  final InputDecoration? decoration;
  final TextEditingController? controller;

  final int? maxLength;

  final TextInputAction? textInputAction;

  final TextAlignVertical? textAlignVertical;

  final TextInputType? keyboardType;

  final Function(String)? onChanged;

  final Function()? onEditingComplete;

  final Function()? onTap;

  final bool readOnly;

  final bool autofocus;

  final bool obscureText;

  final int? maxLines;

  final List<TextInputFormatter>? inputFormatters;

  final FocusNode? focusNode;

  final bool enabled;

  final TextCapitalization textCapitalization;

  TextItemContent? get content => item.content;

  @override
  Widget build(BuildContext context) {
    return item.status == StackItemStatus.editing
        ? _buildEditing(context)
        : _buildNormal(context);
  }

  /// * Text
  Widget _buildNormal(BuildContext context) {
    final content = this.content;
    if (content == null) return const SizedBox.shrink();

    // Build the base text widget with enhanced styling
    Widget textWidget = _buildEnhancedText(content);

    // Apply container styling (background, border, padding)
    if (content.backgroundColor != null ||
        content.borderWidth > 0 ||
        content.padding != null) {
      textWidget = Container(
        padding: content.padding ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: content.backgroundColor,
          border: content.borderWidth > 0 && content.borderColor != null
              ? Border.all(
                  color: content.borderColor!, width: content.borderWidth)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: textWidget,
      );
    }

    // Apply margin
    if (content.margin != null) {
      textWidget = Padding(
        padding: content.margin!,
        child: textWidget,
      );
    }

    // Apply transformations (skew, flip)
    if (content.skewX != 0 || content.skewY != 0 || item.flipX || item.flipY) {
      textWidget = Transform(
        transform: Matrix4.identity()
          ..setEntry(0, 1, content.skewX)
          ..setEntry(1, 0, content.skewY)
          ..scaleByVector3(
            vm.Vector3(
              item.flipX ? -1.0 : 1.0,
              item.flipY ? -1.0 : 1.0,
              1.0,
            ),
          ),
        alignment: Alignment.center,
        child: textWidget,
      );
    }

    // Apply opacity
    if (content.opacity < 1.0) {
      textWidget = Opacity(
        opacity: content.opacity,
        child: textWidget,
      );
    }

    // Apply arc transformation if needed
    if (content.arcDegree != 0) {
      textWidget = Transform.rotate(
        angle:
            content.arcDegree * (3.14159 / 180), // Convert degrees to radians
        child: textWidget,
      );
    }

    // Wrap in alignment container
    return Container(
      alignment:
          _getAlignment(content.horizontalAlignment, content.verticalAlignment),
      child: FittedBox(child: textWidget),
    );
  }

  Widget _buildEnhancedText(TextItemContent content) {
    // Create text style with enhanced properties
    final baseStyle = TextStyle(
      fontSize: content.fontSize,
      fontWeight: content.fontWeight,
      fontStyle: content.fontStyle,
      letterSpacing: content.letterSpacing,
      wordSpacing: content.wordSpacing,
      height: content.lineHeight,
      decoration: content.isUnderlined ? TextDecoration.underline : null,
      decorationColor: content.textColor,
      shadows: _buildShadows(content),
    );

    // Combine with existing style if any
    final finalStyle = content.style?.merge(baseStyle) ?? baseStyle;

    final text = content.data ?? '';

    // Handle gradient text
    if (content.textGradient != null) {
      return ShaderMask(
        shaderCallback: (bounds) => content.textGradient!.createShader(bounds),
        child: Text(
          text,
          style: finalStyle.copyWith(color: Colors.white),
          textAlign: content.textAlign ?? content.horizontalAlignment,
          textDirection: content.textDirection,
          locale: content.locale,
          softWrap: content.softWrap,
          overflow: content.overflow,
          textScaler: content.textScaleFactor != null
              ? TextScaler.linear(content.textScaleFactor!)
              : TextScaler.noScaling,
          maxLines: content.maxLines,
          semanticsLabel: content.semanticsLabel,
          textWidthBasis: content.textWidthBasis,
          textHeightBehavior: content.textHeightBehavior,
          selectionColor: content.selectionColor,
        ),
      );
    } else {
      // Regular text with color
      return Text(
        text,
        style: finalStyle.copyWith(
          color: content.textColor?.withValues(alpha: content.opacity) ??
              finalStyle.color?.withValues(alpha: content.opacity),
        ),
        textAlign: content.textAlign ?? content.horizontalAlignment,
        textDirection: content.textDirection,
        locale: content.locale,
        softWrap: content.softWrap,
        overflow: content.overflow,
        textScaler: content.textScaleFactor != null
            ? TextScaler.linear(content.textScaleFactor!)
            : TextScaler.noScaling,
        maxLines: content.maxLines,
        semanticsLabel: content.semanticsLabel,
        textWidthBasis: content.textWidthBasis,
        textHeightBehavior: content.textHeightBehavior,
        selectionColor: content.selectionColor,
      );
    }
  }

  List<Shadow>? _buildShadows(TextItemContent content) {
    if (content.shadowBlurRadius <= 0 || content.shadowColor == null) {
      return null;
    }

    return [
      Shadow(
        color: content.shadowColor!,
        offset: content.shadowOffset ?? const Offset(1, 1),
        blurRadius: content.shadowBlurRadius,
      ),
    ];
  }

  Alignment _getAlignment(TextAlign horizontal, MainAxisAlignment vertical) {
    double x = 0.0;
    double y = 0.0;

    // Horizontal alignment
    switch (horizontal) {
      case TextAlign.left:
        x = -1.0;
        break;
      case TextAlign.center:
        x = 0.0;
        break;
      case TextAlign.right:
        x = 1.0;
        break;
      case TextAlign.start:
        x = -1.0;
        break;
      case TextAlign.end:
        x = 1.0;
        break;
      case TextAlign.justify:
        x = 0.0;
        break;
    }

    // Vertical alignment
    switch (vertical) {
      case MainAxisAlignment.start:
        y = -1.0;
        break;
      case MainAxisAlignment.center:
        y = 0.0;
        break;
      case MainAxisAlignment.end:
        y = 1.0;
        break;
      case MainAxisAlignment.spaceAround:
      case MainAxisAlignment.spaceBetween:
      case MainAxisAlignment.spaceEvenly:
        y = 0.0;
        break;
    }

    return Alignment(x, y);
  }

  /// * TextFormField
  Widget _buildEditing(BuildContext context) {
    return Center(
      child: TextFormField(
        initialValue: content?.data,
        style: content?.style,
        strutStyle: content?.strutStyle?.style,
        textAlign: content?.textAlign ?? TextAlign.start,
        textDirection: content?.textDirection,
        maxLines: content?.maxLines,
        decoration: decoration,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        textAlignVertical: textAlignVertical,
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        readOnly: readOnly,
        obscureText: obscureText,
        maxLength: maxLength,
        onChanged: (String str) {
          item.setData(str);
          onChanged?.call(str);
        },
        onTap: onTap,
        onEditingComplete: onEditingComplete,
        inputFormatters: inputFormatters,
        enabled: enabled,
      ),
    );
  }
}
