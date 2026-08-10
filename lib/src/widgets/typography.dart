import 'package:flutter/material.dart';

enum HeadlineSize { large, medium, small }

class Headline extends StatelessWidget {
  const Headline(this.text, {super.key, this.size = HeadlineSize.medium});

  final String text;
  final HeadlineSize size;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final TextStyle? style = switch (size) {
      HeadlineSize.large => theme.headlineLarge,
      HeadlineSize.medium => theme.headlineMedium,
      HeadlineSize.small => theme.headlineSmall,
    };
    return Text(text, style: style);
  }
}

enum TitleSize { large, medium, small }

class AppTitle extends StatelessWidget {
  const AppTitle(this.text, {super.key, this.size = TitleSize.medium});

  final String text;
  final TitleSize size;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final TextStyle? style = switch (size) {
      TitleSize.large => theme.titleLarge,
      TitleSize.medium => theme.titleMedium,
      TitleSize.small => theme.titleSmall,
    };
    return Text(text, style: style);
  }
}

enum BodySize { large, medium, small }

class Body extends StatelessWidget {
  const Body(this.text, {super.key, this.size = BodySize.medium});

  final String text;
  final BodySize size;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final TextStyle? style = switch (size) {
      BodySize.large => theme.bodyLarge,
      BodySize.medium => theme.bodyMedium,
      BodySize.small => theme.bodySmall,
    };
    return Text(text, style: style);
  }
}

enum LabelSize { large, medium, small }

class Label extends StatelessWidget {
  const Label(this.text, {super.key, this.size = LabelSize.medium});

  final String text;
  final LabelSize size;

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final TextStyle? style = switch (size) {
      LabelSize.large => theme.labelLarge,
      LabelSize.medium => theme.labelMedium,
      LabelSize.small => theme.labelSmall,
    };
    return Text(text, style: style);
  }
}
