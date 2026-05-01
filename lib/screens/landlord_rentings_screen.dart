import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/custom_button.dart';

// ---------------------------------------------------------------------------
// Modelo de dados simulado
// ---------------------------------------------------------------------------
class _LandlordRenting {
  final String title;
  final String dateInfo;
  final String tenantName;
  final String address;

  const _LandlordRenting({
    required this.title,
    required this.dateInfo,
    required this.tenantName,
    required this.address,
  });
}

const List<_LandlordRenting> _mockRentings = [
  _LandlordRenting(
    title: '60 Cadeiras de plástico branca',
    dateInfo: 'Solicitação de aluguel para jul. Dia 12 ao 13 até 19:00 horas',
    tenantName: 'Gabriel Freire',
    address: 'Endereço: Rua RD13, número 184, Residêncial Drummond',
  ),
  _LandlordRenting(
    title: '15 Mesas de plástico branca',
    dateInfo: 'Solicitação de aluguel para jul. Dia 12 ao 13 até 19:00 horas',
    tenantName: 'Gabriel Freire',
    address: 'Endereço: Rua RD13, número 184, Residêncial Drummond',
  ),
  _LandlordRenting(
    title: '1 Pula Pula 2,30m infantil',
    dateInfo: 'Solicitação de aluguel para jul. Dia 12 das 13:00 ás 19:00',
    tenantName: 'Gabriel Freire',
    address: 'Endereço: Rua RD13, número 184, Residêncial Drummond',
  ),
];

// ---------------------------------------------------------------------------
// Tela
// ---------------------------------------------------------------------------
class LandlordRentingsScreen extends StatelessWidget {
  const LandlordRentingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryBlack),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Text(
              'Minhas locações',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              itemCount: _mockRentings.length,
              itemBuilder: (context, index) {
                final renting = _mockRentings[index];
                return _LandlordRentingCard(renting: renting);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de Locação (Locador)
// ---------------------------------------------------------------------------
class _LandlordRentingCard extends StatelessWidget {
  final _LandlordRenting renting;

  const _LandlordRentingCard({required this.renting});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha 1: Imagem do produto + Título e Data
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.borderGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppTheme.textGrey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      renting.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      renting.dateInfo,
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nome do "Locador" (conforme mockup)
          Text(
            'Locador: ${renting.tenantName}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),

          // Linha 2: Imagem do usuário + Endereço
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppTheme.borderGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.person, color: AppTheme.textGrey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  renting.address,
                  style:
                      const TextStyle(fontSize: 13, color: AppTheme.textGrey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botão Aceitar Locação
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              label: 'Aceitar Locação',
              height: 36,
              width: 150,
              borderRadius: 6,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
