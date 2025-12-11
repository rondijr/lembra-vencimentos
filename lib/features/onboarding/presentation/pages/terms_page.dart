import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';

/// Versão atual dos Termos e Política  
/// Atualize sempre que houver mudanças significativas
const String kTermsVersion = '1.0.0';
const String kPrivacyVersion = '1.0.0';

// Textos estáticos dos documentos (const para otimização)
const String _kTermsText = '''TERMOS DE USO
Versão 1.0.0 - Última atualização: Dezembro de 2025

1. ACEITAÇÃO DOS TERMOS
Ao utilizar o aplicativo "Lembra Vencimentos", você concorda com estes Termos de Uso.

2. DESCRIÇÃO DO SERVIÇO
O "Lembra Vencimentos" é um aplicativo gratuito para gerenciamento pessoal de prazos e vencimentos de documentos (RG, CNH, carteirinhas, etc.).

3. USO PERMITIDO
• O aplicativo é destinado exclusivamente para uso pessoal
• Você é responsável por manter a segurança do seu dispositivo
• Não utilize o app para fins ilegais ou não autorizados

4. ARMAZENAMENTO DE DADOS
• Dados armazenados localmente no seu dispositivo
• Você é responsável por fazer backup dos seus dados
• Sincronização com Supabase mediante sua autorização

5. NOTIFICAÇÕES
• O app enviará lembretes locais sobre vencimentos próximos
• Você pode desativar notificações nas configurações do dispositivo
• Não garantimos a entrega de todas as notificações

6. RESPONSABILIDADE
• O app é uma ferramenta auxiliar de organização
• Você é responsável por verificar os prazos reais dos documentos
• NÃO nos responsabilizamos por esquecimentos ou perdas de prazo

7. PROPRIEDADE INTELECTUAL
• O código fonte é aberto (licença a ser definida)
• Marcas e design são propriedade dos desenvolvedores

8. MODIFICAÇÕES
• Podemos modificar estes termos a qualquer momento
• Mudanças significativas serão notificadas no app

9. LEI APLICÁVEL
Estes termos são regidos pelas leis brasileiras, incluindo a LGPD.''';

const String _kPrivacyText = '''POLÍTICA DE PRIVACIDADE
Versão 1.0.0 - Última atualização: Dezembro de 2025

Esta Política de Privacidade descreve como o "Lembra Vencimentos" coleta, usa e protege seus dados pessoais, em conformidade com a LGPD (Lei nº 13.709/2018).

1. DADOS COLETADOS

1.1 Dados Armazenados Localmente:
• Nome do usuário
• Informações sobre documentos (tipo, data de vencimento)
• Fotos de documentos (opcional)
• Preferências do aplicativo

1.2 Dados Opcionalmente Sincronizados:
• Se você optar por usar sincronização em nuvem via Supabase
• Você pode desativar a sincronização a qualquer momento

1.3 Dados NÃO Coletados:
• NÃO coletamos dados de localização
• NÃO acessamos contatos
• NÃO rastreamos seu comportamento
• NÃO compartilhamos dados com terceiros
• NÃO usamos analytics ou publicidade

2. FINALIDADE DO TRATAMENTO
Os dados são utilizados exclusivamente para:
• Gerenciar seus prazos e vencimentos
• Enviar lembretes locais
• Sincronizar entre dispositivos (se autorizado)

3. BASE LEGAL (LGPD)
• Consentimento: para sincronização em nuvem
• Execução de contrato: para funcionalidades básicas

4. COMPARTILHAMENTO DE DADOS
• NÃO compartilhamos seus dados com terceiros
• NÃO vendemos informações
• Dados sincronizados ficam no Supabase (servidor seguro)

5. ARMAZENAMENTO E SEGURANÇA
• Dados criptografados no dispositivo
• Protegidos pela segurança do sistema operacional
• Transmissão via HTTPS

6. SEUS DIREITOS (LGPD)
Você tem direito a:
• Confirmação do tratamento de dados
• Acesso aos seus dados
• Correção de dados incompletos
• Anonimização, bloqueio ou eliminação
• Portabilidade dos dados
• Revogação do consentimento

7. RETENÇÃO DE DADOS
• Dados locais: até você desinstalar o app
• Dados em nuvem: até você solicitar exclusão

8. DADOS DE MENORES
• O app não é destinado a menores de 13 anos

9. COOKIES
• O app NÃO usa cookies
• SharedPreferences usado apenas para preferências locais

10. CONTATO
Dúvidas: GitHub do projeto
Autoridade Nacional: www.gov.br/anpd''';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _termsScrollController = ScrollController();
  final ScrollController _privacyScrollController = ScrollController();
  
  bool _hasScrolledTermsToEnd = false;
  bool _hasScrolledPrivacyToEnd = false;
  bool _markedTermsAsRead = false;
  bool _markedPrivacyAsRead = false;
  bool _acceptedBoth = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Detectar scroll até o final - Termos
    _termsScrollController.addListener(() {
      if (!_hasScrolledTermsToEnd) {
        final maxScroll = _termsScrollController.position.maxScrollExtent;
        final currentScroll = _termsScrollController.position.pixels;
        if (currentScroll >= maxScroll - 50) {
          setState(() => _hasScrolledTermsToEnd = true);
        }
      }
    });
    
    // Detectar scroll até o final - Privacidade
    _privacyScrollController.addListener(() {
      if (!_hasScrolledPrivacyToEnd) {
        final maxScroll = _privacyScrollController.position.maxScrollExtent;
        final currentScroll = _privacyScrollController.position.pixels;
        if (currentScroll >= maxScroll - 50) {
          setState(() => _hasScrolledPrivacyToEnd = true);
        }
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _termsScrollController.dispose();
    _privacyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _markedTermsAsRead && _markedPrivacyAsRead;
    
    return Scaffold(
      backgroundColor: AppColors.slate,
      appBar: AppBar(
        backgroundColor: AppColors.slate,
        elevation: 0,
        title: const Text('Termos e Privacidade', style: TextStyle(color: AppColors.onSlate)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.blue,
          labelColor: AppColors.blue,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Termos de Uso'),
            Tab(text: 'Política de Privacidade'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                child: TabBarView(
                  controller: _tabController,
                  physics: const PageScrollPhysics(), // Física otimizada
                  children: [
                    _buildTermsTab(),
                    _buildPrivacyTab(),
                  ],
                ),
              ),
            ),
            
            // Área de aceite final
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.slate,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Aceitar termos de uso e política de privacidade',
                    child: CheckboxListTile(
                      value: _acceptedBoth,
                      onChanged: canContinue ? (value) {
                        setState(() => _acceptedBoth = value ?? false);
                        if (value == true) HapticFeedback.mediumImpact();
                      } : null,
                      title: const Text(
                        'Li e aceito os Termos de Uso e a Política de Privacidade',
                        style: TextStyle(color: AppColors.onSlate, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.blue,
                      checkColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: canContinue && _acceptedBoth ? () async {
                        HapticFeedback.mediumImpact();
                        final navigator = Navigator.of(context);
                        final isMounted = mounted;
                        
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('terms_accepted', true);
                        await prefs.setString('terms_version', kTermsVersion);
                        await prefs.setString('privacy_version', kPrivacyVersion);
                        await prefs.setString('acceptance_date', DateTime.now().toIso8601String());
                        
                        if (isMounted) navigator.pushReplacementNamed('/home');
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        disabledBackgroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text(
                        canContinue && _acceptedBoth ? 'Continuar' : 'Leia e marque os documentos como lidos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: canContinue && _acceptedBoth ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTermsTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue.withValues(alpha: 0.3), width: 1),
              ),
              child: RepaintBoundary(
                child: Scrollbar(
                  controller: _termsScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _termsScrollController,
                    physics: const ClampingScrollPhysics(), // Física otimizada
                    child: const Text(
                      _kTermsText,
                      style: TextStyle(fontSize: 14, color: AppColors.onSlate, height: 1.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _hasScrolledTermsToEnd && !_markedTermsAsRead ? () {
                setState(() => _markedTermsAsRead = true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Termos de Uso marcados como lidos'), duration: Duration(seconds: 2), backgroundColor: AppColors.blue),
                );
              } : null,
              icon: Icon(_markedTermsAsRead ? Icons.check_circle : Icons.visibility, color: Colors.white),
              label: Text(
                _markedTermsAsRead ? 'Termos lidos ✓' : _hasScrolledTermsToEnd ? 'Marcar como lido' : 'Role até o final para marcar',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _markedTermsAsRead ? Colors.green : _hasScrolledTermsToEnd ? AppColors.blue : Colors.grey.shade700,
                disabledBackgroundColor: Colors.grey.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrivacyTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3), width: 1),
              ),
              child: RepaintBoundary(
                child: Scrollbar(
                  controller: _privacyScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _privacyScrollController,
                    physics: const ClampingScrollPhysics(), // Física otimizada
                    child: const Text(
                      _kPrivacyText,
                      style: TextStyle(fontSize: 14, color: AppColors.onSlate, height: 1.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _hasScrolledPrivacyToEnd && !_markedPrivacyAsRead ? () {
                setState(() => _markedPrivacyAsRead = true);
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Política de Privacidade marcada como lida'), duration: Duration(seconds: 2), backgroundColor: AppColors.amber),
                );
              } : null,
              icon: Icon(_markedPrivacyAsRead ? Icons.check_circle : Icons.visibility, color: Colors.white),
              label: Text(
                _markedPrivacyAsRead ? 'Política lida ✓' : _hasScrolledPrivacyToEnd ? 'Marcar como lido' : 'Role até o final para marcar',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _markedPrivacyAsRead ? Colors.green : _hasScrolledPrivacyToEnd ? AppColors.amber : Colors.grey.shade700,
                disabledBackgroundColor: Colors.grey.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
