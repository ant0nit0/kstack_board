import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// * Handle style
@immutable
class HandleStyle {
  const HandleStyle({
    this.color,
    this.borderColor,
    this.borderWidth,
    this.size,
    this.iconColor,
  });

  factory HandleStyle.fromJson(final Map<String, dynamic> json) {
    return HandleStyle(
      color: asNullT<Color>(json['color']),
      borderColor: asNullT<Color>(json['borderColor']),
      borderWidth: asNullT<double>(json['borderWidth']),
      size: asNullT<double>(json['size']),
      iconColor: asNullT<Color>(json['iconColor']),
    );
  }

  /// * Background color
  final Color? color;

  /// * Border color
  final Color? borderColor;

  /// * Border thickness
  final double? borderWidth;

  /// * Size
  final double? size;

  /// * Icon color (mostly for buttons)
  final Color? iconColor;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'color': color,
        'borderColor': borderColor,
        'borderWidth': borderWidth,
        'size': size,
        'iconColor': iconColor,
      };

  @override
  int get hashCode => Object.hash(
        color,
        borderColor,
        borderWidth,
        size,
        iconColor,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HandleStyle &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          size == other.size &&
          iconColor == other.iconColor;
}

/// * case style
@immutable
class CaseStyle {
  const CaseStyle({
    this.buttonStyle = const HandleStyle(
      color: Colors.white,
      borderColor: Colors.grey,
      borderWidth: 1,
      iconColor: Colors.grey,
      size: 24,
    ),
    this.scaleHandleStyle,
    this.resizeHandleStyle,
    this.boxAspectRatio,
    this.frameBorderColor = Colors.purple,
    this.frameBorderWidth = 2,
    this.isFrameDashed = false,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.showHelperButtons = true,
  });

  factory CaseStyle.fromJson(final Map<String, dynamic> json) {
    return CaseStyle(
      buttonStyle: json['buttonStyle'] != null
          ? HandleStyle.fromJson(json['buttonStyle'])
          : const HandleStyle(
              color: Colors.white,
              borderColor: Colors.grey,
              borderWidth: 1,
              iconColor: Colors.grey,
              size: 24,
            ),
      scaleHandleStyle: json['scaleHandleStyle'] != null
          ? HandleStyle.fromJson(json['scaleHandleStyle'])
          : null,
      resizeHandleStyle: json['resizeHandleStyle'] != null
          ? HandleStyle.fromJson(json['resizeHandleStyle'])
          : null,
      boxAspectRatio: asNullT<double>(json['boxAspectRatio']),
      frameBorderColor:
          asNullT<Color>(json['frameBorderColor']) ?? Colors.purple,
      frameBorderWidth: asNullT<double>(json['frameBorderWidth']) ?? 2.0,
      isFrameDashed: asNullT<bool>(json['isFrameDashed']) ?? false,
      dashWidth: asNullT<double>(json['dashWidth']) ?? 5.0,
      dashGap: asNullT<double>(json['dashGap']) ?? 3.0,
      showHelperButtons: asNullT<bool>(json['showHelperButtons']) ?? true,
    );
  }

  /// * Button style
  final HandleStyle buttonStyle;

  /// * Scale handle style
  final HandleStyle? scaleHandleStyle;

  /// * Resize handle style
  final HandleStyle? resizeHandleStyle;

  /// * Frame border color
  final Color frameBorderColor;

  /// * Frame border thickness
  final double frameBorderWidth;

  /// * Whether the frame border should be dashed
  final bool isFrameDashed;

  /// * Width of each dash (only used if isFrameDashed is true)
  final double dashWidth;

  /// * Gap between dashes (only used if isFrameDashed is true)
  final double dashGap;

  /// * if(boxAspectRatio!=null)
  /// * Border ratio
  /// * if(boxAspectRatio!=null) Scaling transformation will fix the ratio
  // * `TODO`: transform this parameter to a boolean disabling the resizeX and resizeY handles
  final double? boxAspectRatio;

  /// * Whether to show helper buttons (like delete, rotate etc.)
  final bool showHelperButtons;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'buttonStyle': buttonStyle.toJson(),
        'scaleHandleStyle': scaleHandleStyle?.toJson(),
        'resizeHandleStyle': resizeHandleStyle?.toJson(),
        'boxAspectRatio': boxAspectRatio,
        'frameBorderColor': frameBorderColor,
        'frameBorderWidth': frameBorderWidth,
        'isFrameDashed': isFrameDashed,
        'dashWidth': dashWidth,
        'dashGap': dashGap,
        'showHelperButtons': showHelperButtons,
      };

  @override
  int get hashCode => Object.hash(
        buttonStyle,
        scaleHandleStyle,
        resizeHandleStyle,
        boxAspectRatio,
        frameBorderColor,
        frameBorderWidth,
        isFrameDashed,
        dashWidth,
        dashGap,
        showHelperButtons,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseStyle &&
          runtimeType == other.runtimeType &&
          buttonStyle == other.buttonStyle &&
          scaleHandleStyle == other.scaleHandleStyle &&
          resizeHandleStyle == other.resizeHandleStyle &&
          boxAspectRatio == other.boxAspectRatio &&
          frameBorderColor == other.frameBorderColor &&
          frameBorderWidth == other.frameBorderWidth &&
          isFrameDashed == other.isFrameDashed &&
          dashWidth == other.dashWidth &&
          dashGap == other.dashGap &&
          showHelperButtons == other.showHelperButtons;
}
