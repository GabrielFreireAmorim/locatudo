import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  bool _pickupLocally = true;
  bool _allDays = false;
  bool _weekdays = true;
  bool _weekends = false;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Locação',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const CustomInput(
                label: 'Titulo',
                colorScheme: CustomInputColorScheme.light,
                isOutline: true,
              ),
              const SizedBox(height: 20),

              // Valor por dia
              _buildPriceInput(),
              const SizedBox(height: 20),

              // Descrição
              const Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Furadeira...',
                  hintStyle: const TextStyle(color: AppTheme.textGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppTheme.borderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppTheme.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppTheme.primaryOrange),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Retirar no local
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _pickupLocally,
                      activeColor: AppTheme.primaryBlack,
                      onChanged: (val) {
                        setState(() {
                          _pickupLocally = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Retirar no local',
                      style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),

              // Disponibilidade
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Disponibilidade:',
                        style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('De '),
                        _buildTimePicker('9:41 AM'),
                        const Text(' até '),
                        _buildTimePicker('9:41 AM'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAvailabilityCheckbox('Todos os dias', _allDays,
                        (val) => setState(() => _allDays = val)),
                    _buildAvailabilityCheckbox('Dias úteis', _weekdays,
                        (val) => setState(() => _weekdays = val)),
                    _buildAvailabilityCheckbox('Fins de semana', _weekends,
                        (val) => setState(() => _weekends = val)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Imagem Upload Preview
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlack.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.photo_outlined,
                      color: AppTheme.primaryWhite, size: 40),
                ),
              ),
              const SizedBox(height: 40),

              // Botão Carregar Imagem
              CustomButton(
                label: 'Carregar Imagem',
                onPressed: () {},
                backgroundColor: AppTheme.primaryBlack,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInput() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderGrey)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Valor por dia',
                  style: TextStyle(color: AppTheme.primaryBlack, fontSize: 14)),
              Icon(Icons.arrow_right, color: AppTheme.primaryBlack),
            ],
          ),
          SizedBox(height: 4),
          Text('0,00',
              style: TextStyle(color: AppTheme.primaryBlack, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.borderGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        time,
        style: const TextStyle(
            color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAvailabilityCheckbox(
      String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: value,
              activeColor: AppTheme.primaryBlack,
              onChanged: (val) => onChanged(val ?? false),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
