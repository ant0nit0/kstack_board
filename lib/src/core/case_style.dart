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

  HandleStyle copyWith({
    Color? color,
    Color? borderColor,
    double? borderWidth,
    double? size,
    Color? iconColor,
  }) {
    return HandleStyle(
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      size: size ?? this.size,
      iconColor: iconColor ?? this.iconColor,
    );
  }
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
    this.handleHitAreaPadding = 0.0,
    this.wiggleAnimationConfig = const WiggleAnimationConfig(),
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
      handleHitAreaPadding:
          asNullT<double>(json['handleHitAreaPadding']) ?? 0.0,
      wiggleAnimationConfig: json['wiggleAnimationConfig'] != null
          ? WiggleAnimationConfig(
              enabled:
                  asNullT<bool>(json['wiggleAnimationConfig']['enabled']) ??
                      true,
              duration: Duration(
                milliseconds:
                    asNullT<int>(json['wiggleAnimationConfig']['duration']) ??
                        500,
              ),
              rotationAmplitude: asNullT<double>(
                      json['wiggleAnimationConfig']['rotationAmplitude']) ??
                  0.05,
              translationAmplitude: asNullT<double>(
                      json['wiggleAnimationConfig']['translationAmplitude']) ??
                  2.0,
            )
          : const WiggleAnimationConfig(),
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

  /// * Additional invisible padding around handles for easier touch detection
  /// * This padding increases the hit area without changing the visual appearance
  final double handleHitAreaPadding;

  /// * Configuration for wiggle animation when items are in grouping status
  final WiggleAnimationConfig wiggleAnimationConfig;

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
        'handleHitAreaPadding': handleHitAreaPadding,
        'wiggleAnimationConfig': {
          'enabled': wiggleAnimationConfig.enabled,
          'duration': wiggleAnimationConfig.duration.inMilliseconds,
          'rotationAmplitude': wiggleAnimationConfig.rotationAmplitude,
          'translationAmplitude': wiggleAnimationConfig.translationAmplitude,
        },
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
        handleHitAreaPadding,
        wiggleAnimationConfig,
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
          showHelperButtons == other.showHelperButtons &&
          handleHitAreaPadding == other.handleHitAreaPadding &&
          wiggleAnimationConfig == other.wiggleAnimationConfig;

  /// * Copy with
  CaseStyle copyWith({
    HandleStyle? buttonStyle,
    Color? buttonColor,
    Color? buttonBorderColor,
    double? buttonBorderWidth,
    double? buttonSize,
    Color? buttonIconColor,
    HandleStyle? scaleHandleStyle,
    Color? scaleHandleColor,
    Color? scaleHandleBorderColor,
    double? scaleHandleBorderWidth,
    double? scaleHandleSize,
    Color? scaleHandleIconColor,
    HandleStyle? resizeHandleStyle,
    Color? resizeHandleColor,
    Color? resizeHandleBorderColor,
    double? resizeHandleBorderWidth,
    double? resizeHandleSize,
    Color? resizeHandleIconColor,
    double? boxAspectRatio,
    Color? frameBorderColor,
    double? frameBorderWidth,
    bool? isFrameDashed,
    double? dashWidth,
    double? dashGap,
    bool? showHelperButtons,
    double? handleHitAreaPadding,
    WiggleAnimationConfig? wiggleAnimationConfig,
  }) {
    return CaseStyle(
      buttonStyle: buttonStyle ??
          this.buttonStyle.copyWith(
                color: buttonColor,
                borderColor: buttonBorderColor,
                borderWidth: buttonBorderWidth,
                size: buttonSize,
                iconColor: buttonIconColor,
              ),
      scaleHandleStyle: scaleHandleStyle ??
          this.scaleHandleStyle?.copyWith(
                color: scaleHandleColor,
                borderColor: scaleHandleBorderColor,
                borderWidth: scaleHandleBorderWidth,
                size: scaleHandleSize,
                iconColor: scaleHandleIconColor,
              ),
      resizeHandleStyle: resizeHandleStyle ??
          this.resizeHandleStyle?.copyWith(
                color: resizeHandleColor,
                borderColor: resizeHandleBorderColor,
                borderWidth: resizeHandleBorderWidth,
                size: resizeHandleSize,
                iconColor: resizeHandleIconColor,
              ),
      boxAspectRatio: boxAspectRatio ?? this.boxAspectRatio,
      frameBorderColor: frameBorderColor ?? this.frameBorderColor,
      frameBorderWidth: frameBorderWidth ?? this.frameBorderWidth,
      isFrameDashed: isFrameDashed ?? this.isFrameDashed,
      dashWidth: dashWidth ?? this.dashWidth,
      dashGap: dashGap ?? this.dashGap,
      showHelperButtons: showHelperButtons ?? this.showHelperButtons,
      handleHitAreaPadding: handleHitAreaPadding ?? this.handleHitAreaPadding,
      wiggleAnimationConfig:
          wiggleAnimationConfig ?? this.wiggleAnimationConfig,
    );
  }
}
