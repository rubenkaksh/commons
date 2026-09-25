import 'package:flutter/widgets.dart';

/// Every user-facing string commons renders on its own (labels it does not
/// take as a parameter). English defaults; an app localises them by
/// subclassing and overriding getters from its l10n, then providing the
/// instance with [CommonsStringsScope] (widgets) or the `strings:` parameter
/// of [DioApiClient] (error mapping, which has no [BuildContext]).
class CommonsStrings {
  const CommonsStrings();

  /// The strings from the nearest [CommonsStringsScope], or the English
  /// defaults when there is none.
  static CommonsStrings of(BuildContext context) {
    final CommonsStringsScope? scope = context
        .dependOnInheritedWidgetOfExactType<CommonsStringsScope>();
    return scope?.strings ?? const CommonsStrings();
  }

  String get retry => 'Retry';
  String get cancel => 'Cancel';
  String get genericError => 'Something went wrong.';
  String get showPassword => 'Show password';
  String get hidePassword => 'Hide password';

  String get timeoutError =>
      'The server took too long to respond. Please try again.';
  String get offlineError =>
      'You appear to be offline. Check your connection and try again.';
  String get unexpectedError => 'Something went wrong. Please try again.';
  String clientError(int statusCode) => 'Request failed (HTTP $statusCode).';
  String serverError(int statusCode) =>
      'Server error (HTTP $statusCode). Please try again later.';
}

/// Provides [CommonsStrings] to the commons widgets below it. Place it in
/// `MaterialApp.builder` so it sits under the app's localizations.
class CommonsStringsScope extends InheritedWidget {
  const CommonsStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final CommonsStrings strings;

  @override
  bool updateShouldNotify(CommonsStringsScope oldWidget) =>
      strings != oldWidget.strings;
}
