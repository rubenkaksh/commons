import 'package:flutter_test/flutter_test.dart';
import 'package:commons/commons.dart';

class FakeBackend implements AnalyticsBackend {
  final List<String> calls = <String>[];
  Map<String, Object>? lastProps;
  bool throwOnCapture = false;
  bool throwOnSetup = false;
  bool throwOnRegister = false;

  @override
  Future<void> setup(String projectToken, String host) async {
    if (throwOnSetup) throw Exception('boom');
    calls.add('setup:$projectToken:$host');
  }

  @override
  Future<void> register(String key, Object value) async {
    if (throwOnRegister) throw Exception('boom');
    calls.add('register:$key:$value');
  }

  @override
  Future<void> capture(String eventName, Map<String, Object> properties) async {
    if (throwOnCapture) throw Exception('boom');
    lastProps = properties;
    calls.add('capture:$eventName');
  }

  @override
  Future<void> screen(String screenName) async {
    calls.add('screen:$screenName');
  }

  @override
  Future<void> optOut() async {
    calls.add('optOut');
  }

  @override
  Future<void> optIn() async {
    calls.add('optIn');
  }
}

AnalyticsConfig cfg({
  String token = 'tok',
  AnalyticsEnv env = AnalyticsEnv.prod,
  Set<String>? allowed,
}) =>
    AnalyticsConfig(
      projectToken: token,
      app: 'demo',
      appVersion: 'abc123',
      env: env,
      allowedEvents: allowed,
    );

void main() {
  late FakeBackend backend;
  late Analytics analytics;

  setUp(() {
    backend = FakeBackend();
    analytics = Analytics(backend: backend);
  });

  test('init with enabled config sets up, registers and is ready', () async {
    await analytics.init(cfg());

    expect(analytics.isReady, isTrue);
    expect(backend.calls, contains('setup:tok:https://eu.i.posthog.com'));
    expect(backend.calls, contains('register:app:demo'));
    expect(backend.calls, contains('register:app_version:abc123'));
    expect(backend.calls, contains('register:env:prod'));
    expect(
      backend.calls.any((c) => c.startsWith('register:platform:') && c.length > 'register:platform:'.length),
      isTrue,
      reason: 'expected a platform super-property to be registered',
    );
  });

  test('empty token: no backend calls, not ready, track is inert', () async {
    await analytics.init(cfg(token: ''));

    expect(analytics.isReady, isFalse);
    expect(backend.calls, isEmpty);

    await analytics.track('run_started');
    expect(backend.calls, isEmpty);
  });

  test('dev env: no backend calls at all', () async {
    await analytics.init(cfg(env: AnalyticsEnv.dev));

    expect(analytics.isReady, isFalse);
    expect(backend.calls, isEmpty);

    await analytics.track('run_started');
    expect(backend.calls, isEmpty);
  });

  test('track sends capture with the given properties', () async {
    await analytics.init(cfg());

    await analytics.track('run_started', {'level': 1});

    expect(backend.calls, contains('capture:run_started'));
    expect(backend.lastProps, {'level': 1});
  });

  test('allowedEvents drops events outside the contract', () async {
    await analytics.init(cfg(allowed: {'run_started'}));

    await analytics.track('level_failed');
    expect(backend.calls.where((c) => c.startsWith('capture:')), isEmpty);

    await analytics.track('run_started');
    expect(
      backend.calls.where((c) => c.startsWith('capture:')).toList(),
      ['capture:run_started'],
    );
  });

  test('event names must match the snake_case pattern', () async {
    await analytics.init(cfg());

    await analytics.track('Run Started');
    await analytics.track('runStarted');
    expect(backend.calls.where((c) => c.startsWith('capture:')), isEmpty);

    await analytics.track('run_started');
    expect(
      backend.calls.where((c) => c.startsWith('capture:')).toList(),
      ['capture:run_started'],
    );
  });

  test('backend capture errors are swallowed', () async {
    await analytics.init(cfg());
    backend.throwOnCapture = true;

    await analytics.track('run_started');

    expect(analytics.isReady, isTrue);
    backend.throwOnCapture = false;
    await analytics.track('run_started');
    expect(backend.calls, contains('capture:run_started'));
  });

  test('init swallows setup errors and stays disabled', () async {
    backend.throwOnSetup = true;
    await analytics.init(cfg());

    expect(analytics.isReady, isFalse);
    await analytics.track('run_started');
    expect(backend.calls.where((c) => c.startsWith('capture:')), isEmpty);
  });

  test('init swallows register errors and stays disabled', () async {
    backend.throwOnRegister = true;
    await analytics.init(cfg());

    expect(analytics.isReady, isFalse);
  });

  test('re-init with a disabled config disables sending', () async {
    await analytics.init(cfg());
    await analytics.init(cfg(env: AnalyticsEnv.dev));

    expect(analytics.isReady, isFalse);
    await analytics.track('run_started');
    expect(backend.calls.where((c) => c.startsWith('capture:')), isEmpty);
  });

  test('optOut before init is applied after setup', () async {
    await analytics.optOut();
    expect(backend.calls, isEmpty);

    await analytics.init(cfg());
    expect(backend.calls, contains('optOut'));
    expect(
      backend.calls.indexOf('optOut'),
      greaterThan(backend.calls.lastIndexWhere((c) => c.startsWith('register:'))),
    );
  });

  test('optIn before init clears a remembered optOut', () async {
    await analytics.optOut();
    await analytics.optIn();
    await analytics.init(cfg());

    expect(backend.calls, isNot(contains('optOut')));
  });

  test('screen, optOut and optIn forward after init, inert before', () async {
    await analytics.screen('home');
    await analytics.optOut();
    await analytics.optIn();
    expect(backend.calls, isEmpty);

    await analytics.init(cfg());
    await analytics.screen('home');
    await analytics.optOut();
    await analytics.optIn();

    expect(backend.calls, contains('screen:home'));
    expect(backend.calls, contains('optOut'));
    expect(backend.calls, contains('optIn'));
  });
}
