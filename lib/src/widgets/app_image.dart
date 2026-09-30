import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// How [AppImage] loads its [AppImage.source].
enum AppImageKind {
  /// A raster image fetched over HTTP(S).
  network,

  /// An SVG fetched over HTTP(S).
  networkSvg,

  /// A raster image bundled with the app.
  asset,

  /// An SVG bundled with the app.
  assetSvg,
}

/// A theme-aware image that picks its loader from [AppImage.kindOf] and falls
/// back to theme-coloured placeholder / error states instead of crashing.
class AppImage extends StatelessWidget {
  /// Creates an image for [source], sized by [width] and [height].
  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
  });

  /// URL (http/https) or asset path of the image; `.svg` selects an SVG loader.
  final String source;

  /// Target width, also applied to the placeholder and error states.
  final double? width;

  /// Target height, also applied to the placeholder and error states.
  final double? height;

  /// How the image is inscribed into the box it is given.
  final BoxFit fit;

  /// Corner rounding applied to the whole widget; `null` means no clipping.
  final BorderRadius? borderRadius;

  /// Shown while a network image loads; defaults to a theme-coloured box.
  final Widget? placeholder;

  /// Shown when the image fails to load; defaults to a broken-image icon on a
  /// theme-coloured box.
  final Widget? errorWidget;

  /// Accessibility description for the image, where the underlying loader
  /// supports one.
  final String? semanticLabel;

  /// Classifies [source]: an `http://` or `https://` prefix (matched
  /// case-insensitively, so `HTTP://` counts) -> network, and a path ending in
  /// `.svg` (case-insensitive, after stripping any `?query` and `#fragment`)
  /// -> the Svg variant.
  ///
  /// `data:` URIs are not supported: they classify as [AppImageKind.asset]
  /// and fail to load — pass a real URL or an asset path instead.
  static AppImageKind kindOf(String source) {
    final String lower = source.toLowerCase();
    final bool isNetwork =
        lower.startsWith('http://') || lower.startsWith('https://');
    // Strip ?query and #fragment, whichever comes first, before the .svg check.
    int end = lower.length;
    final int queryIndex = lower.indexOf('?');
    if (queryIndex != -1) {
      end = queryIndex;
    }
    final int fragmentIndex = lower.indexOf('#');
    if (fragmentIndex != -1 && fragmentIndex < end) {
      end = fragmentIndex;
    }
    final bool isSvg = lower.substring(0, end).endsWith('.svg');
    if (isNetwork) {
      return isSvg ? AppImageKind.networkSvg : AppImageKind.network;
    }
    return isSvg ? AppImageKind.assetSvg : AppImageKind.asset;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget placeholderOrDefault =
        placeholder ??
        SizedBox(
          width: width,
          height: height,
          child: ColoredBox(color: colors.surfaceContainerHighest),
        );
    final Widget errorOrDefault =
        errorWidget ??
        SizedBox(
          width: width,
          height: height,
          child: ColoredBox(
            color: colors.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        );

    final Widget networkImage = CachedNetworkImage(
      imageUrl: source,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => placeholderOrDefault,
      errorWidget: (_, __, ___) => errorOrDefault,
    );

    final Widget image = switch (kindOf(source)) {
      // An unlabelled image must not be announced as a Semantics node at all,
      // so wrap only when a label was actually supplied.
      AppImageKind.network => semanticLabel == null
          ? networkImage
          : Semantics(
              label: semanticLabel,
              image: true,
              child: networkImage,
            ),
      AppImageKind.networkSvg => SvgPicture.network(
        source,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => placeholderOrDefault,
        errorBuilder: (_, __, ___) => errorOrDefault,
        semanticsLabel: semanticLabel,
      ),
      AppImageKind.asset => Image.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (_, __, ___) => errorOrDefault,
      ),
      AppImageKind.assetSvg => SvgPicture.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => placeholderOrDefault,
        errorBuilder: (_, __, ___) => errorOrDefault,
        semanticsLabel: semanticLabel,
      ),
    };

    final BorderRadius? radius = borderRadius;
    if (radius == null) {
      return image;
    }
    return ClipRRect(borderRadius: radius, child: image);
  }
}

/// Opens [source] full screen with pinch-zoom; closes on the close button or
/// back.
Future<void> showFullScreenImage(
  BuildContext context, {
  required String source,
  String? semanticLabel,
}) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (ctx) {
      final ColorScheme colors = Theme.of(ctx).colorScheme;
      return Dialog.fullscreen(
        backgroundColor: colors.surface,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: AppImage(
                    source: source,
                    fit: BoxFit.contain,
                    semanticLabel: semanticLabel,
                    // Explicit states so the full-screen view never falls back
                    // to the grey default slab while loading or on error.
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 48,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  key: const Key('appImageFullScreenClose'),
                  icon: Icon(
                    Icons.close,
                    color: colors.onSurface,
                  ),
                  tooltip: MaterialLocalizations.of(ctx).closeButtonTooltip,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
