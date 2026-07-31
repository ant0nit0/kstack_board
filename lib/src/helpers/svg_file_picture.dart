/// Renders an SVG held in a local file, on the platforms that have local files.
///
/// `SvgPicture.file` cannot simply be called from shared code: on web,
/// flutter_svg swaps `dart:io`'s `File` for its own abstract `File`
/// (`flutter_svg/src/utilities/_file_none.dart`), which `dart:io`'s `File` does
/// not implement. A `kIsWeb` guard does not help — the compiler still
/// type-checks the call — so the two platforms need separate implementations.
///
/// A local file path only ever exists on the device that created it, so on web
/// this branch is unreachable in practice; the web implementation returns null
/// and the caller falls back to its normal placeholder.
export 'svg_file_picture_io.dart'
    if (dart.library.js_interop) 'svg_file_picture_web.dart';
