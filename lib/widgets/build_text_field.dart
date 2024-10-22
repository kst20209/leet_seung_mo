import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final BuildContext context;
  final TextEditingController controller;
  final String label;
  final String? error;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const BuildTextField({
    Key? key,
    required this.context,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
  final String buttonText;
  final TextInputType keyboardType;
  final VoidCallback onPressed;
  final FormFieldValidator<String>? validator;
  final String? error;

  BuildTextFieldWithButton({
    required this.context,
    required this.controller,
    required this.label,
    required this.buttonText,
    required this.onPressed,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              TextFormField(
                controller: controller,
                validator: validator,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.brown[50],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.brown,
                    ),
                  ),
                  errorText: error,
                ),
                onChanged: (value) {},
              ),
            ],
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
    );
  }
}

// New widget specifically for Nickname text field
class NicknameTextFieldWithButton extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onPressed;
  final bool isNicknameAvailable;

  NicknameTextFieldWithButton({
    required this.controller,
    required this.onPressed,
    this.isNicknameAvailable = false,
  });

  @override
  _NicknameTextFieldWithButtonState createState() =>
      _NicknameTextFieldWithButtonState();
}

class _NicknameTextFieldWithButtonState
    extends State<NicknameTextFieldWithButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              TextFormField(
                controller: widget.controller,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.brown[50],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: widget.isNicknameAvailable
                          ? Color(0xFF6FB077)
                          : Colors.brown,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              if (!widget.isNicknameAvailable)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    '중복된 닉네임입니다. 다른 닉네임을 입력해주세요.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          child: Text('중복 확인'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: widget.onPressed,
        ),
      ],
    );
  }
}
