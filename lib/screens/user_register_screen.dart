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
  bool _isLoadingData = true; // controla o loading inicial de dados

  XFile? _pickedImage;
  String? _existingAvatarUrl; // URL do avatar já salvo no banco

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

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

  // ---------------------------------------------------------------------------
  // Carregamento inicial dos dados do perfil
  // ---------------------------------------------------------------------------

  Future<void> _loadUserProfile() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return;

      final data = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return;

      _nameController.text = data['name'] ?? '';
      _cpfController.text = data['cpf'] ?? '';
      _existingAvatarUrl = data['profile_image_url'] as String?;

      final address = data['address'] as String?;
      if (address != null && address.isNotEmpty) {
        _parseAddress(address);
      }
    } catch (_) {
      // Falha silenciosa: o usuário preenche manualmente
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  /// Faz o parse do endereço salvo no formato:
  /// "Rua X, 123, Complemento, CEP: 12345-678"
  void _parseAddress(String address) {
    final parts = address.split(', ');

    String cep = '';
    String street = '';
    String number = '';
    String complement = '';

    // CEP é sempre o último segmento com prefixo "CEP: "
    final cepIndex = parts.lastIndexWhere((p) => p.startsWith('CEP: '));
    final remaining = [...parts];

    if (cepIndex != -1) {
      cep = parts[cepIndex].replaceFirst('CEP: ', '');
      remaining.removeAt(cepIndex);
    }

    if (remaining.isNotEmpty) street = remaining[0];
    if (remaining.length > 1) number = remaining[1];
    if (remaining.length > 2) complement = remaining.sublist(2).join(', ');

    _cepController.text = cep;
    _streetController.text = street;
    _complementController.text = complement;

    if (number == 'S/N') {
      _noNumber = true;
      _numberController.clear();
    } else {
      _numberController.text = number;
    }
  }

  // ---------------------------------------------------------------------------
  // Seleção e upload de imagem
  // ---------------------------------------------------------------------------

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
    // Se o usuário não selecionou uma nova foto, preserva a URL existente
    if (_pickedImage == null) return _existingAvatarUrl;

    final fileBytes = await _pickedImage!.readAsBytes();
    final fileExt = _pickedImage!.path.split('.').last.toLowerCase();
    // Caminho: $userId/avatar.$ext → foldername[1] = UUID, satisfaz a política RLS
    final filePath = '$userId/avatar.$fileExt';

    // 'jpg' não é um MIME type válido — o correto é 'image/jpeg'.
    final mimeType = fileExt == 'jpg' ? 'image/jpeg' : 'image/$fileExt';

    await SupabaseService.client.storage.from('avatars').uploadBinary(
          filePath,
          fileBytes,
          fileOptions: FileOptions(
            contentType: mimeType,
            upsert: true,
          ),
        );

    final publicUrl = SupabaseService.client.storage
        .from('avatars')
        .getPublicUrl(filePath);
    
    // Adiciona timestamp para evitar cache (cache busting)
    return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  // ---------------------------------------------------------------------------
  // Salvar perfil
  // ---------------------------------------------------------------------------

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

      // 1. Upload da foto (se selecionada) ou mantém a existente
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  /// Resolve qual imagem exibir no avatar:
  /// 1. Nova foto selecionada pelo usuário (FileImage)
  /// 2. Foto já salva no banco (NetworkImage)
  /// 3. Nenhuma → null (exibe ícone)
  ImageProvider? get _avatarImage {
    if (_pickedImage != null) return FileImage(File(_pickedImage!.path));
    if (_existingAvatarUrl != null) return NetworkImage(_existingAvatarUrl!);
    return null;
  }

  bool get _hasAvatar => _avatarImage != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryBlack),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          backgroundImage: _avatarImage,
                          child: !_hasAvatar
                              ? const Icon(Icons.person,
                                  size: 40, color: AppTheme.textGrey)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 160,
                        child: CustomButton(
                          label:
                              _hasAvatar ? 'Trocar imagem' : 'Carregar imagem',
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
                            onChanged: (val) =>
                                setState(() => _noNumber = val!),
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
