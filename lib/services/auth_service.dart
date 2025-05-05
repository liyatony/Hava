import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        throw Exception('User creation failed');
      }

      try {
        await _supabase
            .from('profiles')
            .insert({
              'id': response.user!.id,
              'username': username,
              'email': email,
            });
      } catch (e) {
        throw Exception('Profile creation failed: ${e.toString()}');
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? username,
    String? email,
  }) async {
    if (currentUser == null) {
      throw Exception('No authenticated user');
    }
    
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (email != null) updates['email'] = email;
      
      if (updates.isNotEmpty) {
        await _supabase
            .from('profiles')
            .update(updates)
            .eq('id', currentUser!.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadAvatar(File imageFile) async {
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }
      
      final fileSize = imageFile.lengthSync();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Image file is too large (max 5MB)');
      }

      final fileExt = path.extension(imageFile.path);
      final fileName = 'avatar${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = '${currentUser!.id}/$fileName';
      
      // Upload the file
      await _supabase.storage
          .from('avatars')
          .upload(filePath, imageFile, fileOptions: FileOptions(
            upsert: true,
            contentType: 'image/${fileExt.replaceAll('.', '')}',
          ));
      
      // Get public URL
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      
      // Update profile
      await _supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', currentUser!.id);
      
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }
}