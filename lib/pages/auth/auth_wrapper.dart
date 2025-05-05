import 'package:flutter/material.dart';
import 'package:hava/pages/home/weather_screen.dart';
import 'package:hava/pages/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final AuthState authState = snapshot.data!;
          final session = authState.session;
          
          if (session != null) {
            // User is logged in
            return const MainScreen();
          } else {
            // User is not logged in
            return const LoginScreen();
          }
        }
        
        // Loading state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}