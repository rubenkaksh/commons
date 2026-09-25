import 'package:flutter/material.dart';

/// Semantic status colours Material's ColorScheme lacks. Registered on the
/// theme by ComponentThemes.build; read with BrandColors.of(context).
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
  });

  /// Status colour for positive/success states.
  final Color success;

  /// Content colour paired with [success].
  final Color onSuccess;

  /// Status colour for caution/warning states.
  final Color warning;

  /// Content colour paired with [warning].
  final Color onWarning;

  /// Status colour for neutral/informational states.
  final Color info;

  /// Content colour paired with [info].
  final Color onInfo;

  static const BrandColors light = BrandColors(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFF8A5100),
    onWarning: Color(0xFFFFFFFF),
    info: Color(0xFF0061A4),
    onInfo: Color(0xFFFFFFFF),
  );

  static const BrandColors dark = BrandColors(
    success: Color(0xFF81C784),
    onSuccess: Color(0xFF00390A),
    warning: Color(0xFFFFB951),
    onWarning: Color(0xFF452B00),
    info: Color(0xFF9ECAFF),
    onInfo: Color(0xFF003258),
  );

  /// The theme's BrandColors, or the default for its brightness.
  static BrandColors of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.extension<BrandColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  BrandColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
  }) => BrandColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    info: info ?? this.info,
    onInfo: onInfo ?? this.onInfo,
  );

  @override
  BrandColors lerp(covariant ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandColors &&
          other.success == success &&
          other.onSuccess == onSuccess &&
          other.warning == warning &&
          other.onWarning == onWarning &&
          other.info == info &&
          other.onInfo == onInfo;

  @override
  int get hashCode =>
      Object.hash(success, onSuccess, warning, onWarning, info, onInfo);
}
