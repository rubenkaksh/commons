import 'package:flutter/material.dart';

/// A phone number input field with +977 prefix and 10-digit mobile validation.
///
/// Validates 10-digit mobile numbers.
/// Use [PhoneInput.isValid] to check validity programmatically.
class PhoneInput extends StatelessWidget {
  const PhoneInput({
    super.key,
    this.onChanged,
    this.error,
    this.controller,
    this.autofocus = false,
  });

  final ValueChanged<String>? onChanged;
  final String? error;
  final TextEditingController? controller;
  final bool autofocus;

  static final RegExp _mobileRegex = RegExp(r'^[6-9]\d{9}$');

  /// Returns true if [phone] is a valid 10-digit mobile number.
  static bool isValid(String phone) {
    return _mobileRegex.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '9876543210',
        errorText: error,
        counterText: '',
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 12, right: 8),
          child: Text(
            '+977',
            style: TextStyle(fontSize: 16),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
      onChanged: onChanged,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        }
        if (!isValid(value)) {
          return 'Enter a valid 10-digit mobile number';
        }
        return null;
      },
    );
  }
}
