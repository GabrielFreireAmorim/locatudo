import 'package:flutter/services.dart';

class MaskedInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedInputFormatter({required this.mask, required this.separator});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > oldValue.text.length) {
      if (newValue.text.length > mask.length) return oldValue;
      if (newValue.text.length < mask.length && mask[newValue.text.length - 1] == separator) {
        return TextEditingValue(
          text: '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
          selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
        );
      }
    }
    return newValue;
  }
}

/// Formatador simples para CPF (000.000.000-00)
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) text = text.substring(0, 11);

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 2 || i == 5) && i != text.length - 1) buffer.write('.');
      if (i == 8 && i != text.length - 1) buffer.write('-');
    }

    final newText = buffer.toString();
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// Formatador simples para CEP (00000-000)
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 8) text = text.substring(0, 8);

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 4 && i != text.length - 1) buffer.write('-');
    }

    final newText = buffer.toString();
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
