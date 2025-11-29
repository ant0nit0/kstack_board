import 'package:flutter/material.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

/// TextItemContent
class TextItemContent implements StackItemContent {
  TextItemContent({
    this.data,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    // Enhanced customization properties
    this.fontFamily,
    this.fontSize = 16.0,
    this.fontWeight,
    this.fontStyle,
    this.isUnderlined = false,
    this.textColor,
    this.textGradient,
    this.strokeColor,
    this.strokeWidth = 0.0,
    this.shadowColor,
    this.shadowOffset,
    this.shadowBlurRadius = 0.0,
    this.shadowSpreadRadius = 0.0,
    this.arcDegree = 0.0,
    this.letterSpacing = 0.0,
    this.wordSpacing = 0.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.0,
    this.opacity = 1.0,
    this.padding,
    this.margin,
    this.skewX = 0.0,
    this.skewY = 0.0,
    this.horizontalAlignment = TextAlign.center,
    this.verticalAlignment = MainAxisAlignment.center,
    this.lineHeight = 1.0,
  });

  factory TextItemContent.fromJson(Map<String, dynamic> data) {
    return TextItemContent(
      data: data['data'] == null ? null : asT<String>(data['data']),
      style:
          data['style'] == null ? null : jsonToTextStyle(asMap(data['style'])),
      strutStyle: data['strutStyle'] == null
          ? null
          : StackTextStrutStyle.fromJson(asMap(data['strutStyle'])),
      textAlign: data['textAlign'] == null
          ? null
          : ExEnum.tryParse<TextAlign>(
              TextAlign.values, asT<String>(data['textAlign'])),
      textDirection: data['textDirection'] == null
          ? null
          : ExEnum.tryParse<TextDirection>(
              TextDirection.values, asT<String>(data['textDirection'])),
      locale:
          data['locale'] == null ? null : jsonToLocale(asMap(data['locale'])),
      softWrap: data['softWrap'] == null ? null : asT<bool>(data['softWrap']),
      overflow: data['overflow'] == null
          ? null
          : ExEnum.tryParse<TextOverflow>(
              TextOverflow.values, asT<String>(data['overflow'])),
      textScaleFactor: data['textScaleFactor'] == null
          ? null
          : asT<double>(data['textScaleFactor']),
      maxLines: data['maxLines'] == null ? null : asT<int>(data['maxLines']),
      semanticsLabel: data['semanticsLabel'] == null
          ? null
          : asT<String>(data['semanticsLabel']),
      textWidthBasis: data['textWidthBasis'] == null
          ? null
          : ExEnum.tryParse<TextWidthBasis>(
              TextWidthBasis.values, asT<String>(data['textWidthBasis'])),
      textHeightBehavior: data['textHeightBehavior'] == null
          ? null
          : jsonToTextHeightBehavior(asMap(data['textHeightBehavior'])),
      selectionColor: data['selectionColor'] == null
          ? null
          : Color(asT<int>(data['selectionColor'])),
      // Enhanced customization properties
      fontFamily:
          data['fontFamily'] == null ? null : asT<String>(data['fontFamily']),
      fontSize: data['fontSize'] == null ? 16.0 : asT<double>(data['fontSize']),
      fontWeight: data['fontWeight'] == null
          ? null
          : FontWeight.values[asT<int>(data['fontWeight'])],
      fontStyle: data['fontStyle'] == null
          ? null
          : FontStyle.values[asT<int>(data['fontStyle'])],
      isUnderlined: data['isUnderlined'] == null
          ? false
          : asT<bool>(data['isUnderlined']),
      textColor:
          data['textColor'] == null ? null : Color(asT<int>(data['textColor'])),
      strokeColor: data['strokeColor'] == null
          ? null
          : Color(asT<int>(data['strokeColor'])),
      strokeWidth:
          data['strokeWidth'] == null ? 0.0 : asT<double>(data['strokeWidth']),
      shadowColor: data['shadowColor'] == null
          ? null
          : Color(asT<int>(data['shadowColor'])),
      shadowOffset: data['shadowOffset'] == null
          ? null
          : Offset(asT<double>(data['shadowOffset']['dx']),
              asT<double>(data['shadowOffset']['dy'])),
      shadowBlurRadius: data['shadowBlurRadius'] == null
          ? 0.0
          : asT<double>(data['shadowBlurRadius']),
      shadowSpreadRadius: data['shadowSpreadRadius'] == null
          ? 0.0
          : asT<double>(data['shadowSpreadRadius']),
      arcDegree:
          data['arcDegree'] == null ? 0.0 : asT<double>(data['arcDegree']),
      letterSpacing: data['letterSpacing'] == null
          ? 0.0
          : asT<double>(data['letterSpacing']),
      wordSpacing:
          data['wordSpacing'] == null ? 0.0 : asT<double>(data['wordSpacing']),
      backgroundColor: data['backgroundColor'] == null
          ? null
          : Color(asT<int>(data['backgroundColor'])),
      borderColor: data['borderColor'] == null
          ? null
          : Color(asT<int>(data['borderColor'])),
      borderWidth:
          data['borderWidth'] == null ? 0.0 : asT<double>(data['borderWidth']),
      opacity: data['opacity'] == null ? 1.0 : asT<double>(data['opacity']),
      padding: data['padding'] == null
          ? null
          : EdgeInsets.fromLTRB(
              asT<double>(data['padding']['left']),
              asT<double>(data['padding']['top']),
              asT<double>(data['padding']['right']),
              asT<double>(data['padding']['bottom']),
            ),
      margin: data['margin'] == null
          ? null
          : EdgeInsets.fromLTRB(
              asT<double>(data['margin']['left']),
              asT<double>(data['margin']['top']),
              asT<double>(data['margin']['right']),
              asT<double>(data['margin']['bottom']),
            ),
      skewX: data['skewX'] == null ? 0.0 : asT<double>(data['skewX']),
      skewY: data['skewY'] == null ? 0.0 : asT<double>(data['skewY']),
      horizontalAlignment: data['horizontalAlignment'] == null
          ? TextAlign.center
          : ExEnum.tryParse<TextAlign>(
              TextAlign.values, asT<String>(data['horizontalAlignment']))!,
      verticalAlignment: data['verticalAlignment'] == null
          ? MainAxisAlignment.center
          : ExEnum.tryParse<MainAxisAlignment>(MainAxisAlignment.values,
              asT<String>(data['verticalAlignment']))!,
      lineHeight:
          data['lineHeight'] == null ? 1.0 : asT<double>(data['lineHeight']),
    );
  }

  String? data;
  TextStyle? style;
  StackTextStrutStyle? strutStyle;
  TextAlign? textAlign;
  TextDirection? textDirection;
  Locale? locale;
  bool? softWrap;
  TextOverflow? overflow;
  double? textScaleFactor;
  int? maxLines;
  String? semanticsLabel;
  TextWidthBasis? textWidthBasis;
  TextHeightBehavior? textHeightBehavior;
  Color? selectionColor;

  // Enhanced customization properties
  String? fontFamily;
  double fontSize;
  FontWeight? fontWeight;
  FontStyle? fontStyle;
  bool isUnderlined;
  Color? textColor;
  Gradient? textGradient;
  Color? strokeColor;
  double strokeWidth;
  Color? shadowColor;
  Offset? shadowOffset;
  double shadowBlurRadius;
  double shadowSpreadRadius;
  double arcDegree; // Text arc from -180 to 180
  double letterSpacing;
  double wordSpacing;
  Color? backgroundColor;
  Color? borderColor;
  double borderWidth;
  double opacity;
  EdgeInsets? padding;
  EdgeInsets? margin;
  double skewX; // Tilt X axis
  double skewY; // Tilt Y axis
  TextAlign horizontalAlignment;
  MainAxisAlignment verticalAlignment;
  double lineHeight;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (data != null) 'data': data,
      if (style != null) 'style': style?.toJson(),
      if (strutStyle != null) 'strutStyle': strutStyle?.toJson(),
      if (textAlign != null) 'textAlign': textAlign?.toString(),
      if (textDirection != null) 'textDirection': textDirection?.toString(),
      if (locale != null) 'locale': locale?.toJson(),
      if (softWrap != null) 'softWrap': softWrap,
      if (overflow != null) 'overflow': overflow?.toString(),
      if (textScaleFactor != null) 'textScaleFactor': textScaleFactor,
      if (maxLines != null) 'maxLines': maxLines,
      if (semanticsLabel != null) 'semanticsLabel': semanticsLabel,
      if (textWidthBasis != null) 'textWidthBasis': textWidthBasis?.toString(),
      if (textHeightBehavior != null)
        'textHeightBehavior': textHeightBehavior?.toJson(),
      if (selectionColor != null) 'selectionColor': selectionColor?.toARGB32(),
      // Enhanced customization properties
      if (fontFamily != null) 'fontFamily': fontFamily,
      'fontSize': fontSize,
      if (fontWeight != null) 'fontWeight': fontWeight?.index,
      if (fontStyle != null) 'fontStyle': fontStyle?.index,
      'isUnderlined': isUnderlined,
      if (textColor != null) 'textColor': textColor?.toARGB32(),
      if (textGradient != null)
        'textGradient': {
          'colors': textGradient!.colors.map((c) => c.toARGB32()).toList(),
          'type': textGradient.runtimeType.toString(),
        },
      if (strokeColor != null) 'strokeColor': strokeColor?.toARGB32(),
      'strokeWidth': strokeWidth,
      if (shadowColor != null) 'shadowColor': shadowColor?.toARGB32(),
      if (shadowOffset != null)
        'shadowOffset': {'dx': shadowOffset!.dx, 'dy': shadowOffset!.dy},
      'shadowBlurRadius': shadowBlurRadius,
      'shadowSpreadRadius': shadowSpreadRadius,
      'arcDegree': arcDegree,
      'letterSpacing': letterSpacing,
      'wordSpacing': wordSpacing,
      if (backgroundColor != null)
        'backgroundColor': backgroundColor?.toARGB32(),
      if (borderColor != null) 'borderColor': borderColor?.toARGB32(),
      'borderWidth': borderWidth,
      'opacity': opacity,
      if (padding != null)
        'padding': {
          'left': padding!.left,
          'top': padding!.top,
          'right': padding!.right,
          'bottom': padding!.bottom,
        },
      if (margin != null)
        'margin': {
          'left': margin!.left,
          'top': margin!.top,
          'right': margin!.right,
          'bottom': margin!.bottom,
        },
      'skewX': skewX,
      'skewY': skewY,
      'horizontalAlignment': horizontalAlignment.toString(),
      'verticalAlignment': verticalAlignment.toString(),
      'lineHeight': lineHeight,
    };
  }
}

/// StackTextItem
class StackTextItem extends StackItem<TextItemContent> {
  StackTextItem({
    super.content,
    super.id,
    super.angle = null,
    required super.size,
    super.offset,
    super.lockZOrder = null,
    super.status = null,
    super.flipX = false,
    super.flipY = false,
  });

  factory StackTextItem.fromJson(Map<String, dynamic> data) {
    return StackTextItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? null : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset:
          data['offset'] == null ? null : jsonToOffset(asMap(data['offset'])),
      status: StackItemStatus.values[data['status'] as int],
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      content: TextItemContent.fromJson(asMap(data['content'])),
      flipX: asNullT<bool>(data['flipX']) ?? false,
      flipY: asNullT<bool>(data['flipY']) ?? false,
    );
  }

  /// * 覆盖文本
  /// * Override text
  void setData(String str) {
    content!.data = str;
  }

  @override
  StackTextItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    TextItemContent? content,
    bool? flipX,
    bool? flipY,
  }) {
    return StackTextItem(
      id: id,
      angle: angle ?? this.angle,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      content: content ?? this.content,
    );
  }
}
