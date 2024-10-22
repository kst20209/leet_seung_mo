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
              child: FormField<String>(
                initialValue: controller.text,
                validator: validator,
                builder: (FormFieldState<String> state) {
                  final isValid = state.value != null &&
                      state.value!.isNotEmpty &&
                      state.errorText == '사용 가능한 닉네임입니다';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: label,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.brown[50],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isValid ? Color(0xFF6FB077) : Colors.brown,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          state.didChange(value);
                        },
                      ),
                      if (state.errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                              color:
                                  isValid ? Color(0xFF6FB077) : Colors.red[700],
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                    ],
                  );
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
