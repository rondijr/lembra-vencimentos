import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Credenciais carregadas do arquivo .env
  // Para configurar:
  // 1. Copie .env.example para .env
  // 2. Adicione suas credenciais do Supabase
  // 3. O arquivo .env está no .gitignore (não será commitado)
  
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
