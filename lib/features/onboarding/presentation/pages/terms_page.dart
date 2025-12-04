import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Icon(
                Icons.description_outlined,
                size: 64,
                color: AppColors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Termos de Uso',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSlate,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Antes de começar, leia nossos termos:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSlate,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SingleChildScrollView(
                    child: Text(
                      '''1. Uso do Aplicativo
Este aplicativo é destinado ao gerenciamento pessoal de prazos e vencimentos de documentos. O uso é gratuito e os dados são armazenados apenas localmente no seu dispositivo.

2. Privacidade de Dados
• Todos os seus dados ficam armazenados apenas no seu dispositivo
• Não coletamos, enviamos ou compartilhamos suas informações
• Você é o único responsável por fazer backup dos seus dados

3. Notificações
• O app enviará lembretes locais sobre vencimentos próximos
• Você pode desativar as notificações nas configurações do dispositivo
• As notificações são geradas localmente, sem uso de servidores externos

4. Responsabilidade
• O app serve como ferramenta auxiliar de organização
• Você é responsável por verificar os prazos reais dos documentos
• Não nos responsabilizamos por eventuais esquecimentos ou perdas de prazo

5. Atualização dos Termos
Estes termos podem ser atualizados. Mudanças significativas serão notificadas no app.

6. Código Aberto
Este é um projeto de código aberto. Você pode verificar o código fonte e contribuir no GitHub.''',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSlate,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                value: _acceptedTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
                title: const Text(
                  'Li e aceito os termos de uso',
                  style: TextStyle(
                    color: AppColors.onSlate,
                    fontSize: 14,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.blue,
                checkColor: AppColors.onSlate,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _acceptedTerms
                      ? () async {
                          // Marca termos como aceitos
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('terms_accepted', true);
                          
                          if (mounted) {
                            Navigator.of(context).pushReplacementNamed('/onboarding');
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    disabledBackgroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSlate,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
