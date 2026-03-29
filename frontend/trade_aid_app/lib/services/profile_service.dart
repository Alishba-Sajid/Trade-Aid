import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    final response = await supabase
        .from('profiles')
        .select('full_name, profile_image_url')
        .eq('user_id', user.id)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    return await supabase
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
    String? imageUrl,
  }) async {
    final user = supabase.auth.currentUser;

    await supabase
        .from('profiles')
        .update({
          'full_name': name,
          'phone': phone,
          'address': address,
          if (imageUrl != null) 'profile_image_url': imageUrl,
        })
        .eq('user_id', user!.id);
  }

  Future<String?> uploadProfileImage(File file) async {
    final user = supabase.auth.currentUser;

    final fileName = '${user!.id}.jpg';

    await supabase.storage
        .from('profile-images')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final publicUrl = supabase.storage
        .from('profile-images')
        .getPublicUrl(fileName);

    return publicUrl;
  }

  Future<void> deleteAccount() async {
    final user = supabase.auth.currentUser;

    // delete profile
    await supabase.from('profiles').delete().eq('user_id', user!.id);

    // logout user
    await supabase.auth.signOut();
  }
  Future<String?> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  try {
    final user = supabase.auth.currentUser;

    // 🔴 Re-authenticate user (IMPORTANT)
    final email = user?.email;

    await supabase.auth.signInWithPassword(
      email: email!,
      password: currentPassword,
    );

    // ✅ Update password
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    return null; // success
  } catch (e) {
    return e.toString(); // return error
  }
}
// ---------------- BUYER HISTORY ----------------
  Future<List<Map<String, dynamic>>> getBoughtProducts() async {
    final userId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('products')
        .select()
        .eq('reserved_for', userId)
        .eq('status', 'sold');

    return List<Map<String, dynamic>>.from(res);
  }

  // ---------------- SELLER HISTORY ----------------
  Future<List<Map<String, dynamic>>> getSoldProducts() async {
    final userId = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('products')
        .select()
        .eq('user_id', userId)
        .eq('status', 'sold');

    return List<Map<String, dynamic>>.from(res);
  }
  // ---------------- AVAILED RESOURCES ----------------
Future<List<Map<String, dynamic>>> getAvailedResources() async {
  final userId = supabase.auth.currentUser!.id;

  final res = await supabase
      .from('resource_bookings')
      .select('*, resources(*)')
      .eq('user_id', userId)
      .eq('status', 'confirmed');

  return List<Map<String, dynamic>>.from(res);
}
  // ---------------- PROVIDED RESOURCES ----------------
Future<List<Map<String, dynamic>>> getProvidedResources() async {
  final userId = supabase.auth.currentUser!.id;

  final res = await supabase
      .from('resource_bookings')
      .select('*, resources(*)')
      .eq('owner_id', userId)
      .eq('status', 'confirmed');

  return List<Map<String, dynamic>>.from(res);
}
}
