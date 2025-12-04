import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

/// Página de onboarding para primeira execução do app.
/// 
/// Tema: Aluno com prazos dispersos precisa lembrar vencimentos.
/// Paleta: Blue #2563EB, Slate #0F172A, Amber #F59E0B.
/// Ícone: calendário com sino.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ícone: calendário com sino
              const Icon(
                Icons.event_available,
                size: 120,
                color: AppColors.blue,
              ),
              const SizedBox(height: 32),
              
              // Título principal
              const Text(
                'Lembra Vencimentos',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSlate,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtítulo com foco na persona (aluno)
              Text(
                'Nunca mais perca prazos importantes!',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.onSlate.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Descrição dos documentos
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBulletPoint('📅  RG, CNH, carteirinhas...'),
                    const SizedBox(height: 12),
                    _buildBulletPoint('🔔  Avisos locais 1 dia antes'),
                    const SizedBox(height: 12),
                    _buildBulletPoint('🔒  Seus dados ficam no seu celular'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Botão de começar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: AppColors.slate,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: const Text(
                  'Cadastrar 1º prazo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.onSlate,
      ),
    );
  }
}
