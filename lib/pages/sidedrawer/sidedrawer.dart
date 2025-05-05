import 'package:flutter/material.dart';
import 'package:hava/pages/auth/login_screen.dart';
import 'package:hava/pages/auth/profile_screen.dart';
import 'package:hava/pages/sidedrawer/aboutscreen.dart';
import 'package:hava/pages/sidedrawer/contactdevelopers/contact_developers_bottom_sheet.dart';
import 'package:hava/pages/sidedrawer/displaymodescreen.dart';
import 'package:hava/pages/sidedrawer/historycomparison/weatherhistoryscreen.dart';
import 'package:hava/pages/sidedrawer/rate_app_bottom_sheet.dart';
import 'package:hava/pages/sidedrawer/weathernews.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _supabase.auth.onAuthStateChange.listen((event) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
        _loadUserProfile();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _userProfile = null;
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        _userProfile = response as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userProfile = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFD0BCFF).withOpacity(0.7),
        child: Column(
          children: [
            const SizedBox(height: 45),
            _buildProfileSection(context),
            const SizedBox(height: 30),
            Expanded(
              child: _buildMenuItems(context),
            ),
            _buildVersionText(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = _supabase.auth.currentUser;
    final userData = _userProfile ?? {};
    final avatarUrl = userData['avatar_url'] as String?;
    final username = userData['username'] as String? ?? 'Guest';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(context); // Close drawer first
          if (user != null) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            if (result == true) {
              await _loadUserProfile();
            }
          } else {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
            if (result == true) {
              await _loadUserProfile();
            }
          }
        },
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildDrawerItem(
          icon: Icons.cloud,
          label: "Weather News",
          onTap: () => _navigateTo(context, const WeatherNewsScreen()),
        ),
        _buildDrawerItem(
          icon: Icons.history,
          label: "Weather History",
          onTap: () => _navigateTo(context, const WeatherHistoryScreen()),
        ),
        _buildDrawerItem(
          icon: Icons.tv,
          label: "Display Mode",
          onTap: () => _navigateTo(context, const DisplayModeScreen()),
        ),
        _buildDrawerItem(
          icon: Icons.contact_mail,
          label: "Contact Developers",
          onTap: () {
            Navigator.pop(context);
            _showBottomSheet(context, const ContactDevelopersBottomSheet());
          },
        ),
        _buildDrawerItem(
          icon: Icons.star_outline,
          label: "Rate the App",
          onTap: () {
            Navigator.pop(context);
            _showBottomSheet(context, const RateAppBottomSheet());
          },
        ),
        _buildDrawerItem(
          icon: Icons.info_outline,
          label: "About",
          onTap: () => _navigateTo(context, const AboutScreen()),
        ),
        if (_supabase.auth.currentUser != null)
          _buildDrawerItem(
            icon: Icons.logout,
            label: "Sign Out",
            onTap: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pop(context);
                setState(() {
                  _userProfile = null;
                });
              }
            },
          ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black87,
          size: 24,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildVersionText() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "Version 1.0.1",
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _navigateTo(BuildContext context, Widget screen) async {
    Navigator.pop(context); // Close drawer first
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result == true) {
      await _loadUserProfile();
    }
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => bottomSheet,
    );
  }
}