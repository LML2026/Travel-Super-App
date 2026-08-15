import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int minLines;
  final int? maxLines;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
