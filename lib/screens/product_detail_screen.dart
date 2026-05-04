import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/custom_button.dart';
import '../models/product_model.dart';
import '../repositories/product_repository.dart';
import '../services/supabase_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _productRepo = ProductRepository();
  final _questionController = TextEditingController();

  ProductModel? _product;
  List<String> _images = [];
  List<Map<String, dynamic>> _questions = [];
  
  bool _isLoadingImages = true;
  bool _isLoadingQuestions = true;
  bool _isSubmittingQuestion = false;
  int _currentImageIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_product == null) {
      _product = ModalRoute.of(context)!.settings.arguments as ProductModel;
      _images = [_product!.imageUrl]; // Imagem principal inicialmente
      _loadData();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadImages();
    _loadQuestions();
  }

  Future<void> _loadImages() async {
    try {
      final images = await _productRepo.getProductImages(_product!.id);
      if (mounted) {
        setState(() {
          if (images.isNotEmpty) {
            _images = images;
          }
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _productRepo.getProductQuestions(_product!.id);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoadingQuestions = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingQuestions = false);
    }
  }

  Future<void> _submitQuestion() async {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para perguntar'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }

    if (user.id == _product!.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não pode perguntar no próprio anúncio'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }

    setState(() => _isSubmittingQuestion = true);
    try {
      await _productRepo.addProductQuestion(_product!.id, text);
      _questionController.clear();
      Navigator.pop(context); // Fechar dialog
      _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pergunta enviada com sucesso!'), backgroundColor: AppTheme.statusGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: AppTheme.statusRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingQuestion = false);
    }
  }

  void _showAskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fazer uma Pergunta', style: TextStyle(color: AppTheme.primaryBlack)),
          content: TextField(
            controller: _questionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Escreva sua dúvida aqui...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              onPressed: _isSubmittingQuestion ? null : () async {
                await _submitQuestion();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
              child: _isSubmittingQuestion 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _vote(String questionId, String voteType) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para votar'), backgroundColor: AppTheme.statusRed),
      );
      return;
    }

    try {
      await _productRepo.voteQuestion(questionId, voteType);
      _loadQuestions(); // Recarrega para atualizar os contadores
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao votar: $e'), backgroundColor: AppTheme.statusRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) return const Scaffold();

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
                  Expanded(
                    child: Text(
                      _product!.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estoque: ${_product!.stockQuantity}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Imagens / Carrossel
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: _images.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              _images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppTheme.borderGrey.withOpacity(0.3),
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 50, color: AppTheme.textGrey),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_images.length > 1)
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1}/${_images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Preço
              Text(
                'R\$ ${_product!.price.toStringAsFixed(2)} / ${_product!.pricingType == 'HOURLY' ? 'Hora' : 'Dia'}',
                style: const TextStyle(
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
                child: Text(
                  _product!.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Retirada
              Text(
                _product!.pickupLocally ? 'Retirada no local' : 'Entrega a combinar',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryBlack,
                ),
              ),
              if (_product!.pickupLocally && _product!.pickupTimeStart != null && _product!.pickupTimeEnd != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Horário de Retirada: ${_product!.pickupTimeStart!.substring(0, 5)} às ${_product!.pickupTimeEnd!.substring(0, 5)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.borderGrey),
              const SizedBox(height: 16),

              // Perguntas e Respostas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perguntas e respostas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAskDialog,
                    icon: const Icon(Icons.add_comment, color: AppTheme.primaryOrange, size: 20),
                    label: const Text('Perguntar', style: TextStyle(color: AppTheme.primaryOrange)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lista de Q&A Dinâmica
              if (_isLoadingQuestions)
                const Center(child: CircularProgressIndicator())
              else if (_questions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Nenhuma pergunta ainda. Seja o primeiro!', style: TextStyle(color: AppTheme.textGrey)),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final q = _questions[index];
                    return _buildQnA(
                      id: q['id'] as String,
                      question: q['question_text'] as String,
                      answer: q['answer_text'] as String?,
                      upvotes: q['upvotes'] as int? ?? 0,
                      downvotes: q['downvotes'] as int? ?? 0,
                    );
                  },
                ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQnA({
    required String id,
    required String question, 
    String? answer, 
    required int upvotes, 
    required int downvotes
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          if (answer != null && answer.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppTheme.primaryOrange, width: 3)),
              ),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Votos
          Row(
            children: [
              GestureDetector(
                onTap: () => _vote(id, 'UP'),
                child: Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined, size: 16, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text('Útil ($upvotes)', style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _vote(id, 'DOWN'),
                child: Row(
                  children: [
                    const Icon(Icons.thumb_down_outlined, size: 16, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text('Não útil ($downvotes)', style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
