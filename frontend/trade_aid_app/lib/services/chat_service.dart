import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../models/profile_model.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  // ─────────────────────────────
  // Get current user's community
  // ─────────────────────────────
  Future<String?> getMyCommunityId() async {

  final userId = _supabase.auth.currentUser!.id;

  final data = await _supabase
      .from('community_members')
      .select('community_id')
      .eq('user_id', userId)
      .maybeSingle();

  if (data == null) {
    return null;
  }

  return data['community_id'];
}
  // ─────────────────────────────
  // COMMUNITY MEMBERS TAB
  // ─────────────────────────────
Future<List<ProfileModel>> getCommunityMembers() async {
  final communityId = await getMyCommunityId();
  final myUserId = _supabase.auth.currentUser!.id;

  if (communityId == null) return [];

  final data = await _supabase
      .from('community_members')
      .select('user_id, profiles(*)')
      .eq('community_id', communityId);

  final members = (data as List)
      .map((e) => ProfileModel.fromJson(e['profiles']))
      .where((p) => p.userId != myUserId)
      .toList();

  return members;
}
  // ──────────────────────────
  // RECENT CHAT TAB
  // ─────────────────────────────
Future<List<Map<String, dynamic>>> getRecentChats() async {
  final userId = _supabase.auth.currentUser!.id;

  final data = await _supabase
      .from('conversations')
      .select('''
      id,
      user1_id,
      user2_id,
      last_message_at,
      user1:profiles!conversations_user1_id_fkey(full_name,profile_image_url),
      user2:profiles!conversations_user2_id_fkey(full_name,profile_image_url)
      ''')
      .or('user1_id.eq.$userId,user2_id.eq.$userId')
      .order('last_message_at', ascending: true);
print(data);
  return List<Map<String, dynamic>>.from(data);
}

  // ─────────────────────────────
  // GET OR CREATE CONVERSATION
  // ─────────────────────────────
  Future<String> getOrCreateConversation(String otherUserId) async {
    final myId = _supabase.auth.currentUser!.id;

    final existing = await _supabase
        .from('conversations')
        .select()
        .or(
            'and(user1_id.eq.$myId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$myId)')
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    final communityId = await getMyCommunityId();

    final newConversation = await _supabase
        .from('conversations')
        .insert({
          'community_id': communityId,
          'user1_id': myId,
          'user2_id': otherUserId,
        })
        .select()
        .single();

    return newConversation['id'];
  }

  // ─────────────────────────────
  // STREAM MESSAGES
  // ─────────────────────────────
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', chatId)
        .order('created_at')
        .map((data) =>
            data.map((msg) => ChatMessage.fromJson(msg)).toList());
  }

  // ─────────────────────────────
  // SEND MESSAGE
  // ─────────────────────────────
  Future<void> sendMessage(String chatId, String text) async {
    final userId = _supabase.auth.currentUser!.id;

    await _supabase.from('messages').insert({
      'conversation_id': chatId,
      'sender_id': userId,
      'message_text': text,
    });

    await _supabase
        .from('conversations')
        .update({'last_message_at': DateTime.now().toIso8601String()})
        .eq('id', chatId);
  }
  Future<void> sendMedia(String chatId, String mediaUrl) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;

  await Supabase.instance.client.from('messages').insert({
    'conversation_id': chatId,
    'sender_id': userId,
    'media_url': mediaUrl,
  });
}
}