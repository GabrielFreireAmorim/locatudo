import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/consent_service.dart';

/// Tela de aceite dos Termos de Uso.
///
/// Regras de UX:
/// - O texto dos termos é exibido em um [SingleChildScrollView] controlado.
/// - O botão "Eu Li e Aceito" começa **desabilitado**.
/// - O botão só é habilitado quando o usuário rola o scroll até o final
///   (garantindo a tentativa de leitura).
/// - Após o aceite, o usuário é redirecionado para `/product_list`.
/// - Não há botão de "Voltar" — o usuário é obrigado a aceitar ou sair do app.
class TermsPage extends StatefulWidget {
  final bool isReadOnly;
  const TermsPage({super.key, this.isReadOnly = false});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  final ScrollController _scrollController = ScrollController();
  final ConsentService _consentService = ConsentService();

  late bool _hasReachedEnd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hasReachedEnd = widget.isReadOnly; // Se for readOnly, já libera o estado
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Lógica de Scroll
  // ----------------------------------------------------------------

  void _onScroll() {
    if (_hasReachedEnd) return; // Já chegou ao fim — não precisa checar mais.

    final position = _scrollController.position;
    // Considera "fim" quando faltam menos de 80px para o final do conteúdo.
    final isAtBottom =
        position.pixels >= position.maxScrollExtent - 80;

    if (isAtBottom) {
      setState(() => _hasReachedEnd = true);
    }
  }

  // ----------------------------------------------------------------
  // Aceite
  // ----------------------------------------------------------------

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    try {
      await _consentService.acceptTerms();
      if (mounted) {
        // Substitui a rota inteira para que o usuário não consiga
        // pressionar "Voltar" e retornar à tela de termos.
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/product_list',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar aceite: $e'),
            backgroundColor: AppTheme.statusRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Impede o gesto/botão de voltar APENAS se não for readOnly
      canPop: widget.isReadOnly,
      child: Scaffold(
        backgroundColor: AppTheme.primaryWhite,
        appBar: AppBar(
          title: const Text(
            'Termos de Uso',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: widget.isReadOnly, // Mostra seta se for readOnly
          backgroundColor: AppTheme.primaryWhite,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppTheme.borderGrey, height: 1),
          ),
        ),
        body: Column(
          children: [
            // ---- Cabeçalho informativo ----
            if (!widget.isReadOnly) _buildHeader(),

            // ---- Texto dos Termos (scrollável) ----
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20, 20, 20, widget.isReadOnly ? 40 : 100),
                    child: _buildTermsContent(),
                  ),
                  // Gradiente de fade no fundo para indicar mais conteúdo
                  if (!_hasReachedEnd && !widget.isReadOnly) _buildScrollFadeHint(),
                ],
              ),
            ),

            // ---- Rodapé com botão de aceite ----
            if (!widget.isReadOnly) _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // Widgets Auxiliares
  // ----------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppTheme.primaryOrange.withOpacity(0.08),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primaryOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Por favor, leia os termos até o final para habilitar o botão de aceite.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.primaryOrange.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollFadeHint() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryWhite.withOpacity(0),
                AppTheme.primaryWhite.withOpacity(0.95),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador de progresso de leitura
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _hasReachedEnd
                  ? AppTheme.statusGreen.withOpacity(0.1)
                  : AppTheme.borderGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hasReachedEnd
                      ? Icons.check_circle_outline
                      : Icons.arrow_downward,
                  size: 16,
                  color: _hasReachedEnd
                      ? AppTheme.statusGreen
                      : AppTheme.textGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  _hasReachedEnd
                      ? 'Leitura concluída!'
                      : 'Role até o final para continuar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _hasReachedEnd
                        ? AppTheme.statusGreen
                        : AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),

          // Botão principal
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _hasReachedEnd ? 1.0 : 0.45,
              child: ElevatedButton.icon(
                onPressed: (_hasReachedEnd && !_isLoading)
                    ? _handleAccept
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.borderGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.verified_outlined, size: 20),
                label: Text(
                  _isLoading ? 'Salvando...' : 'Eu Li e Aceito',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // Conteúdo dos Termos
  // ----------------------------------------------------------------

  Widget _buildTermsContent() {
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

        _termSection(
          '1. Aceitação dos Termos',
          'Ao acessar ou usar o aplicativo LocaTudo, você concorda em ficar '
              'vinculado a estes Termos de Uso. Caso não concorde com alguma '
              'das condições aqui estabelecidas, não utilize a plataforma.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '2. Descrição do Serviço',
          'O LocaTudo é uma plataforma de intermediação de aluguel de itens '
              'entre particulares. Atuamos como facilitadores da conexão entre '
              'locadores e locatários, sem sermos parte nos contratos firmados '
              'entre os usuários.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '3. Cadastro e Conta',
          'Para utilizar as funcionalidades da plataforma, você deve criar uma '
              'conta com informações verdadeiras, precisas e atualizadas. Você '
              'é responsável pela confidencialidade de sua senha e por todas as '
              'atividades realizadas em sua conta.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '4. Uso Aceitável',
          'Você concorda em utilizar o LocaTudo apenas para fins lícitos. É '
              'proibido publicar anúncios falsos, enganosos ou fraudulentos; '
              'utilizar a plataforma para qualquer atividade ilegal; assediar '
              'outros usuários; ou tentar comprometer a segurança do sistema.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '5. Transações entre Usuários',
          'O LocaTudo não garante a qualidade, segurança ou legalidade dos '
              'itens anunciados, nem a veracidade das informações fornecidas '
              'pelos usuários. Recomendamos que as partes formalizem um contrato '
              'de locação e verifiquem o estado do item antes da transação.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '6. Privacidade e Proteção de Dados',
          'O tratamento dos seus dados pessoais é regido por nossa Política de '
              'Privacidade, em conformidade com a Lei Geral de Proteção de Dados '
              '(LGPD — Lei nº 13.709/2018). Ao aceitar estes termos, você '
              'consente com a coleta e uso dos dados descritos na política.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '7. Propriedade Intelectual',
          'Todo o conteúdo disponível na plataforma — incluindo textos, '
              'logotipos, ícones e software — é de propriedade do LocaTudo ou '
              'de seus licenciadores e está protegido pelas leis de propriedade '
              'intelectual. É vedada a reprodução sem autorização prévia.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '8. Limitação de Responsabilidade',
          'O LocaTudo não será responsável por danos indiretos, incidentais ou '
              'consequentes decorrentes do uso da plataforma, incluindo perda de '
              'dados, lucros cessantes ou interrupção de negócios.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '9. Alterações nos Termos',
          'Reservamo-nos o direito de modificar estes Termos a qualquer momento. '
              'Alterações relevantes serão comunicadas por notificação no '
              'aplicativo ou por e-mail. O uso continuado da plataforma após as '
              'alterações constitui aceitação dos novos termos.',
          titleStyle,
          bodyStyle,
        ),
        _termSection(
          '10. Foro e Legislação Aplicável',
          'Estes Termos são regidos pela legislação brasileira. Qualquer disputa '
              'decorrente do uso da plataforma será submetida ao foro da comarca '
              'de Belo Horizonte — MG, com renúncia expressa a qualquer outro.',
          titleStyle,
          bodyStyle,
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'Ao clicar em "Eu Li e Aceito", você confirma que leu, '
              'compreendeu e concorda com todos os termos acima.',
          style: bodyStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: AppTheme.primaryBlack.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _termSection(
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
