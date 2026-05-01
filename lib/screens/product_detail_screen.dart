import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/custom_button.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: const BackButton(color: AppTheme.primaryBlack),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.primaryBlack),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e sub-informação
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'Furadeira',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+5 Alugados',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Imagem principal (Placeholder por enquanto)
              Center(
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.borderGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.handyman_outlined, // Ícone representando ferramenta
                      size: 100,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Preço
              const Text(
                '5,90 / Hora',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),

              // Descrição
              const Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderGrey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Furadeira de impacto 650W com velocidade variável e reversível. Acompanha kit de brocas básicas. Ideal para perfurações em alvenaria, madeira e metal.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Retirada
              const Text(
                'Retirada no local',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.borderGrey),
              const SizedBox(height: 16),

              // Perguntas e Respostas
              const Text(
                'Perguntas e respostas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Perguntar',
                onPressed: () {},
                backgroundColor: AppTheme.primaryBlack,
              ),
              const SizedBox(height: 24),

              // Lista de Q&A
              _buildQnA(
                question: 'Vem com broca para madeira ?',
                answer: '》Kit 16 Brocas 3 Pontas P/ Madeira\nBrocas 3 4 5 6 8 9 10 12mm',
              ),
              const SizedBox(height: 16),
              _buildQnA(
                question: 'É 220 ?',
                answer: '》Sim 220.',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQnA({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textGrey,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
