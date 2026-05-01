import 'package:flutter/material.dart';

Widget buildGoogleSignInButton({required VoidCallback onPressed}) {
  return OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    icon: const Icon(Icons.login, color: Colors.red),
    label: const Text('Entrar com Google', style: TextStyle(fontWeight: FontWeight.bold)),
    onPressed: onPressed,
  );
}
