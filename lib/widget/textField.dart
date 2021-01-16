import 'package:flutter/material.dart';

Widget textFormField(
    String title, TextEditingController controller, bool obscure) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: title,
      contentPadding: const EdgeInsets.all(15.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      hintText: title,
    ),
    obscureText: obscure,
    controller: controller,
    validator: (value) {
      if (value.isEmpty) {
        return '$title is required!!';
      }
      return null;
    },
  );
}
