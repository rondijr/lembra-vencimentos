import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/theme_provider.dart';
import 'features/deadlines/presentation/pages/home_screen.dart';
import 'features/deadlines/presentation/pages/profile_page.dart';
import 'features/deadlines/presentation/pages/settings_page.dart';
import 'features/deadlines/presentation/pages/notifications_page.dart';
import 'features/deadlines/presentation/pages/clear_data_page.dart';
import 'features/onboarding/presentation/pages/splash_page.dart';
import 'features/onboarding/presentation/pages/policies_page.dart';
import 'features/onboarding/presentation/pages/new_onboarding_page.dart';
import 'features/onboarding/presentation/pages/consent_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/pages/terms_page.dart';
import 'features/onboarding/presentation/pages/create_user_page.dart';
import 'features/categories/presentation/pages/category_list_page.dart';
import 'features/tags/presentation/pages/tag_list_page.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");
  
  // Inicializa locale pt_BR para formatação de datas
  await initializeDateFormatting('pt_BR', null);
  
  // Inicializa Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  await NotificationService().init(); // inicializa notificações locais
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const LembraVencimentosApp(),
    ),
  );
}

class LembraVencimentosApp extends StatelessWidget {
  const LembraVencimentosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Lembra Vencimentos',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/policies': (context) => const PoliciesPage(),
            '/new_onboarding': (context) => const NewOnboardingPage(),
            '/consent': (context) => const ConsentPage(),
            '/onboarding': (context) => const OnboardingPage(),
            '/create_user': (context) => const CreateUserPage(),
            '/terms': (context) => const TermsPage(),
            '/home': (context) => const HomeScreen(),
            '/profile': (context) => const ProfilePage(),
            '/settings': (context) => const SettingsPage(),
            '/notifications': (context) => const NotificationsPage(),
            '/clear_data': (context) => const ClearDataPage(),
            '/categories': (context) => const CategoryListPage(),
            '/tags': (context) => const TagListPage(),
          },
        );
      },
    );
  }
}
