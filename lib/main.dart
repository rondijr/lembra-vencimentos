import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/utils/app_colors.dart';
import 'core/config/supabase_config.dart';
import 'features/deadlines/presentation/pages/home_screen.dart';
import 'features/deadlines/presentation/pages/profile_page.dart';
import 'features/deadlines/presentation/pages/settings_page.dart';
import 'features/deadlines/presentation/pages/clear_data_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/terms_page.dart';
import 'features/onboarding/presentation/pages/create_user_page.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa locale pt_BR para formatação de datas
  await initializeDateFormatting('pt_BR', null);
  
  // Inicializa Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  await NotificationService().init(); // inicializa notificações locais
  
  // Verifica se usuário já foi criado
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');
  final hasAcceptedTerms = prefs.getBool('terms_accepted') ?? false;
  
  String initialRoute = '/create_user';
  if (userId != null) {
    initialRoute = hasAcceptedTerms ? '/home' : '/terms';
  }
  
  runApp(LembraVencimentosApp(initialRoute: initialRoute));
}

class LembraVencimentosApp extends StatelessWidget {
  final String initialRoute;
  
  const LembraVencimentosApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembra Vencimentos',
      theme: ThemeData(
        primaryColor: AppColors.blue,
        scaffoldBackgroundColor: AppColors.slate,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: AppColors.amber),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/create_user': (context) => const CreateUserPage(),
        '/terms': (context) => const TermsPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/notifications': (context) => const SettingsPage(),
        '/sync': (context) => const ProfilePage(),
        '/clear_data': (context) => const ClearDataPage(),
      },
    );
  }
}
