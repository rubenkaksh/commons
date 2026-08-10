import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.label,
    this.hint,
    this.error,
    this.enabled = true,
    this.obscure = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
  });

  final String label;
  final String? hint;
  final String? error;
  final bool enabled;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      obscureText: obscure,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
    );
  }
}

class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.label,
    this.hint,
    this.error,
    this.onChanged,
    this.onFieldSubmitted,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
  });

  final String label;
  final String? hint;
  final String? error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscured,
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.error,
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscured = !_obscured),
          icon: Icon(
            _obscured ? Icons.visibility_off : Icons.visibility,
          ),
          tooltip: _obscured ? 'Show password' : 'Hide password',
        ),
      ),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    this.hint,
    this.onChanged,
    this.controller,
  });

  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: hint,
      onChanged: onChanged,
      controller: controller,
      leading: const Padding(
        padding: EdgeInsetsDirectional.only(start: 12),
        child: Icon(Icons.search),
      ),
    );
  }
}
