import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          if (message case final String text) ...[
            const SizedBox(height: 16),
            Text(text),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.icon,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon ?? Icons.inbox_outlined, size: 48),
          if (message case final String text) ...[
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
          ],
          if (actionLabel case final String label when onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAction, child: Text(label)),
          ],
        ],
      ),
    );
  }
}

enum LoadState { loading, error, empty, data }

class StateSwitcher extends StatelessWidget {
  const StateSwitcher({
    super.key,
    required this.state,
    this.onRetry,
    this.loading,
    this.error,
    this.empty,
    required this.data,
  });

  final LoadState state;
  final VoidCallback? onRetry;
  final Widget? loading;
  final Widget Function()? error;
  final Widget? empty;
  final Widget data;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case LoadState.loading:
        return loading ?? const LoadingView();
      case LoadState.error:
        final Widget Function()? errorBuilder = error;
        return errorBuilder == null
            ? ErrorView(message: 'Something went wrong.', onRetry: onRetry)
            : errorBuilder();
      case LoadState.empty:
        return empty ?? const EmptyView();
      case LoadState.data:
        return data;
    }
  }
}
