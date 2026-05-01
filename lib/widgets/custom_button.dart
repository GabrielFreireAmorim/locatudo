import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Botão primário preto arredondado do LocaTudo.
/// Aparece na HomeScreen (Entrar / Cadastrar), LoginScreen e RegisterScreen.
///
/// Parâmetros:
/// - [label]    : Texto exibido no botão.
/// - [onPressed]: Callback disparado ao pressionar.
/// - [isLoading]: Exibe um CircularProgressIndicator no lugar do texto.
/// - [backgroundColor]: Cor de fundo (padrão: preto).
/// - [foregroundColor]: Cor do texto/ícone (padrão: branco).
/// - [width]    : Largura do botão. Se nulo, ocupa 100% do pai (double.infinity).
/// - [height]   : Altura do botão (padrão: 50).
/// - [borderRadius]: Raio dos cantos arredondados (padrão: 10).
/// - [icon]     : Ícone opcional exibido à esquerda do texto (ex: Google button).
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppTheme.primaryBlack,
    this.foregroundColor = AppTheme.primaryWhite,
    this.width,
    this.height = 50,
    this.borderRadius = 10,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Garante responsividade: se width for nulo, ocupa todo o espaço disponível
    final double effectiveWidth = width ?? double.infinity;

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(effectiveWidth, height),
      maximumSize: Size(effectiveWidth, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      elevation: 0,
    );

    // Conteúdo central: spinner ou texto (com ícone opcional)
    Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 12),
                  Text(label),
                ],
              )
            : Text(label);

    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
