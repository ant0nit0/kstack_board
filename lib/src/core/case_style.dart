import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// * case style
@immutable
class CaseStyle {
  const CaseStyle({
    this.buttonBgColor = Colors.white,
    this.buttonBorderColor = Colors.grey,
    this.buttonBorderWidth = 1,
    this.buttonIconColor = Colors.grey,
    this.buttonSize = 24,
    this.boxAspectRatio,
    this.frameBorderColor = Colors.purple,
    this.frameBorderWidth = 2,
    this.isFrameDashed = false,
    this.dashWidth = 5.0,
    this.dashGap = 3.0,
    this.scaleHandleBgColor,
    this.scaleHandleBorderColor,
    this.scaleHandleIconColor,
    this.scaleHandleSize,
    this.resizeHandleBgColor,
    this.resizeHandleBorderColor,
    this.resizeHandleSize,
    this.showHelperButtons = true,
  });

  factory CaseStyle.fromJson(final Map<String, dynamic> json) {
    final Color? buttonBgColor = asNullT<Color>(json['buttonBgColor']);
    final Color? buttonBorderColor = asNullT<Color>(json['buttonBorderColor']);
    final double? buttonBorderWidth =
        asNullT<double>(json['buttonBorderWidth']);
    final Color? buttonIconColor = asNullT<Color>(json['buttonIconColor']);
    final double? buttonSize = asNullT<double>(json['buttonSize']);
    final double? boxAspectRatio = asNullT<double>(json['boxAspectRatio']);
    final Color? frameBorderColor = asNullT<Color>(json['frameBorderColor']);
    final double? frameBorderWidth = asNullT<double>(json['frameBorderWidth']);
    final bool? isFrameDashed = asNullT<bool>(json['isFrameDashed']);
    final double? dashWidth = asNullT<double>(json['dashWidth']);
    final double? dashGap = asNullT<double>(json['dashGap']);
    final Color? scaleHandleBgColor =
        asNullT<Color>(json['scaleHandleBgColor']);
    final Color? scaleHandleBorderColor =
        asNullT<Color>(json['scaleHandleBorderColor']);
    final Color? scaleHandleIconColor =
        asNullT<Color>(json['scaleHandleIconColor']);
    final double? scaleHandleSize = asNullT<double>(json['scaleHandleSize']);
    final Color? resizeHandleBgColor =
        asNullT<Color>(json['resizeHandleBgColor']);
    final Color? resizeHandleBorderColor =
        asNullT<Color>(json['resizeHandleBorderColor']);
    final double? resizeHandleSize = asNullT<double>(json['resizeHandleSize']);
    final bool? showHelperButtons = asNullT<bool>(json['showHelperButtons']);

    return CaseStyle(
      buttonBgColor: buttonBgColor ?? Colors.white,
      buttonBorderColor: buttonBorderColor ?? Colors.grey,
      buttonBorderWidth: buttonBorderWidth ?? 1,
      buttonIconColor: buttonIconColor ?? Colors.grey,
      buttonSize: buttonSize ?? 24,
      boxAspectRatio: boxAspectRatio,
      frameBorderColor: frameBorderColor ?? Colors.purple,
      frameBorderWidth: frameBorderWidth ?? 2,
      isFrameDashed: isFrameDashed ?? false,
      dashWidth: dashWidth ?? 5.0,
      dashGap: dashGap ?? 3.0,
      scaleHandleBgColor: scaleHandleBgColor,
      scaleHandleBorderColor: scaleHandleBorderColor,
      scaleHandleIconColor: scaleHandleIconColor,
      scaleHandleSize: scaleHandleSize,
      resizeHandleBgColor: resizeHandleBgColor,
      resizeHandleBorderColor: resizeHandleBorderColor,
      resizeHandleSize: resizeHandleSize,
      showHelperButtons: showHelperButtons ?? true,
    );
  }

  /// * Background color
  final Color buttonBgColor;

  /// * Border color
  final Color buttonBorderColor;

  /// * Border thickness
  final double buttonBorderWidth;

  /// * Icon color
  final Color buttonIconColor;

  /// * Button size
  final double buttonSize;

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

  /// * Background color for scale handle
  final Color? scaleHandleBgColor;

  /// * Border color for scale handle
  final Color? scaleHandleBorderColor;

  /// * Icon color for scale handle
  final Color? scaleHandleIconColor;

  /// * Size for scale handle (defaults to buttonSize if null)
  final double? scaleHandleSize;

  /// * Background color for resize handle
  final Color? resizeHandleBgColor;

  /// * Border color for resize handle
  final Color? resizeHandleBorderColor;

  /// * Size for resize handle (defaults to buttonSize if null)
  final double? resizeHandleSize;

  /// * Whether to show helper buttons (like delete, rotate etc.)
  final bool showHelperButtons;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'bgColor': buttonBgColor,
        'buttonBorderColor': buttonBorderColor,
        'buttonBorderWidth': buttonBorderWidth,
        'buttonIconColor': buttonIconColor,
        'buttonSize': buttonSize,
        'boxAspectRatio': boxAspectRatio,
        'frameBorderColor': frameBorderColor,
        'frameBorderWidth': frameBorderWidth,
        'isFrameDashed': isFrameDashed,
        'dashWidth': dashWidth,
        'dashGap': dashGap,
        'scaleHandleBgColor': scaleHandleBgColor,
        'scaleHandleBorderColor': scaleHandleBorderColor,
        'scaleHandleIconColor': scaleHandleIconColor,
        'scaleHandleSize': scaleHandleSize,
        'resizeHandleBgColor': resizeHandleBgColor,
        'resizeHandleBorderColor': resizeHandleBorderColor,
        'resizeHandleSize': resizeHandleSize,
        'showHelperButtons': showHelperButtons,
      };

  @override
  int get hashCode => Object.hash(
      buttonBgColor,
      buttonBorderColor,
      buttonBorderWidth,
      buttonIconColor,
      buttonSize,
      boxAspectRatio,
      frameBorderColor,
      frameBorderWidth,
      isFrameDashed,
      dashWidth,
      dashGap,
      scaleHandleBgColor,
      scaleHandleBorderColor,
      scaleHandleIconColor,
      scaleHandleSize,
      resizeHandleBgColor,
      resizeHandleBorderColor,
      resizeHandleSize,
      showHelperButtons);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseStyle &&
          runtimeType == other.runtimeType &&
          buttonBgColor == other.buttonBgColor &&
          buttonBorderColor == other.buttonBorderColor &&
          buttonBorderWidth == other.buttonBorderWidth &&
          buttonIconColor == other.buttonIconColor &&
          buttonSize == other.buttonSize &&
          boxAspectRatio == other.boxAspectRatio &&
          frameBorderColor == other.frameBorderColor &&
          frameBorderWidth == other.frameBorderWidth &&
          isFrameDashed == other.isFrameDashed &&
          dashWidth == other.dashWidth &&
          dashGap == other.dashGap &&
          scaleHandleBgColor == other.scaleHandleBgColor &&
          scaleHandleBorderColor == other.scaleHandleBorderColor &&
          scaleHandleIconColor == other.scaleHandleIconColor &&
          scaleHandleSize == other.scaleHandleSize &&
          resizeHandleBgColor == other.resizeHandleBgColor &&
          resizeHandleBorderColor == other.resizeHandleBorderColor &&
          resizeHandleSize == other.resizeHandleSize &&
          showHelperButtons == other.showHelperButtons;
}
