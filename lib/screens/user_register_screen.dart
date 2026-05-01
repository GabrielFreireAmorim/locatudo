import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../utils/input_masks.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  bool _noNumber = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryBlack),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: 20),

            const CustomInput(
              label: 'Nome completo',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
            ),
            const SizedBox(height: 20),

            CustomInput(
              label: 'CPF/CNPJ',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CpfInputFormatter()
              ], // Aplicando máscara de CPF
            ),
            const SizedBox(height: 20),

            // Upload de Imagem
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: AppTheme.borderGrey,
                  child: Icon(Icons.person, size: 40, color: AppTheme.textGrey),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 160,
                  child: CustomButton(
                    label: 'Carregar imagem',
                    height: 35,
                    borderRadius: 8,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            CustomInput(
              label: 'CEP',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CepInputFormatter()
              ], // Aplicando máscara de CEP
            ),
            const SizedBox(height: 20),

            const CustomInput(
              label: 'Rua',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(
                  child: CustomInput(
                    label: 'Número',
                    colorScheme: CustomInputColorScheme.light,
                    isOutline: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 15),
                Row(
                  children: [
                    Checkbox(
                      value: _noNumber,
                      activeColor: AppTheme.primaryBlack,
                      onChanged: (val) => setState(() => _noNumber = val!),
                    ),
                    const Text('Sem número'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            const CustomInput(
              label: 'Complemento',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
            ),
            const SizedBox(height: 40),

            CustomButton(
              label: 'Salvar',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
