import 'package:flutter/material.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

Widget buildGoogleSignInButton({required VoidCallback onPressed}) {
  return (GoogleSignInPlatform.instance as web.GoogleSignInPlugin).renderButton();
}
