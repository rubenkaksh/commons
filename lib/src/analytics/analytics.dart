import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// The PostHog environment an app reports events under.
enum AnalyticsEnv {
  /// Production. Analytics is enabled here when a project token is set.
  prod,

  /// Development. Analytics is always disabled here.
  dev,
}

/// Configuration for [Analytics.init].
///
/// Apps build one of these at startup and pass it to [Analytics.init].
@immutable
class AnalyticsConfig {
  /// Creates an analytics configuration.
  const AnalyticsConfig({
    required this.projectToken,
    required this.app,
    required this.appVersion,
    this.host = 'https://eu.i.posthog.com',
    this.env = AnalyticsEnv.prod,
    this.allowedEvents,
  });

  /// The public PostHog project token. An empty string disables analytics.
  final String projectToken;

  /// The app name reported with every event, for example `'bhagdori'`.
  final String app;

  /// The app version reported with every event, usually the git short sha.
  final String appVersion;

  /// The PostHog ingestion host.
  final String host;

  /// The environment reported with every event.
  final AnalyticsEnv env;

  /// The app's event contract. Events not in this set are dropped.
  ///
  /// `null` allows any event name that matches the naming rule.
  final Set<String>? allowedEvents;

  /// Whether analytics sends events.
  ///
  /// True only when [projectToken] is non-empty and [env] is
  /// [AnalyticsEnv.prod].
  bool get enabled => projectToken.isNotEmpty && env == AnalyticsEnv.prod;
}

/// Seam over the PostHog SDK so tests can fake it.
abstract class AnalyticsBackend {
  /// Configures the SDK with [projectToken] and [host].
  Future<void> setup(String projectToken, String host);

  /// Registers a super-property [key] with [value] sent on every event.
  Future<void> register(String key, Object value);

  /// Sends the event [eventName] with [properties].
  Future<void> capture(String eventName, Map<String, Object> properties);

  /// Records that the user viewed the screen [screenName].
  Future<void> screen(String screenName);

  /// Stops sending events for this user.
  Future<void> optOut();

  /// Resumes sending events for this user after an opt-out.
  Future<void> optIn();
}

/// [AnalyticsBackend] that forwards to the `posthog_flutter` plugin.
///
/// On web, `Posthog().setup` does nothing. The app must load posthog-js in
/// `web/index.html` and call
/// `posthog.init('<token>', {api_host: 'https://eu.i.posthog.com', persistence: 'localStorage'})`.
/// That keeps a saved anonymous id and sets no cookies.
class PosthogBackend implements AnalyticsBackend {
  /// Creates a backend that uses the shared `Posthog()` instance.
  const PosthogBackend();

  @override
  Future<void> setup(String projectToken, String host) async {
    final config = PostHogConfig(projectToken);
    config.host = host;
    await Posthog().setup(config);
  }

  @override
  Future<void> register(String key, Object value) async {
    await Posthog().register(key, value);
  }

  @override
  Future<void> capture(String eventName, Map<String, Object> properties) async {
    await Posthog().capture(eventName: eventName, properties: properties);
  }

  @override
  Future<void> screen(String screenName) async {
    await Posthog().screen(screenName: screenName);
  }

  @override
  Future<void> optOut() async {
    await Posthog().optOut();
  }

  @override
  Future<void> optIn() async {
    await Posthog().optIn();
  }
}

/// Thin product-analytics wrapper so apps never import `posthog_flutter`.
///
/// Call [init] once at startup. Every other method is a no-op until [init]
/// has enabled analytics. Backend errors are logged and never thrown.
class Analytics {
  /// Creates an analytics client. Uses [PosthogBackend] when [backend] is null.
  Analytics({AnalyticsBackend? backend})
      : _backend = backend ?? PosthogBackend();

  final AnalyticsBackend _backend;

  static final RegExp _eventNamePattern = RegExp(r'^[a-z][a-z0-9_]*$');

  AnalyticsConfig? _config;
  bool _ready = false;

  /// Whether [init] enabled analytics, so events are sent.
  bool get isReady => _ready;

  /// Stores [config] and, when it is enabled, sets up the SDK.
  ///
  /// Registers the super-properties `app`, `app_version`, `platform` and
  /// `env`. Errors from the SDK setup are rethrown.
  Future<void> init(AnalyticsConfig config) async {
    _config = config;
    if (!config.enabled) return;

    await _backend.setup(config.projectToken, config.host);
    await _backend.register('app', config.app);
    await _backend.register('app_version', config.appVersion);
    await _backend.register(
      'platform',
      kIsWeb ? 'web' : defaultTargetPlatform.name,
    );
    await _backend.register('env', config.env.name);
    _ready = true;
  }

  /// Sends the event [event] with [properties].
  ///
  /// Drops the event when analytics is not ready, when [event] is not in the
  /// app's `allowedEvents` contract, or when its name does not match
  /// `^[a-z][a-z0-9_]*$`.
  Future<void> track(
    String event, [
    Map<String, Object> properties = const {},
  ]) async {
    if (!_ready) return;
    final allowed = _config!.allowedEvents;
    if (allowed != null && !allowed.contains(event)) {
      debugPrint('analytics: dropped unknown event "$event"');
      return;
    }
    if (!_eventNamePattern.hasMatch(event)) {
      debugPrint('analytics: dropped unknown event "$event"');
      return;
    }
    await _guard(() => _backend.capture(event, properties));
  }

  /// Records a screen view for [name].
  ///
  /// Does nothing when analytics is not ready.
  Future<void> screen(String name) async {
    if (!_ready) return;
    await _guard(() => _backend.screen(name));
  }

  /// Stops sending events for this user. Does nothing when not ready.
  Future<void> optOut() async {
    if (!_ready) return;
    await _guard(_backend.optOut);
  }

  /// Resumes sending events for this user. Does nothing when not ready.
  Future<void> optIn() async {
    if (!_ready) return;
    await _guard(_backend.optIn);
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('analytics: backend error: $error');
    }
  }
}
