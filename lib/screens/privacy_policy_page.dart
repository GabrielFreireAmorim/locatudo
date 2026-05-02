import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Tela de Política de Privacidade.
/// Exibida no modo leitura através do menu Jurídico.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryWhite,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderGrey, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: _buildPrivacyContent(),
      ),
    );
  }

  Widget _buildPrivacyContent() {
    const titleStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: AppTheme.primaryBlack,
      height: 1.6,
    );
    const bodyStyle = TextStyle(
      fontSize: 14,
      color: AppTheme.textGrey,
      height: 1.75,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Versão e data
        Text(
          'Versão 1.0  •  Vigência a partir de 01/05/2026',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textGrey.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),

        _policySection(
          '1. Informações que Coletamos',
          'Coletamos informações que você nos fornece diretamente ao criar uma conta, '
              'como nome, e-mail, telefone, endereço e foto de perfil. Também coletamos '
              'dados sobre os itens que você anuncia e as transações de locação que realiza.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '2. Como Utilizamos seus Dados',
          'Utilizamos seus dados para operar, manter e fornecer as funcionalidades da '
              'plataforma; processar transações; enviar comunicações importantes; '
              'prevenir fraudes e garantir a segurança dos usuários.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '3. Compartilhamento de Informações',
          'Seus dados de contato (nome, telefone e endereço aproximado) serão compartilhados '
              'com o outro usuário envolvido em uma locação (locador ou locatário) apenas '
              'após a confirmação da transação, para viabilizar a entrega do item.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '4. Cookies e Tecnologias de Rastreamento',
          'Podemos utilizar cookies e tecnologias similares para entender como você utiliza '
              'nosso serviço, personalizar sua experiência e coletar estatísticas de uso '
              'da plataforma.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '5. Segurança dos Dados',
          'Empregamos medidas técnicas e organizacionais para proteger seus dados contra '
              'acesso não autorizado, perda ou alteração. No entanto, nenhum sistema é '
              'completamente seguro.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '6. Seus Direitos (LGPD)',
          'Em conformidade com a LGPD, você tem direito a confirmar a existência de tratamento; '
              'acessar seus dados; corrigir dados incompletos ou inexatos; e solicitar a '
              'exclusão de seus dados, observadas as obrigações legais de guarda de registros.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '7. Retenção de Dados',
          'Manteremos seus dados pessoais pelo tempo necessário para cumprir as finalidades '
              'descritas nesta política, a menos que um período de retenção mais longo seja '
              'exigido ou permitido por lei.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '8. Alterações nesta Política',
          'Podemos atualizar esta Política de Privacidade periodicamente. Notificaremos você '
              'sobre mudanças significativas através do aplicativo ou e-mail cadastrado.',
          titleStyle,
          bodyStyle,
        ),
        _policySection(
          '9. Contato',
          'Se você tiver dúvidas sobre esta política ou sobre como tratamos seus dados, '
              'entre em contato conosco através da seção "Obter Ajuda" no seu perfil.',
          titleStyle,
          bodyStyle,
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'O uso continuado do LocaTudo após alterações nesta política '
              'será considerado como aceitação das novas práticas.',
          style: bodyStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: AppTheme.primaryBlack.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _policySection(
    String title,
    String body,
    TextStyle titleStyle,
    TextStyle bodyStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 4),
          Text(body, style: bodyStyle),
        ],
      ),
    );
  }
}
