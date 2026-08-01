import 'package:flutter/material.dart' as m;

import '../widgets/buttons.dart';
import '../widgets/inputs.dart';

part 'login_screen_impl.dart';

/// Contract-driven login screen (grandeur pattern).
///
/// The package ships the presentational screen plus three abstract contracts
/// ([LoginStrings], [LoginAsyncData], [LoginServiceCallbacks]) declared in
/// [login_screen_impl]. The consuming app implements the contracts and injects
/// them here — strings/localization, loading/error/authenticated state, and
/// the submit + post-login navigation behaviour all stay app-owned.
///
/// The screen itself is framework-free: pure Flutter + [m.ValueNotifier], no
/// bloc/riverpod/get_it/routing inside the package, zero hardcoded strings.
class LoginScreen extends m.StatefulWidget {
  const LoginScreen({
    super.key,
    required this.displayTexts,
    required this.asyncData,
    required this.callbacks,
  });

  final LoginStrings displayTexts;
  final LoginAsyncData asyncData;
  final LoginServiceCallbacks callbacks;

  @override
  m.State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends m.State<LoginScreen> {
  final m.GlobalKey<m.FormState> _formKey = m.GlobalKey<m.FormState>();
  final m.TextEditingController _emailController = m.TextEditingController();
  final m.TextEditingController _passwordController = m.TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill demo credentials so first render matches the demo flow.
    _emailController.text = widget.displayTexts.demoEmail;
    _passwordController.text = widget.displayTexts.demoPassword;
    widget.asyncData.isAuthenticated.addListener(_handleAuthenticated);
  }

  @override
  void dispose() {
    widget.asyncData.isAuthenticated.removeListener(_handleAuthenticated);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuthenticated() {
    if (!widget.asyncData.isAuthenticated.value) {
      return;
    }
    // Consume the signal so each auth transition fires navigation once.
    widget.asyncData.isAuthenticated.value = false;
    widget.callbacks.navigateForward(context);
  }

  @override
  m.Widget build(m.BuildContext context) {
    return m.Scaffold(
      appBar: m.AppBar(title: m.Text(widget.displayTexts.appBarTitle)),
      body: m.SafeArea(
        child: m.Center(
          child: m.SingleChildScrollView(
            padding: const m.EdgeInsets.all(24),
            child: m.ConstrainedBox(
              constraints: const m.BoxConstraints(maxWidth: 440),
              child: _buildForm(context),
            ),
          ),
        ),
      ),
    );
  }

  m.Widget _buildForm(m.BuildContext context) {
    return m.Form(
      key: _formKey,
      child: m.Column(
        crossAxisAlignment: m.CrossAxisAlignment.stretch,
        children: <m.Widget>[
          m.Text(
            widget.displayTexts.subtitle,
            style: m.Theme.of(context).textTheme.headlineMedium,
          ),
          const m.SizedBox(height: 8),
          m.Text(
            widget.displayTexts.description,
            style: m.Theme.of(context).textTheme.bodyLarge,
          ),
          const m.SizedBox(height: 24),
          TextInput(
            label: widget.displayTexts.emailLabel,
            keyboardType: m.TextInputType.emailAddress,
            textInputAction: m.TextInputAction.next,
            controller: _emailController,
            validator: widget.displayTexts.emailValidator,
          ),
          const m.SizedBox(height: 16),
          PasswordInput(
            label: widget.displayTexts.passwordLabel,
            keyboardType: m.TextInputType.visiblePassword,
            textInputAction: m.TextInputAction.done,
            controller: _passwordController,
            validator: widget.displayTexts.passwordValidator,
            onFieldSubmitted: (String _) => _onSubmit(),
          ),
          m.ValueListenableBuilder<String?>(
            valueListenable: widget.asyncData.errorMessage,
            builder: (m.BuildContext c, String? message, m.Widget? _) {
              if (message == null) {
                return const m.SizedBox.shrink();
              }
              return m.Padding(
                padding: const m.EdgeInsets.only(top: 16),
                child: m.Text(
                  message,
                  style: m.TextStyle(color: m.Theme.of(c).colorScheme.error),
                ),
              );
            },
          ),
          const m.SizedBox(height: 24),
          m.ValueListenableBuilder<bool>(
            valueListenable: widget.asyncData.isLoading,
            builder: (m.BuildContext c, bool loading, m.Widget? _) {
              return FilledButton(
                text: widget.displayTexts.submitLabel,
                icon: loading ? null : const m.Icon(m.Icons.login),
                isLoading: loading,
                onPressed: loading ? null : _onSubmit,
              );
            },
          ),
          const m.SizedBox(height: 12),
          OutlineButton(
            text: widget.displayTexts.fillDemoLabel,
            icon: const m.Icon(m.Icons.key_outlined),
            onPressed: _fillDemoCredentials,
          ),
        ],
      ),
    );
  }

  void _fillDemoCredentials() {
    _emailController.text = widget.displayTexts.demoEmail;
    _passwordController.text = widget.displayTexts.demoPassword;
  }

  Future<void> _onSubmit() async {
    final m.FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    await widget.callbacks.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}
