import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/custom_button.dart';

// ---------------------------------------------------------------------------
// Modelo de dados simulado
// ---------------------------------------------------------------------------
class _TenantRenting {
  final String title;
  final String dateInfo;
  final String supplierInfo;
  final String status; // 'AGUARDANDO CONFIRMAÇÃO' ou 'CONFIRMADO'
  final double price;
  final String? imageUrl;

  const _TenantRenting({
    required this.title,
    required this.dateInfo,
    required this.supplierInfo,
    required this.status,
    required this.price,
    this.imageUrl,
  });
}

const List<_TenantRenting> _mockRentings = [
  _TenantRenting(
    title: '60 Cadeiras de plástico branca',
    dateInfo: 'jul. Dia 12 ao 13 até 19:00 horas',
    supplierInfo: 'Alugadas de FestaPronta',
    status: 'AGUARDANDO CONFIRMAÇÃO',
    price: 90.00,
  ),
  _TenantRenting(
    title: '15 Mesas de plástico branca',
    dateInfo: 'jul. Dia 12 ao 13 até 19:00 horas',
    supplierInfo: 'Alugadas de FestaPronta',
    status: 'CONFIRMADO',
    price: 90.00,
  ),
  _TenantRenting(
    title: '1 Pula Pula 2,30m infantil',
    dateInfo: 'jul. Dia 12 das 13:00 ás 19:00 horas',
    supplierInfo: 'Alugadas de PulaPula Para você',
    status: 'CONFIRMADO',
    price: 85.00,
  ),
];

// ---------------------------------------------------------------------------
// Tela
// ---------------------------------------------------------------------------
class TenantRentingsScreen extends StatelessWidget {
  const TenantRentingsScreen({super.key});

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
                return _TenantRentingCard(renting: renting);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de Locação (Locatário)
// ---------------------------------------------------------------------------
class _TenantRentingCard extends StatelessWidget {
  final _TenantRenting renting;

  const _TenantRentingCard({required this.renting});

  @override
  Widget build(BuildContext context) {
    final bool isConfirmed = renting.status == 'CONFIRMADO';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do Produto
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              width: double.infinity,
              height: 140,
              color: AppTheme.borderGrey.withOpacity(0.3),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: AppTheme.textGrey,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  renting.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const SizedBox(height: 4),

                // Data e Fornecedor
                Text(
                  renting.dateInfo,
                  style:
                      const TextStyle(fontSize: 14, color: AppTheme.textGrey),
                ),
                Text(
                  renting.supplierInfo,
                  style:
                      const TextStyle(fontSize: 14, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 12),

                // Status tag
                Text(
                  renting.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color:
                        isConfirmed ? AppTheme.statusGreen : AppTheme.statusRed,
                  ),
                ),
                const SizedBox(height: 8),

                // Preço e Botão "Reportar Atraso"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppTheme.primaryBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(text: 'Por  '),
                          TextSpan(
                            text:
                                'R\$ ${renting.price.toStringAsFixed(2).replaceAll('.', ',')}',
                          ),
                        ],
                      ),
                    ),
                    if (isConfirmed)
                      CustomButton(
                        label: 'Reportar Atraso',
                        height: 36,
                        width: 140,
                        borderRadius: 6,
                        onPressed: () {},
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
