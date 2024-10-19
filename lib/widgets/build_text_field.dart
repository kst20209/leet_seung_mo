import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final String label;
  final String? error;
  final bool obscureText;
  final String? Function(String?)? validator;

  const BuildTextField({
    Key? key,
    required this.context,
    required this.controller,
    required this.label,
    this.error,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.brown[50],
          ),
          obscureText: obscureText,
          validator: (value) {
            if (error != null) return error;
            return validator?.call(value);
          },
        ),
      ],
    );
  }
}

class BuildTextFieldWithButton extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final String label;
  final String? error;
  final String buttonText;
  final VoidCallback onPressed;
  final String? Function(String?)? validator;

  const BuildTextFieldWithButton({
    Key? key,
    required this.context,
    required this.controller,
    required this.label,
    this.error,
    required this.buttonText,
    required this.onPressed,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.brown[50],
                ),
                validator: (value) {
                  if (error != null) return error;
                  return validator?.call(value);
                },
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              child: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed,
            ),
          ],
        ),
      ],
    );
  }
}
