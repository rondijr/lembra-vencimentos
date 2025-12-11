import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkFirstAccess();
  }

  Future<void> _checkFirstAccess() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasAcceptedTerms = prefs.getBool('terms_accepted') ?? false;
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final hasUserId = prefs.getString('user_id');

    if (!mounted) return;

    // Se tem user_id, já completou tudo, vai direto para home
    if (hasUserId != null && hasUserId.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
    // Se não aceitou termos, começa do início
    else if (!hasAcceptedTerms) {
      Navigator.of(context).pushReplacementNamed('/terms');
    }
    // Se aceitou termos mas não viu onboarding, vai para onboarding
    else if (!hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
    // Se viu onboarding mas não criou usuário, vai para criar usuário
    else {
      Navigator.of(context).pushReplacementNamed('/create_user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.slate,
      body: _SplashContent(),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepaintBoundary(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lembra Vencimentos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
