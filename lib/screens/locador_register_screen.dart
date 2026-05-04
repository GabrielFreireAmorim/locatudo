import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_theme.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/user_repository.dart';
import '../utils/input_masks.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class LocadorRegisterScreen extends StatefulWidget {
  const LocadorRegisterScreen({super.key});

  @override
  State<LocadorRegisterScreen> createState() => _LocadorRegisterScreenState();
}

class _LocadorRegisterScreenState extends State<LocadorRegisterScreen> {
  final UserRepository _userRepository = UserRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Step 1
  String _personType = 'Física';

  // Step 2
  final _nameController = TextEditingController();
  final _docController = TextEditingController(); // CPF ou CNPJ

  // Step 3
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  // Step 4
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();

  // Step 5
  XFile? _documentImage;

  // Step 6
  final _storeNameController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];

  // Step 7
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _docController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Fetch Categories
      final cats = await _categoryRepository.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          if (cats.isNotEmpty) _selectedCategoryId = cats.first.id;
        });
      }

      // Fetch User Profile
      final profile = await _userRepository.getUserProfile(user.id);
      if (profile != null) {
        _nameController.text = profile.name;
        _docController.text = profile.cpf ?? '';
        _cepController.text = profile.addressCep ?? '';
        _streetController.text = profile.addressStreet ?? '';
        _numberController.text = profile.addressNumber ?? '';
        _cityController.text = profile.addressCity ?? '';
        _stateController.text = profile.addressState ?? '';
        _phoneController.text = profile.phone ?? '';
      }
    } catch (e) {
      debugPrint('Error loading locador data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => _documentImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você deve aceitar os termos para continuar.')),
      );
      return;
    }

    if (_documentImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, faça o upload de um documento.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado.');

      await _userRepository.submitLocadorApplication(
        userId: user.id,
        personType: _personType,
        phone: _phoneController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        storeName: _storeNameController.text.trim(),
        storeDescription: _storeDescriptionController.text.trim(),
        storeCategory: _selectedCategoryId ?? '',
        addressCep: _cepController.text.trim(),
        addressStreet: _streetController.text.trim(),
        addressNumber: _numberController.text.trim(),
        addressCity: _cityController.text.trim(),
        addressState: _stateController.text.trim(),
        acceptedTerms: _acceptedTerms,
        documentFile: File(_documentImage!.path),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada com sucesso! Em análise.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Tipo'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<String>(
              title: const Text('Pessoa Física'),
              value: 'Física',
              groupValue: _personType,
              activeColor: AppTheme.primaryBlack,
              onChanged: (val) => setState(() => _personType = val!),
            ),
            RadioListTile<String>(
              title: const Text('Pessoa Jurídica'),
              value: 'Jurídica',
              groupValue: _personType,
              activeColor: AppTheme.primaryBlack,
              onChanged: (val) => setState(() => _personType = val!),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Dados'),
        content: Column(
          children: [
            CustomInput(
              label: _personType == 'Física' ? 'Nome Completo' : 'Razão Social',
              controller: _nameController,
              isOutline: true,
              colorScheme: CustomInputColorScheme.light,
            ),
            const SizedBox(height: 15),
            CustomInput(
              label: _personType == 'Física' ? 'CPF' : 'CNPJ',
              controller: _docController,
              isOutline: true,
              colorScheme: CustomInputColorScheme.light,
              keyboardType: TextInputType.number,
              inputFormatters: [CpfInputFormatter()], // Você pode precisar ajustar para Cnpj formatter futuramente
            ),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Endereço'),
        content: Column(
          children: [
            CustomInput(
              label: 'CEP',
              controller: _cepController,
              isOutline: true,
              colorScheme: CustomInputColorScheme.light,
              keyboardType: TextInputType.number,
              inputFormatters: [CepInputFormatter()],
            ),
            const SizedBox(height: 15),
            CustomInput(label: 'Rua', controller: _streetController, isOutline: true, colorScheme: CustomInputColorScheme.light),
            const SizedBox(height: 15),
            CustomInput(label: 'Número', controller: _numberController, isOutline: true, colorScheme: CustomInputColorScheme.light),
            const SizedBox(height: 15),
            CustomInput(label: 'Cidade', controller: _cityController, isOutline: true, colorScheme: CustomInputColorScheme.light),
            const SizedBox(height: 15),
            CustomInput(label: 'Estado (UF)', controller: _stateController, isOutline: true, colorScheme: CustomInputColorScheme.light),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text('Contato'),
        content: Column(
          children: [
            CustomInput(
              label: 'Telefone',
              controller: _phoneController,
              isOutline: true,
              colorScheme: CustomInputColorScheme.light,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            CustomInput(
              label: 'WhatsApp (Opcional)',
              controller: _whatsappController,
              isOutline: true,
              colorScheme: CustomInputColorScheme.light,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
      Step(
        title: const Text('Verificação'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Envie uma foto legível do seu documento (RG, CNH ou Contrato Social).'),
            const SizedBox(height: 15),
            CustomButton(
              label: _documentImage == null ? 'Selecionar Documento' : 'Documento Selecionado ✓',
              onPressed: _pickDocument,
            ),
          ],
        ),
        isActive: _currentStep >= 4,
      ),
      Step(
        title: const Text('Perfil'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomInput(
              label: 'Nome da Loja/Perfil',
              controller: _storeNameController,
              isOutline: true,
              colorScheme: CustomInputColorScheme.light,
            ),
            const SizedBox(height: 15),
            CustomInput(
              label: 'Descrição',
              controller: _storeDescriptionController,
              isOutline: true,
              colorScheme: CustomInputColorScheme.light,
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            const Text('Categoria Principal', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategoryId,
                  hint: const Text('Selecione uma categoria'),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedCategoryId = val);
                  },
                ),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 5,
      ),
      Step(
        title: const Text('Termos'),
        content: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Li e aceito os termos e condições para me tornar Locador na plataforma LocaTudo.'),
          value: _acceptedTerms,
          activeColor: AppTheme.primaryBlack,
          onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        isActive: _currentStep >= 6,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        title: const Text('Tornar-se Locador', style: TextStyle(color: AppTheme.primaryBlack)),
        iconTheme: const IconThemeData(color: AppTheme.primaryBlack),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < _getSteps().length - 1) {
                  setState(() => _currentStep += 1);
                } else {
                  _submit();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              controlsBuilder: (context, details) {
                final isLastStep = _currentStep == _getSteps().length - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                label: isLastStep ? 'Enviar Solicitação' : 'Próximo',
                                onPressed: details.onStepContinue,
                              ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryBlack,
                              side: const BorderSide(color: AppTheme.primaryBlack),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Voltar'),
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              },
              steps: _getSteps(),
            ),
    );
  }
}
