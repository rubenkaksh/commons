import 'package:flutter/material.dart';

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
/// The screen itself is framework-free: pure Flutter + [ValueNotifier], no
/// bloc/riverpod/get_it/routing inside the package, zero hardcoded strings.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.displayTexts,
    required this.asyncData,
    required this.callbacks,
    this.enableGoogleSignIn = false,
    this.onRegisterTap,
  });

  final LoginStrings displayTexts;
  final LoginAsyncData asyncData;
  final LoginServiceCallbacks callbacks;

  /// Opt-in Google sign-in. When true, a Google button is rendered and
  /// [LoginServiceCallbacks.googleSignIn] is invoked on tap.
  final bool enableGoogleSignIn;

  /// Opt-in registration entry. When non-null, a "Create an account" button
  /// is rendered under the form and invoked on tap (the app owns navigation,
  /// e.g. pushing its register screen).
  final VoidCallback? onRegisterTap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.displayTexts.appBarTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _buildForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            widget.displayTexts.subtitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.displayTexts.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          TextInput(
            label: widget.displayTexts.emailLabel,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: _emailController,
            validator: widget.displayTexts.emailValidator,
          ),
          const SizedBox(height: 16),
          PasswordInput(
            label: widget.displayTexts.passwordLabel,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            controller: _passwordController,
            validator: widget.displayTexts.passwordValidator,
            onFieldSubmitted: (String _) => _onSubmit(),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: widget.asyncData.errorMessage,
            builder: (BuildContext c, String? message, Widget? _) {
              if (message == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  message,
                  style: TextStyle(color: Theme.of(c).colorScheme.error),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<bool>(
            valueListenable: widget.asyncData.isLoading,
            builder: (BuildContext c, bool loading, Widget? _) {
              return Column(
                children: <Widget>[
                  AppFilledButton(
                    text: widget.displayTexts.submitLabel,
                    icon: loading ? null : const Icon(Icons.login),
                    isLoading: loading,
                    onPressed: loading ? null : _onSubmit,
                  ),
                  if (widget.enableGoogleSignIn) ...<Widget>[
                    const SizedBox(height: 12),
                    AppFilledButton(
                      text: widget.displayTexts.googleSignInLabel,
                      icon: const Icon(Icons.g_mobiledata),
                      isLoading: loading,
                      onPressed: loading ? null : _onGoogleSignIn,
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          AppOutlinedButton(
            text: widget.displayTexts.fillDemoLabel,
            icon: const Icon(Icons.key_outlined),
            onPressed: _fillDemoCredentials,
          ),
          if (widget.onRegisterTap != null) ...<Widget>[
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onRegisterTap,
              child: Text(widget.displayTexts.registerLabel),
            ),
          ],
        ],
      ),
    );
  }

  void _fillDemoCredentials() {
    _emailController.text = widget.displayTexts.demoEmail;
    _passwordController.text = widget.displayTexts.demoPassword;
  }

  Future<void> _onGoogleSignIn() async {
    await widget.callbacks.googleSignIn();
  }

  Future<void> _onSubmit() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }
    await widget.callbacks.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}
