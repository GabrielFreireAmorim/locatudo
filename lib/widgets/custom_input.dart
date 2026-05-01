import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';

/// Campo de texto com linha inferior reutilizável do LocaTudo.
/// Adapta as cores do underline e do label automaticamente conforme o
/// [colorScheme] informado: 'dark' (fundo laranja) ou 'light' (fundo branco).
///
/// Parâmetros:
/// - [label]         : Texto do label flutuante.
/// - [controller]    : TextEditingController opcional.
/// - [obscureText]   : Define se o campo é para senha (padrão: false).
/// - [keyboardType]  : Tipo de teclado (padrão: text).
/// - [colorScheme]   : 'dark' (label/borda brancos) ou 'light' (label/borda cinza/preto).
/// - [validator]     : Função de validação para uso com Form.
/// - [inputFormatters]: Formatadores de entrada opcionais.
/// - [onChanged]     : Callback disparado ao alterar o texto.
/// - [suffixIcon]    : Ícone opcional no final do campo (ex: olho para senha).
enum CustomInputColorScheme { dark, light }

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final CustomInputColorScheme colorScheme;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool isOutline;
  final bool enabled;

  const CustomInput({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.colorScheme = CustomInputColorScheme.dark,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.suffixIcon,
    this.isOutline = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve cores conforme o esquema selecionado
    final bool isDark = colorScheme == CustomInputColorScheme.dark;

    final Color labelColor =
        isDark ? AppTheme.primaryWhite : AppTheme.textGrey;
    final Color activeColor =
        isDark ? AppTheme.primaryWhite : AppTheme.primaryBlack;
    final Color textColor =
        isDark ? AppTheme.primaryWhite : AppTheme.primaryBlack;
    final Color borderColor =
        isDark ? AppTheme.primaryWhite : AppTheme.borderGrey;
    final Color focusedBorderColor =
        isDark ? AppTheme.primaryWhite : AppTheme.primaryOrange;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      cursorColor: activeColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor, fontSize: 16),
        suffixIcon: suffixIcon,
        // Define o tipo de borda (Underline ou Outline) dinamicamente
        enabledBorder: isOutline 
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: borderColor, width: 1.0),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
        focusedBorder: isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: focusedBorderColor, width: 2.5),
              ),
        errorBorder: isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppTheme.statusRed, width: 1.0),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.statusRed, width: 1.5),
              ),
        focusedErrorBorder: isOutline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: AppTheme.statusRed, width: 2.0),
              )
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.statusRed, width: 2.5),
              ),
        filled: false,
        contentPadding: isOutline 
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
            : const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
