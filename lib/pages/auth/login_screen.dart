import 'package:flutter/material.dart';
import 'package:hava/services/auth_service.dart';
import 'package:hava/pages/auth/register_screen.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _showPassword = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Animation visibility flags
  bool _showLogo = false;
  bool _showTitle = false;
  bool _showEmailField = false;
  bool _showPasswordField = false;
  bool _showLoginButton = false;
  bool _showCreateIdButton = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Start the animation
    _animationController.forward();
    
    // Schedule delayed animations
    _setupDelayedAnimations();
  }
  
  void _setupDelayedAnimations() {
    // Start showing elements with delays
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showLogo = true);
    });
    
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showTitle = true);
    });
    
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showEmailField = true);
    });
    
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showPasswordField = true);
    });
    
    Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showLoginButton = true);
    });
    
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showCreateIdButton = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        if (mounted) {
          Navigator.of(context).pop(true); // Return success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    
    // Adjust padding based on screen size
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
    
    return Scaffold(
      // Set the status bar to transparent for a better look
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove default back button
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                 Color(0xFFD1A8F5), // Light purple (matching the top of the image)
                  Color(0xFF792ACF), // Darker purple (matching the bottom of the image)
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 450, // Maximum width for tablets and larger screens
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16.0,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: screenSize.height * 0.02),
                              // Logo image with animated entrance
                              AnimatedOpacity(
                                opacity: _showLogo ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  transform: Matrix4.identity()..scale(_showLogo ? 1.0 : 0.8),
                                  height: 200,
                                  width: 200,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/icons/HAVA.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.04),
                              // Animated title entrance
                              AnimatedOpacity(
                                opacity: _showTitle ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  transform: Matrix4.translationValues(
                                    0, 
                                    _showTitle ? 0 : 20, 
                                    0
                                  ),
                                  child: Hero(
                                    tag: 'login_title',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: const Text(
                                        'Log in with Hava ID',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.04),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Email field with animation
                                    AnimatedOpacity(
                                      opacity: _showEmailField ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOut,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOut,
                                        transform: Matrix4.translationValues(
                                          0, 
                                          _showEmailField ? 0 : 10, 
                                          0
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: TextFormField(
                                            controller: _emailController,
                                            style: const TextStyle(color: Colors.white),
                                            keyboardType: TextInputType.emailAddress,
                                            decoration: const InputDecoration(
                                              hintText: 'Email',
                                              hintStyle: TextStyle(color: Colors.white70),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                  .hasMatch(value)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Password field with animation
                                    AnimatedOpacity(
                                      opacity: _showPasswordField ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOut,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOut,
                                        transform: Matrix4.translationValues(
                                          0, 
                                          _showPasswordField ? 0 : 10, 
                                          0
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: !_showPassword,
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              hintStyle: const TextStyle(color: Colors.white70),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _showPassword ? Icons.visibility_off : Icons.visibility,
                                                  color: Colors.white70,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _showPassword = !_showPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Login button with animation
                                    AnimatedOpacity(
                                      opacity: _showLoginButton ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOut,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOut,
                                        transform: Matrix4.translationValues(
                                          0, 
                                          _showLoginButton ? 0 : 10, 
                                          0
                                        ),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _signIn,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF792ACF),
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              elevation: 3,
                                            ),
                                            child: _isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF792ACF)),
                                                    ),
                                                  )
                                                : const Text(
                                                    'Log in',
                                                    style: TextStyle(
                                                      fontSize: 16, 
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Create ID button with animation
                                    AnimatedOpacity(
                                      opacity: _showCreateIdButton ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeOut,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeOut,
                                        transform: Matrix4.translationValues(
                                          0, 
                                          _showCreateIdButton ? 0 : 10, 
                                          0
                                        ),
                                        child: Hero(
                                          tag: 'create_account_button',
                                          child: Material(
                                            color: Colors.transparent,
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    pageBuilder: (context, animation, secondaryAnimation) => 
                                                      const RegisterScreen(),
                                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                      var curve = Curves.easeInOut;
                                                      var curveTween = CurveTween(curve: curve);
                                                      var fadeTween = Tween(begin: 0.0, end: 1.0);
                                                      var fadeAnimation = fadeTween.animate(animation.drive(curveTween));
                                                      var slideTween = Tween(begin: const Offset(0.0, 0.1), end: Offset.zero);
                                                      var slideAnimation = slideTween.animate(animation.drive(curveTween));
                                                      
                                                      return FadeTransition(
                                                        opacity: fadeAnimation,
                                                        child: SlideTransition(
                                                          position: slideAnimation,
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    transitionDuration: const Duration(milliseconds: 400),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                              child: const Text(
                                                'Create ID',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenSize.height * 0.04),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Floating back button with box - FIXED HERE
          Positioned(
            top: MediaQuery.of(context).padding.top + 20, // Position below status bar with extra 20px
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Fixed back button functionality - now it will go back without any conditions
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 26, // Larger icon size
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}