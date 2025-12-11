import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dots_indicator/dots_indicator.dart';

/// Página de onboarding com 2 telas em PageView
/// Implementa excelência em UX e Acessibilidade (A11Y)
/// - DotsIndicator profissional com animações
/// - Controles contextuais coerentes (Pular/Voltar/Avançar)
/// - Semantics para leitores de tela
/// - Animações suaves e feedback haptic
/// - Material 3 design system
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/create_user');
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate
      body: SafeArea(
        child: Semantics(
          label: 'Tela de apresentação do aplicativo',
          child: Column(
            children: [
              // PageView com as duas páginas
              Expanded(
                child: RepaintBoundary(
                  child: PageView(
                    controller: _pageController,
                    physics: const PageScrollPhysics(), // Física otimizada
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      HapticFeedback.selectionClick();
                      _announcePageChange(index);
                    },
                    children: [
                      _buildPage1(context),
                      _buildPage2(context),
                    ],
                  ),
                ),
              ),
              
              // Indicador de páginas e botões
              Padding(
                padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // DotsIndicator profissional
                      Semantics(
                        label: 'Página ${_currentPage + 1} de 2',
                        child: RepaintBoundary(
                          child: DotsIndicator(
                            dotsCount: 2,
                            position: _currentPage,
                            decorator: const DotsDecorator(
                              size: Size.square(12.0),
                              activeSize: Size(32.0, 12.0),
                              activeShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              ),
                              color: Colors.white30,
                              activeColor: Color(0xFF2563EB),
                              spacing: EdgeInsets.symmetric(horizontal: 4.0),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Botões de navegação contextuais
                    _buildNavigationButtons(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }  Widget _buildNavigationButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão Voltar (página 2) ou Pular (página 1)
        if (_currentPage == 0)
          Semantics(
            button: true,
            label: 'Pular apresentação',
            child: TextButton.icon(
              onPressed: _completeOnboarding,
              icon: const Icon(Icons.skip_next, size: 20),
              label: const Text('Pular'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                minimumSize: const Size(88, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          )
        else
          Semantics(
            button: true,
            label: 'Voltar para página anterior',
            child: TextButton.icon(
              onPressed: _previousPage,
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Voltar'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                minimumSize: const Size(88, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        
        // Botão Próximo (página 1) ou Começar (página 2)
        Semantics(
          button: true,
          label: _currentPage == 0 
              ? 'Avançar para próxima página' 
              : 'Começar a usar o aplicativo',
          child: ElevatedButton.icon(
            onPressed: _currentPage == 0 ? _nextPage : _completeOnboarding,
            icon: Icon(
              _currentPage == 0 ? Icons.arrow_forward : Icons.check_circle,
              size: 20,
            ),
            label: Text(_currentPage == 0 ? 'Próximo' : 'Começar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B), // Amber
              foregroundColor: const Color(0xFF0F172A), // Slate
              minimumSize: const Size(140, 48),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  void _announcePageChange(int page) {
    // Limpar qualquer feedback visual anterior
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
  }

  Widget _buildPage1(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: 'Página 1 de 2: Nunca mais perca seus prazos importantes',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem
            RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/01.png',
                  height: 300,
                  fit: BoxFit.contain,
                  semanticLabel: 'Ilustração de prazos e documentos',
                  cacheHeight: 600, // Cache otimizado
                  filterQuality: FilterQuality.medium, // Qualidade balanceada
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            // Título
            Text(
              'Nunca mais perca\nseus prazos!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Descrição
            Text(
              'Gerencie RG, CNH, carteirinhas e\noutros documentos importantes',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: 'Página 2 de 2: Receba avisos no momento certo',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem
            RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/02.png',
                  height: 300,
                  fit: BoxFit.contain,
                  semanticLabel: 'Ilustração de notificações e lembretes',
                  cacheHeight: 600, // Cache otimizado
                  filterQuality: FilterQuality.medium, // Qualidade balanceada
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            // Título
            Text(
              'Avisos no momento\ncerto!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Descrição
            Column(
              children: [
                Text(
                  'Receba notificações 1 dia antes\ndo vencimento.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B), // Slate 800
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.privacy_tip_outlined,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Seus dados ficam seguros\nno seu dispositivo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
