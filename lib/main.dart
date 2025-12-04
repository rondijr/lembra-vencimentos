import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'pages/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // inicializa notificações locais
  runApp(const LembraVencimentosApp());
}

class LembraVencimentosApp extends StatelessWidget {
  const LembraVencimentosApp({Key? key}) : super(key: key);

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
      home: const HomeScreen(),
    );
  }
}
