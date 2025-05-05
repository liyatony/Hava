import 'package:flutter/material.dart';
import 'dart:async';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEADDFF),
              Color(0xFFF3EDF7),
            ],
          ),
        ),
        child: Column(
          children: [
            // App bar with back button - with animation
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutQuart,
              )),
              child: FadeTransition(
                opacity: ModalRoute.of(context)!.animation!,
                child: Container(
                  padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFD0BCFF),
                        Color(0xFFEADDFF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1B1F)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1B1F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // App logo in the center with animation
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: ModalRoute.of(context)!.animation!,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFEADDFF),
                              Color(0xFFF3EDF7),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            'assets/images/HAVA APP ICON.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: ModalRoute.of(context)!.animation!,
                        curve: Curves.easeOutBack,
                      )),
                      child: FadeTransition(
                        opacity: ModalRoute.of(context)!.animation!,
                        child: const Text(
                          'Hava Weather',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1B1F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: ModalRoute.of(context)!.animation!,
                        curve: Curves.easeOutBack,
                        reverseCurve: Curves.easeInBack,
                      )),
                      child: FadeTransition(
                        opacity: ModalRoute.of(context)!.animation!,
                        child: Text(
                          'Version 1.0.1',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: ModalRoute.of(context)!.animation!,
                        curve: Interval(0.4, 1.0, curve: Curves.easeOutBack),
                      )),
                      child: FadeTransition(
                        opacity: ModalRoute.of(context)!.animation!,
                        child: Text(
                          'released 2 April 2025',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom options with animation
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Interval(0.5, 1.0, curve: Curves.easeOutQuart),
              )),
              child: FadeTransition(
                opacity: ModalRoute.of(context)!.animation!,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF3EDF7),
                        Color(0xFFEADDFF),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildOptionButton(
                              'About App',
                              Icons.info_outline,
                              () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const AboutAppScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.1),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 400),
                                ),
                              ),
                            ),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFE8E0E5)),
                            _buildOptionButton(
                              'Developer Details',
                              Icons.people_outline,
                              () => Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const DeveloperDetailsScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.1),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '© 2024-2025 Hava Weather Team',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6750A4), size: 24),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1B1F),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF6750A4), size: 24),
          ],
        ),
      ),
    );
  }
}

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEADDFF),
              Color(0xFFF3EDF7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Modernized app bar with properly spaced title
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutQuart,
              )),
              child: FadeTransition(
                opacity: ModalRoute.of(context)!.animation!,
                child: Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFD0BCFF),
                        Color(0xFFEADDFF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Modern back button with animation
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: ModalRoute.of(context)!.animation!,
                            curve: Curves.elasticOut,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF6750A4)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'About App',
                              style: TextStyle(
                                color: Color(0xFF1C1B1F),
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Main content area with scroll animations
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAnimatedSection(
                      context: context,
                      delay: 0,
                      title: 'Our Story',
                      content: 'Hava Weather was born out of a passion for providing accurate, localized weather forecasts to help communities make better decisions. Our journey began in 2024 when our team recognized the need for hyper-local weather predictions in the Choondacherry region.',
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedSection(
                      context: context,
                      delay: 100,
                      title: 'What We Do',
                      content: 'Hava Weather combines IoT sensors with advanced AI algorithms to deliver precise 7-day weather forecasts. Our system integrates real-time environmental monitoring with historical data analysis to provide the most accurate predictions for your specific location.',
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedSection(
                      context: context,
                      delay: 200,
                      title: 'What Drives Us',
                      content: 'We believe that accurate weather information should be accessible to everyone. Our team is driven by the potential to positively impact agriculture, environmental management, and daily life through reliable weather forecasting.',
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedSection(
                      context: context,
                      delay: 300,
                      title: 'Our Mission',
                      content: 'To empower individuals and communities with precise, localized weather forecasts that enable better decision-making and improve quality of life. We strive to push the boundaries of weather prediction technology while maintaining simplicity and accessibility.',
                    ),
                    const SizedBox(height: 24),
                    _buildAnimatedSection(
                      context: context,
                      delay: 400,
                      title: 'Thank You',
                      content: 'We sincerely appreciate your trust in Hava Weather. Our team is committed to continuously improving our service to meet your weather information needs. Your feedback and support inspire us to do better every day.',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required BuildContext context,
    required int delay,
    required String title,
    required String content,
  }) {
    final animation = ModalRoute.of(context)!.animation!;
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        delay / 1000,
        1.0,
        curve: Curves.easeOutQuart,
      ),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1B1F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeveloperDetailsScreen extends StatefulWidget {
  const DeveloperDetailsScreen({super.key});

  @override
  State<DeveloperDetailsScreen> createState() => _DeveloperDetailsScreenState();
}

class _DeveloperDetailsScreenState extends State<DeveloperDetailsScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late Timer _autoScrollTimer;
  int _currentPage = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  // Team members data
  final List<Map<String, dynamic>> teamMembers = [
    {
      'name': 'Abin Varghese',
      'role': 'Team Lead & Flutter Developer',
      'imagePath': 'assets/images/developers/abin.jpg',
      'color': const Color(0xFFFEE3BC),
    },
    {
      'name': 'Abel Abraham Philip',
      'role': 'UI Specialist',
      'imagePath': 'assets/images/developers/abel.jpg',
      'color': const Color(0xFFD3F5F5),
    },
    {
      'name': 'Liya Tony',
      'role': 'Frontend Developer',
      'imagePath': 'assets/images/developers/liya.jpg',
      'color': const Color(0xFFFFE6E6),
    },
    {
      'name': 'Maria Joe',
      'role': 'Data Analyst and QA Analyst',
      'imagePath': 'assets/images/developers/maria.jpg',
      'color': const Color(0xFFE6F3E6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85,
    );
    
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < teamMembers.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
    
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoScrollTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEADDFF),
              Color(0xFFF3EDF7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Modernized app bar with properly spaced title
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutQuart,
              )),
              child: FadeTransition(
                opacity: ModalRoute.of(context)!.animation!,
                child: Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFD0BCFF),
                        Color(0xFFEADDFF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Modern back button with animation
                        ScaleTransition(
                          scale: CurvedAnimation(
                            parent: ModalRoute.of(context)!.animation!,
                            curve: Curves.elasticOut,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Color(0xFF6750A4)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Developer Details',
                              style: TextStyle(
                                color: Color(0xFF1C1B1F),
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Main content area with scroll animations
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Floating "Meet Our Team" title with animation
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: ModalRoute.of(context)!.animation!,
                          curve: Curves.easeOutBack,
                        )),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          margin: const EdgeInsets.only(bottom: 30, top: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF9F7BEF),
                                Color(0xFF7A5AF8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9F7BEF).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Meet Our Team',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Our expert team is made up of creatives with technical know-how, '
                                'strategists who think outside the box, and developers who push innovation.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Auto-scrolling team members with animation
                      Container(
                        height: 320,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: teamMembers.length,
                          itemBuilder: (context, index) {
                            final member = teamMembers[index];
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  value = _pageController.page! - index;
                                  value = (1 - (value.abs() * 0.3)).clamp(0.85, 1.0);
                                }
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: _buildTeamMemberFlashcard(
                                name: member['name'] as String,
                                role: member['role'] as String,
                                imagePath: member['imagePath'] as String,
                                backgroundColor: member['color'] as Color,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Page indicator dots with animation
                      ScaleTransition(
                        scale: CurvedAnimation(
                          parent: ModalRoute.of(context)!.animation!,
                          curve: Curves.easeOutBack,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              teamMembers.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 12 : 8,
                                height: _currentPage == index ? 12 : 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == index
                                    ? const Color(0xFF6750A4)
                                    : const Color(0xFFD0BCFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Updated Contact section without website
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: ModalRoute.of(context)!.animation!,
                          curve: Interval(0.5, 1.0, curve: Curves.easeOutBack),
                        )),
                        child: FadeTransition(
                          opacity: ModalRoute.of(context)!.animation!,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFEADDFF),
                                  Color(0xFFD0BCFF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'CONTACT US',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1C1B1F),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildContactItem(Icons.email, 'Email', 'contact.hava1.com'),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    '© 2024-2025 Hava Weather Team',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTeamMemberFlashcard({
    required String name, 
    required String role, 
    required String imagePath,
    required Color backgroundColor,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profile image with animation
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
              ),
            ),
            child: Container(
              width: 160,
              height: 160,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Name and role with animation
          FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1B1F),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    role,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon with animation
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticOut,
              ),
            ),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE8DEF8),
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6750A4).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6750A4),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text with animation
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.5, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutQuart,
            )),
            child: FadeTransition(
              opacity: _controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1B1F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}