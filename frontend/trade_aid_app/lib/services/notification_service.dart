import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final _supabase = Supabase.instance.client;

  static Future<void> createNotification({
    String? userId,
    String? communityId,
    required String title,
    required String message,
    required String type,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'message': message,
      'type': type,
    };

    if (userId != null) payload['user_id'] = userId;
    if (communityId != null) payload['community_id'] = communityId;

    try {
      await _supabase.from('notifications').insert(payload);
    } catch (e) {
      print("Notification error: $e");
    }
  }
}
