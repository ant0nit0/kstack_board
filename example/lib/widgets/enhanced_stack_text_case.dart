import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stack_board_plus/stack_board_plus.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class EnhancedStackTextCase extends StatefulWidget {
  const EnhancedStackTextCase({
    super.key,
    required this.item,
    this.decoration,
    this.onTap,
  });

  final StackTextItem item;
  final InputDecoration? decoration;
  final VoidCallback? onTap;

  @override
  _EnhancedStackTextCaseState createState() => _EnhancedStackTextCaseState();
}

class _EnhancedStackTextCaseState extends State<EnhancedStackTextCase> {
  bool _isHovered = false;

  TextItemContent? get content => widget.item.content;

  @override
  Widget build(BuildContext context) {
    return widget.item.status == StackItemStatus.editing
        ? _buildEditing(context)
        : _buildNormal(context);
  }

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
    if (content.skewX != 0 ||
        content.skewY != 0 ||
        content.flipHorizontally ||
        content.flipVertically) {
      textWidget = Transform(
        transform: Matrix4.identity()
          ..setEntry(0, 1, content.skewX)
          ..setEntry(1, 0, content.skewY)
          ..scaleByVector3(
            vm.Vector3(
              content.flipHorizontally ? -1.0 : 1.0,
              content.flipVertically ? -1.0 : 1.0,
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

    // Add tap gesture for customization
    if (widget.onTap != null) {
      textWidget = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onTap, // Also respond to double tap
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: _isHovered
                          ? Colors.blue.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: textWidget,
              ),
              if (_isHovered)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Wrap in alignment container
    return Container(
      alignment:
          _getAlignment(content.horizontalAlignment, content.verticalAlignment),
      child: FittedBox(child: textWidget),
    );
  }

  Widget _buildEditing(BuildContext context) {
    // When in editing mode, immediately open the customization dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onTap != null) {
        widget.onTap!();
      }
    });

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: Colors.blue.withValues(alpha: 0.1),
        ),
        child: Text(
          content?.data ?? 'Tap to customize',
          style: content?.style?.copyWith(color: Colors.blue) ??
              const TextStyle(color: Colors.blue),
          textAlign: content?.textAlign ?? TextAlign.start,
        ),
      ),
    );
  }

  Widget _buildEnhancedText(TextItemContent content) {
    // Create text style with enhanced properties using Google Fonts
    TextStyle baseStyle;

    try {
      baseStyle = GoogleFonts.getFont(
        content.fontFamily ?? 'Roboto',
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
    } catch (e) {
      // Fallback to default font if Google Font fails
      baseStyle = TextStyle(
        fontFamily: content.fontFamily,
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
    }

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
}
