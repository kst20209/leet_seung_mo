import 'package:flutter/material.dart';

Widget BuildTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  String? error,
  bool obscureText = false,
  String? Function(String?)? validator,
}) {
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
        validator: validator,
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 12),
          child: Text(
            error,
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
        ),
    ],
  );
}

Widget BuildTextFieldWithButton({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  String? error,
  required String buttonText,
  required VoidCallback onPressed,
  String? Function(String?)? validator,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
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
                  ),
                  validator: validator,
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 12),
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red[700], fontSize: 12),
                    ),
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
      ),
    ],
  );
}
