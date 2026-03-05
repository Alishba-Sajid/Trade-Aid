import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final _supabase = Supabase.instance.client;

  static Future<void> createNotification({
    required String communityId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'community_id': communityId,
        'title': title,
        'message': message,
        'type': type,
      });
    } catch (e) {
      print("Notification error: $e");
    }
  }
}