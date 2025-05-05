import 'package:flutter/material.dart';
import 'package:hava/pages/sidedrawer/contactdevelopers/feedback_form.dart';

class ContactDevelopersBottomSheet extends StatelessWidget {
  const ContactDevelopersBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEADDFF).withOpacity(0.98),
              const Color(0xFFD0BCFF).withOpacity(0.98),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.only(top: 24, bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Contact developers',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF381E72),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.close,
                        key: ValueKey('close'),
                        color: const Color(0xFF381E72),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._buildContactOptions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContactOptions(BuildContext context) {
    final options = [
      'Error in the forecast',
      'Problem with the app',
      'Suggest an improvement',
      'Other question'
    ];

    return List.generate(options.length, (index) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildAnimatedOption(context, options[index]),
          ),
          if (index < options.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                thickness: 1,
                color: const Color(0xFFE8DEF8).withOpacity(0.5),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildAnimatedOption(BuildContext context, String title) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FeedbackFormScreen(feedbackType: title),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF381E72),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF381E72).withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}