import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stack_board_plus/stack_board_plus.dart';

class ImageItemContent extends StackItemContent {
  ImageItemContent({
    this.url,
    this.assetName,
    this.bytes,
    this.file,
    this.svgString,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit = BoxFit.cover,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.cornerRadius,
    this.loading = false,
  }) {
    _init();
  }

  ImageItemContent copyWith({
    String? url,
    String? assetName,
    Uint8List? bytes,
    File? file,
    String? svgString,
    String? semanticLabel,
    bool? excludeFromSemantics,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    ImageRepeat? repeat,
    bool? matchTextDirection,
    bool? gaplessPlayback,
    bool? isAntiAlias,
    FilterQuality? filterQuality,
    double? cornerRadius,
    bool? loading,
  }) {
    return ImageItemContent(
      url: url ?? this.url,
      assetName: assetName ?? this.assetName,
      bytes: bytes ?? this.bytes,
      file: file ?? this.file,
      svgString: svgString ?? this.svgString,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      excludeFromSemantics: excludeFromSemantics ?? this.excludeFromSemantics,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      colorBlendMode: colorBlendMode ?? this.colorBlendMode,
      fit: fit ?? this.fit,
      repeat: repeat ?? this.repeat,
      matchTextDirection: matchTextDirection ?? this.matchTextDirection,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      isAntiAlias: isAntiAlias ?? this.isAntiAlias,
      filterQuality: filterQuality ?? this.filterQuality,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      loading: loading ?? this.loading,
    );
  }

  factory ImageItemContent.fromJson(Map<String, dynamic> json) {
    return ImageItemContent(
      url: json['url'] != null ? asT<String>(json['url']) : null,
      assetName:
          json['assetName'] != null ? asT<String>(json['assetName']) : null,
      svgString:
          json['svgString'] != null ? asT<String>(json['svgString']) : null,
      semanticLabel: json['semanticLabel'] != null
          ? asT<String>(json['semanticLabel'])
          : null,
      excludeFromSemantics:
          asNullT<bool>(json['excludeFromSemantics']) ?? false,
      width: json['width'] != null ? asT<double>(json['width']) : null,
      height: json['height'] != null ? asT<double>(json['height']) : null,
      color: json['color'] != null ? Color(asT<int>(json['color'])) : null,
      colorBlendMode: json['colorBlendMode'] != null
          ? BlendMode.values[asT<int>(json['colorBlendMode'])]
          : BlendMode.srcIn,
      fit: json['fit'] != null
          ? BoxFit.values[asT<int>(json['fit'])]
          : BoxFit.cover,
      repeat: json['repeat'] != null
          ? ImageRepeat.values[asT<int>(json['repeat'])]
          : ImageRepeat.noRepeat,
      matchTextDirection: asNullT<bool>(json['matchTextDirection']) ?? false,
      gaplessPlayback: asNullT<bool>(json['gaplessPlayback']) ?? false,
      isAntiAlias: asNullT<bool>(json['isAntiAlias']) ?? true,
      filterQuality: json['filterQuality'] != null
          ? FilterQuality.values[asT<int>(json['filterQuality'])]
          : FilterQuality.high,
      bytes: json['bytes'] != null ? base64Decode(json['bytes']) : null,
      file: json['filePath'] != null ? File(json['filePath']) : null,
      cornerRadius: json['cornerRadius'] != null
          ? asT<double>(json['cornerRadius'])
          : null,
      loading: asNullT<bool>(json['loading']) ?? false,
    );
  }

  factory ImageItemContent.svg({
    required String svgString,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.contain,
    bool matchTextDirection = false,
    FilterQuality filterQuality = FilterQuality.low,
    double? cornerRadius,
  }) {
    return ImageItemContent(
      svgString: svgString,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      matchTextDirection: matchTextDirection,
      filterQuality: filterQuality,
      cornerRadius: cornerRadius,
    );
  }

  void _init() {
    final sources = {
      'url': url,
      'assetName': assetName,
      'bytes': bytes,
      'file': file,
      'svgString': svgString,
    };

    final nonNullSources =
        sources.entries.where((e) => e.value != null).toList();

    if (!loading) {
      if (nonNullSources.length != 1) {
        final selected = nonNullSources.map((e) => e.key).join(', ');
        throw Exception(
          nonNullSources.isEmpty
              ? 'One image source must be provided: url, assetName, bytes, file, or svgString.'
              : 'Only one image source can be used at a time. Found multiple: $selected',
        );
      }
    }

    /// Reset loading state for new content
    _isLoaded = false;
    _hasError = false;
    _isLoading = false;
    _loadingCompleter?.complete();
    _loadingCompleter = null;

    /// Handle different image sources and detect SVG content
    if (svgString != null) {
      /// Direct SVG string provided
      _isSvg = true;
      _isLoaded = true;
      _svgWidget = SvgPicture.string(
        svgString!,
        width: width,
        height: height,
        fit: fit,
        semanticsLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        colorFilter: color != null
            ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
            : null,
        matchTextDirection: matchTextDirection,
      );
    } else if (url != null) {
      _isSvg = _isSvgUrl(url!);
      if (_isSvg) {
        _svgWidget = SvgPicture.network(
          url!,
          width: width,
          height: height,
          fit: fit,
          semanticsLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          colorFilter: color != null
              ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
              : null,
          matchTextDirection: matchTextDirection,
        );
      } else {
        if (url!.startsWith('http') || url!.startsWith('https')) {
          _image = NetworkImage(url!);
        } else {
          _image = FileImage(File(url!));
        }
      }
    } else if (assetName != null) {
      _isSvg = _isSvgPath(assetName!);
      if (_isSvg) {
        _svgWidget = SvgPicture.asset(
          assetName!,
          width: width,
          height: height,
          fit: fit,
          semanticsLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          colorFilter: color != null
              ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
              : null,
          matchTextDirection: matchTextDirection,
        );
      } else {
        _image = AssetImage(assetName!);
        _isLoaded = true;
      }
    } else if (file != null) {
      // Check if file is an SVG
      _isSvg = _isSvgPath(file!.path);
      if (_isSvg) {
        _svgWidget = SvgPicture.file(
          file!,
          width: width,
          height: height,
          fit: fit,
          semanticsLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          colorFilter: color != null
              ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
              : null,
          matchTextDirection: matchTextDirection,
        );
      } else {
        _image = FileImage(file!);
      }
    } else if (bytes != null) {
      /// Check if bytes represent an SVG
      _isSvg = _isSvgBytes(bytes!);
      if (_isSvg) {
        final svgContent = utf8.decode(bytes!);
        _isLoaded = true;
        _svgWidget = SvgPicture.string(
          svgContent,
          width: width,
          height: height,
          fit: fit,
          semanticsLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          colorFilter: color != null
              ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
              : null,
          matchTextDirection: matchTextDirection,
        );
      } else {
        _image = MemoryImage(bytes!);
        _isLoaded = true;
      }
    }
  }

  /// Helper methods to detect SVG content
  bool _isSvgUrl(String url) {
    // print("Checking if URL is SVG: $url");
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final path = uri.path.toLowerCase();
      return path.endsWith('.svg');
    }
    return url.toLowerCase().endsWith('.svg');
  }

  bool _isSvgPath(String path) {
    return path.toLowerCase().endsWith('.svg');
  }

  bool _isSvgBytes(Uint8List bytes) {
    try {
      final content = utf8.decode(bytes);

      /// Check if content starts with SVG markers
      final trimmed = content.trim().toLowerCase();
      return trimmed.startsWith('<svg') ||
          trimmed.startsWith('<?xml') && trimmed.contains('<svg');
    } catch (e) {
      return false;
    }
  }

  late ImageProvider? _image;
  SvgPicture? _svgWidget;
  bool _isSvg = false;

  /// Loading state management
  bool _isLoaded = false;
  bool _hasError = false;
  bool _isLoading = false;
  Completer<void>? _loadingCompleter;

  String? url;
  String? assetName;
  String? svgString;
  String? semanticLabel;
  bool excludeFromSemantics;
  double? width;
  double? height;
  Color? color;
  BlendMode? colorBlendMode;
  BoxFit fit;
  ImageRepeat repeat;
  bool matchTextDirection;
  bool gaplessPlayback;
  bool isAntiAlias;
  Uint8List? bytes;
  File? file;
  FilterQuality filterQuality;
  double? cornerRadius;
  bool loading;

  ImageProvider? get image => _image;
  SvgPicture? get svgWidget => _svgWidget;
  bool get isSvg => _isSvg;

  void setRes({
    String? url,
    String? assetName,
    Uint8List? bytes,
    File? file,
    String? svgString,
  }) {
    if (url != null) this.url = url;
    if (assetName != null) this.assetName = assetName;
    if (bytes != null) this.bytes = bytes;
    if (file != null) this.file = file;
    if (svgString != null) this.svgString = svgString;

    /// Clear previous state
    _image = null;
    _svgWidget = null;
    _isSvg = false;

    /// Reset loading state
    _isLoaded = false;
    _hasError = false;
    _isLoading = false;
    _loadingCompleter?.complete();
    _loadingCompleter = null;

    _init();
  }

  /// Method to build the appropriate widget
  Widget buildWidget() {
    return _buildWidgetWithShimmer();
  }

  /// Create shimmer placeholder
  Widget _buildWidgetWithShimmer() {
    if (loading) {
      return _buildShimmerPlaceholder();
    }

    // If already loaded and no error, return the content directly
    if (_isLoaded && !_hasError) {
      return _buildContentWidget();
    }

    // If there's an error, show error widget
    if (_hasError) {
      return _buildErrorWidget();
    }

    // For SVG content
    if (_isSvg && _svgWidget != null) {
      if (svgString != null) {
        // Direct SVG string - mark as loaded immediately
        _markAsLoaded();
        return _svgWidget!;
      } else {
        // Network or asset SVG - use cached loading state
        return _buildSvgWithLoadingState();
      }
    }
    // For regular images
    else if (_image != null) {
      return _buildImageWithLoadingState();
    }
    // Fallback for no content
    else {
      _markAsError();
      return _buildErrorWidget();
    }
  }

  Widget _buildContentWidget() {
    if (_isSvg && _svgWidget != null) {
      return _svgWidget!;
    } else if (_image != null) {
      return Image(
        image: _image!,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
        color: color,
        colorBlendMode: colorBlendMode,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
      );
    }
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.error, color: Colors.red),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return SizedBox(
      width: width,
      height: height,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  /// Use a one-time check that doesn't re-trigger on rebuilds
  Widget _buildSvgWithLoadingState() {
    if (!_isLoading && !_isLoaded) {
      _startSvgLoading();
    }

    if (_isLoaded) {
      return _svgWidget!;
    }

    return _buildShimmerPlaceholder();
  }

  /// Network image with proper loading state management
  Widget _buildImageWithLoadingState() {
    if (_image is NetworkImage) {
      return Image(
        image: _image!,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
        color: color,
        colorBlendMode: colorBlendMode,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _markAsLoaded();
            });
            return child;
          }
          return _buildShimmerPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markAsError();
          });
          return _buildErrorWidget();
        },
      );
    } else if (_image is FileImage) {
      if (!_isLoading && !_isLoaded) {
        _startFileLoading();
      }

      if (_isLoaded) {
        return _buildContentWidget();
      } else if (_hasError) {
        return _buildErrorWidget();
      }

      return _buildShimmerPlaceholder();
    } else {
      return Image(
        image: _image!,
        width: width,
        height: height,
        fit: fit,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
        color: color,
        colorBlendMode: colorBlendMode,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _markAsLoaded();
            });
            return child;
          }
          return _buildShimmerPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _markAsError();
          });
          return _buildErrorWidget();
        },
      );
    }
  }

  void _startSvgLoading() {
    if (_isLoading) return;

    _isLoading = true;
    _loadingCompleter = Completer<void>();

    Future.delayed(const Duration(milliseconds: 50)).then((_) {
      if (!_loadingCompleter!.isCompleted) {
        _markAsLoaded();
      }
    });
  }

  void _startFileLoading() {
    if (_isLoading) return;

    _isLoading = true;
    _loadingCompleter = Completer<void>();

    if (file != null) {
      file!.exists().then((exists) {
        if (!_loadingCompleter!.isCompleted) {
          if (exists) {
            _markAsLoaded();
          } else {
            _markAsError();
          }
        }
      }).catchError((_) {
        if (!_loadingCompleter!.isCompleted) {
          _markAsError();
        }
      });
    } else {
      _markAsError();
    }
  }

  void _markAsLoaded() {
    _isLoaded = true;
    _hasError = false;
    _isLoading = false;
    _loadingCompleter?.complete();
  }

  void _markAsError() {
    _isLoaded = false;
    _hasError = true;
    _isLoading = false;
    _loadingCompleter?.complete();
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (url != null) 'url': url,
      if (assetName != null) 'assetName': assetName,
      if (bytes != null) 'bytes': base64Encode(bytes!),
      if (file != null) 'filePath': file!.path,
      if (svgString != null) 'svgString': svgString,
      if (semanticLabel != null) 'semanticLabel': semanticLabel,
      'excludeFromSemantics': excludeFromSemantics,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (color != null) 'color': color?.toARGB32(),
      if (colorBlendMode != null) 'colorBlendMode': colorBlendMode?.index,
      'fit': fit.index,
      'repeat': repeat.index,
      'matchTextDirection': matchTextDirection,
      'gaplessPlayback': gaplessPlayback,
      'isAntiAlias': isAntiAlias,
      'filterQuality': filterQuality.index,
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
      'loading': loading,
    };
  }

  @override
  ImageItemContent resize(double scaleFactor) {
    return copyWith(
      width: width != null ? width! * scaleFactor : null,
      height: height != null ? height! * scaleFactor : null,
      cornerRadius: cornerRadius != null ? cornerRadius! * scaleFactor : null,
    );
  }
}

class StackImageItem extends StackItem<ImageItemContent> {
  StackImageItem({
    required super.content,
    super.id,
    super.angle = null,
    required super.size,
    super.offset,
    super.status = null,
    super.lockZOrder = null,
    super.flipX = false,
    super.flipY = false,
    super.locked = false,
  });

  factory StackImageItem.fromJson(Map<String, dynamic> data) {
    return StackImageItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? null : asT<double>(data['angle']),
      size: jsonToSize(asMap(data['size'])),
      offset:
          data['offset'] == null ? null : jsonToOffset(asMap(data['offset'])),
      status: StackItemStatus.values[data['status'] as int],
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      locked: asNullT<bool>(data['locked']) ?? false,
      flipX: asNullT<bool>(data['flipX']) ?? false,
      flipY: asNullT<bool>(data['flipY']) ?? false,
      content: ImageItemContent.fromJson(asMap(data['content'])),
    );
  }

  factory StackImageItem.svg({
    required String svgString,
    required Size size,
    String? id,
    double? angle,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.contain,
    bool matchTextDirection = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool flipX = false,
    bool flipY = false,
    bool locked = false,
  }) {
    return StackImageItem(
      id: id,
      size: size,
      offset: offset,
      angle: angle,
      status: status,
      lockZOrder: lockZOrder,
      locked: locked,
      flipX: flipX,
      flipY: flipY,
      content: ImageItemContent.svg(
        svgString: svgString,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        matchTextDirection: matchTextDirection,
        filterQuality: filterQuality,
      ),
    );
  }

  factory StackImageItem.url({
    required String url,
    required Size size,
    String? id,
    double? angle,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.cover,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool flipX = false,
    bool flipY = false,
    bool locked = false,
  }) {
    return StackImageItem(
      id: id,
      size: size,
      offset: offset,
      angle: angle,
      status: status,
      flipX: flipX,
      flipY: flipY,
      lockZOrder: lockZOrder,
      locked: locked,
      content: ImageItemContent(
        url: url,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
      ),
    );
  }

  factory StackImageItem.asset({
    required String assetName,
    required Size size,
    String? id,
    double? angle,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.cover,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool flipX = false,
    bool flipY = false,
    bool locked = false,
  }) {
    return StackImageItem(
      id: id,
      size: size,
      offset: offset,
      angle: angle,
      status: status,
      lockZOrder: lockZOrder,
      flipX: flipX,
      flipY: flipY,
      locked: locked,
      content: ImageItemContent(
        assetName: assetName,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
      ),
    );
  }

  factory StackImageItem.file({
    required File file,
    required Size size,
    String? id,
    double? angle,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.cover,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool flipX = false,
    bool flipY = false,
    bool locked = false,
  }) {
    return StackImageItem(
      id: id,
      size: size,
      offset: offset,
      angle: angle,
      status: status,
      lockZOrder: lockZOrder,
      flipX: flipX,
      flipY: flipY,
      locked: locked,
      content: ImageItemContent(
        file: file,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
      ),
    );
  }

  factory StackImageItem.bytes({
    required Uint8List bytes,
    required Size size,
    String? id,
    double? angle,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.cover,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool flipX = false,
    bool flipY = false,
    bool locked = false,
  }) {
    return StackImageItem(
      id: id,
      size: size,
      offset: offset,
      angle: angle,
      status: status,
      lockZOrder: lockZOrder,
      flipX: flipX,
      flipY: flipY,
      locked: locked,
      content: ImageItemContent(
        bytes: bytes,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        isAntiAlias: isAntiAlias,
        filterQuality: filterQuality,
      ),
    );
  }

  factory StackImageItem.loading({
    required Size size,
    String? id,
    double? angle,
    Offset? offset,
    StackItemStatus? status,
    bool? lockZOrder,
    double? width,
    double? height,
    double? cornerRadius,
    bool flipX = false,
    bool flipY = false,
    bool locked = false,
  }) {
    return StackImageItem(
      id: id,
      size: size,
      offset: offset,
      angle: angle,
      status: status,
      lockZOrder: lockZOrder,
      flipX: flipX,
      flipY: flipY,
      locked: locked,
      content: ImageItemContent(
        loading: true,
        width: width,
        height: height,
        cornerRadius: cornerRadius,
      ),
    );
  }

  void setUrl(String url) {
    content?.setRes(url: url);
  }

  void setAssetName(String assetName) {
    content?.setRes(assetName: assetName);
  }

  void setSvgString(String svgString) {
    content?.setRes(svgString: svgString);
  }

  void setFile(File file) {
    content?.setRes(file: file);
  }

  void setBytes(Uint8List bytes) {
    content?.setRes(bytes: bytes);
  }

  @override
  StackImageItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    bool? flipX,
    bool? flipY,
    ImageItemContent? content,
    bool? locked,
  }) {
    return StackImageItem(
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      lockZOrder: lockZOrder ?? this.lockZOrder,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      content: content ?? this.content,
      locked: locked ?? this.locked,
    );
  }
}
