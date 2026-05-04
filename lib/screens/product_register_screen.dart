import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/product_repository.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');

  final _categoryRepo = CategoryRepository();
  final _productRepo = ProductRepository();

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String _pricingType = 'DAILY'; // 'DAILY' ou 'HOURLY'
  
  bool _pickupLocally = false;
  TimeOfDay? _pickupTimeStart;
  TimeOfDay? _pickupTimeEnd;
  String? _pickupDays; // 'ALL_DAYS', 'WEEKDAYS', 'WEEKENDS'

  List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepo.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e'), backgroundColor: AppTheme.statusRed),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  Future<void> _pickImage() async {
    if (_imageFiles.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo de 5 imagens permitido.'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }
    
    try {
      final pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (pickedFiles.isNotEmpty) {
        int added = 0;
        for (var pickedFile in pickedFiles) {
          if (_imageFiles.length >= 5) break; // Garante o limite

          final file = File(pickedFile.path);
          final fileSize = await file.length();
          
          if (fileSize > 2 * 1024 * 1024) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('A imagem ${pickedFile.name} é muito grande. Ignorada.'), backgroundColor: AppTheme.statusRed),
             );
             continue;
          }
          
          _imageFiles.add(file);
          added++;
        }
        
        if (added > 0) {
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagens: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? _pickupTimeStart ?? TimeOfDay.now() : _pickupTimeEnd ?? TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _pickupTimeStart = pickedTime;
        } else {
          _pickupTimeEnd = pickedTime;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '00:00:00';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00'; // Formato para o banco de dados TIME
  }

  String _formatTimeDisplay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }

    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma imagem para o produto'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }

    if (_pickupLocally && (_pickupTimeStart == null || _pickupTimeEnd == null || _pickupDays == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os horários e dias para retirada no local'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
      final stock = int.tryParse(_stockController.text) ?? 1;

      await _productRepo.createProduct(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        pricingType: _pricingType,
        price: price,
        stockQuantity: stock,
        pickupLocally: _pickupLocally,
        pickupTimeStart: _pickupLocally ? _formatTimeOfDay(_pickupTimeStart) : null,
        pickupTimeEnd: _pickupLocally ? _formatTimeOfDay(_pickupTimeEnd) : null,
        pickupDays: _pickupLocally ? _pickupDays : null,
        imageFiles: _imageFiles,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado com sucesso!'), backgroundColor: AppTheme.statusGreen),
        );
        Navigator.pop(context); // Retorna para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: $e'), backgroundColor: AppTheme.statusRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text('Cadastrar Produto', style: TextStyle(color: AppTheme.primaryBlack)),
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryBlack),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagens
                    const Text('Imagens do Produto (Máx 5)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageFiles.length < 5 ? _imageFiles.length + 1 : 5,
                        itemBuilder: (context, index) {
                          if (index == _imageFiles.length && _imageFiles.length < 5) {
                            return GestureDetector(
                              onTap: _isLoading ? null : _pickImage,
                              child: Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.borderGrey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.borderGrey, style: BorderStyle.solid),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: AppTheme.textGrey),
                                    SizedBox(height: 8),
                                    Text('Adicionar', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_imageFiles[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Categoria
                    const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    CustomInput(
                      label: 'Título do Anúncio',
                      controller: _titleController,
                      colorScheme: CustomInputColorScheme.light,
                      isOutline: true,
                      validator: (val) => val == null || val.isEmpty ? 'Informe um título' : null,
                    ),
                    const SizedBox(height: 20),

                    // Descrição
                    const Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (val) => val == null || val.isEmpty ? 'Informe uma descrição' : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Preço e Tipo de Cobrança
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: 'Valor (R\$)',
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            colorScheme: CustomInputColorScheme.light,
                            isOutline: true,
                            validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cobrança', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _pricingType,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'DAILY', child: Text('Por Dia')),
                                  DropdownMenuItem(value: 'HOURLY', child: Text('Por Hora')),
                                ],
                                onChanged: (val) => setState(() => _pricingType = val!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Estoque
                    CustomInput(
                      label: 'Quantidade em Estoque',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      colorScheme: CustomInputColorScheme.light,
                      isOutline: true,
                      validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: 24),

                    // Retirada no Local
                    SwitchListTile(
                      title: const Text('Disponível para retirar no local', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _pickupLocally,
                      activeColor: AppTheme.primaryOrange,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _pickupLocally = val),
                    ),
                    
                    if (_pickupLocally) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Horário de Retirada:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _selectTime(context, true),
                                    child: Text(_formatTimeDisplay(_pickupTimeStart)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('até'),
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _selectTime(context, false),
                                    child: Text(_formatTimeDisplay(_pickupTimeEnd)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Dias Disponíveis:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _pickupDays,
                              hint: const Text('Selecione os dias'),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'ALL_DAYS', child: Text('Todos os dias')),
                                DropdownMenuItem(value: 'WEEKDAYS', child: Text('Dias úteis (Seg-Sex)')),
                                DropdownMenuItem(value: 'WEEKENDS', child: Text('Finais de semana')),
                              ],
                              onChanged: (val) => setState(() => _pickupDays = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    // Botão Salvar
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
                        : CustomButton(
                            label: 'Salvar Produto',
                            onPressed: _saveProduct,
                          ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
