import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../services/supabase_service.dart';
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
  bool _isLoading = false;

  XFile? _pickedImage;

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (_pickedImage == null) return null;

    final fileBytes = await _pickedImage!.readAsBytes();
    final fileExt = _pickedImage!.path.split('.').last.toLowerCase();
    final filePath = 'avatars/$userId.$fileExt';

    await SupabaseService.client.storage.from('avatars').uploadBinary(
          filePath,
          fileBytes,
          fileOptions: FileOptions(
            contentType: 'image/$fileExt',
            upsert: true,
          ),
        );

    final publicUrl =
        SupabaseService.client.storage.from('avatars').getPublicUrl(filePath);

    return publicUrl;
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final cpf = _cpfController.text.trim();
    final cep = _cepController.text.trim();
    final street = _streetController.text.trim();
    final number = _noNumber ? 'S/N' : _numberController.text.trim();
    final complement = _complementController.text.trim();

    if (name.isEmpty || cpf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e CPF/CNPJ.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      // 1. Upload da foto (se selecionada)
      final avatarUrl = await _uploadAvatar(user.id);

      // 2. Monta o endereço completo
      final addressParts = [
        if (street.isNotEmpty) street,
        if (number.isNotEmpty) number,
        if (complement.isNotEmpty) complement,
        if (cep.isNotEmpty) 'CEP: $cep',
      ];
      final fullAddress = addressParts.join(', ');

      // 3. Salva/atualiza o perfil na tabela 'users'
      await SupabaseService.client.from('users').upsert({
        'id': user.id,
        'name': name,
        'email': user.email,
        'cpf': cpf,
        'address': fullAddress,
        if (avatarUrl != null) 'profile_image_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      // 4. Navega para a tela de listagem de produtos (substituindo toda a pilha)
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/product_list',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _pickedImage != null;

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

            CustomInput(
              label: 'Nome completo',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
              controller: _nameController,
            ),
            const SizedBox(height: 20),

            CustomInput(
              label: 'CPF/CNPJ',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
              keyboardType: TextInputType.number,
              controller: _cpfController,
              inputFormatters: [CpfInputFormatter()],
            ),
            const SizedBox(height: 20),

            // Upload de Imagem
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: AppTheme.borderGrey,
                    backgroundImage: hasImage
                        ? FileImage(File(_pickedImage!.path))
                        : null,
                    child: !hasImage
                        ? const Icon(Icons.person,
                            size: 40, color: AppTheme.textGrey)
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 160,
                  child: CustomButton(
                    label: hasImage ? 'Trocar imagem' : 'Carregar imagem',
                    height: 35,
                    borderRadius: 8,
                    onPressed: _pickImage,
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
              controller: _cepController,
              inputFormatters: [CepInputFormatter()],
            ),
            const SizedBox(height: 20),

            CustomInput(
              label: 'Rua',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
              controller: _streetController,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    label: 'Número',
                    colorScheme: CustomInputColorScheme.light,
                    isOutline: true,
                    keyboardType: TextInputType.number,
                    controller: _numberController,
                    enabled: !_noNumber,
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

            CustomInput(
              label: 'Complemento',
              colorScheme: CustomInputColorScheme.light,
              isOutline: true,
              controller: _complementController,
            ),
            const SizedBox(height: 40),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    label: 'Salvar',
                    onPressed: _saveProfile,
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
