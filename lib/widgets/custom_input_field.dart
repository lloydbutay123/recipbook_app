import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String errorMessage;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final InputBorder? inputBorder;

  const CustomInputField({
    required this.label,
    required this.controller,
    required this.errorMessage,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.inputBorder,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          obscureText: obscureText,
          onTap: onTap,
          decoration: InputDecoration(
            border: inputBorder,
            hintText: "Enter your $label",
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMessage;
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
