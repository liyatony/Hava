import 'package:flutter/material.dart';
import 'package:hava/pages/splash/splash_screen.dart';
import 'package:hava/services/env_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment variables
  await EnvService.initialize();
  
  // Initialize Supabase with values from .env
  await Supabase.initialize(
    url: EnvService.supabaseUrl,
    anonKey: EnvService.supabaseAnonKey,
  );
  
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HAVA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}