import 'package:flutter/material.dart';

class NormalInputField extends StatelessWidget {
  final String title;
  final TextEditingController? controller;
  final String hint;
  final bool? obsecureText;
  final Widget? widget;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const NormalInputField({
    super.key,
    required this.title,
    this.controller,
    required this.hint,
    this.widget,
    this.obsecureText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget != null;

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            decoration: BoxDecoration(
              color: isReadOnly ? Colors.grey[50] : Colors.white,
              border: Border.all(width: 1.5, color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.1 * 255).round()),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    autofocus: false,
                    obscureText: obsecureText ?? false,
                    readOnly: isReadOnly,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    validator: validator,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ),
                if (widget != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: widget!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
