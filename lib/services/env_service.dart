import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}