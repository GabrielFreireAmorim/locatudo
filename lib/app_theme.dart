import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais identificadas no layout
  static const Color primaryOrange = Color(0xFFFF8A00); // Laranja vibrante
  static const Color primaryBlack = Colors.black;       // Preto
  static const Color primaryWhite = Colors.white;       // Branco
  static const Color primaryWhite70 = Color(0xB3FFFFFF); // Branco com 70% de opacidade  

  // Cores secundárias baseadas nas novas telas
  static const Color textGrey = Color(0xFF757575);      // Textos descritivos e placeholders
  static const Color borderGrey = Color(0xFFE0E0E0);    // Bordas de cards e inputs
  static const Color statusGreen = Color(0xFF4CAF50);   // Status "CONFIRMADO"
  static const Color statusRed = Color(0xFFF44336);     // Status "AGUARDANDO CONFIRMAÇÃO"

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: primaryWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryOrange,
        secondary: primaryBlack,
        surface: primaryWhite,
      ),
      // Configuração global para AppBars (vistos nas telas de lista e detalhes)
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryWhite,
        foregroundColor: primaryBlack,
        elevation: 0, // Sem sombra por padrão para um visual mais limpo
        centerTitle: true,
      ),
      // Configuração global para botões (como vistos na HomeScreen, Login e Register)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlack,
          foregroundColor: primaryWhite,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Configuração global para inputs de texto (como vistos no Login e Register)
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryWhite, width: 2.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryWhite, width: 3.0),
        ),
        labelStyle: TextStyle(color: primaryWhite, fontSize: 16),
        hintStyle: TextStyle(color: primaryWhite70, fontSize: 16),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: primaryBlack),
      ),
    );
  }
}
