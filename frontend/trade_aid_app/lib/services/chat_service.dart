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
  final user = _supabase.auth.currentUser;
  if (user == null) return [];

  final communityId = await getMyCommunityId();
  if (communityId == null) return [];

  // 1️⃣ Get all members of this community
  final members = await _supabase
      .from('community_members')
      .select('user_id')
      .eq('community_id', communityId);
final userIds = (members as List)
    .map((e) => e['user_id'])
    .where((id) => id != null) // ✅ FIX
    .toSet()
    .toList();

  // 2️⃣ Remove current user
  userIds.remove(user.id);

  if (userIds.isEmpty) return [];

  // 3️⃣ Fetch profiles manually
  final profiles = await _supabase
      .from('profiles')
      .select()
      .inFilter('user_id', userIds);
      print("User IDs: $userIds");

  return (profiles as List)
      .map((e) => ProfileModel.fromJson(e))
      .toList();
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
        last_sender_id,
        unread_count,

        user1:profiles!conversations_user1_fkey(
          full_name,
          profile_image_url,
          address
        ),

        user2:profiles!conversations_user2_fkey(
          full_name,
          profile_image_url,
          address
        )
      ''')
     .or('user1_id.eq.$userId,user2_id.eq.$userId')
.not('last_message_at', 'is', null) // ✅ ONLY chats with messages
.order('last_message_at', ascending: false);

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
  // STREAM MESSAGES FOR RECENT MSGS
  // ─────────────────────────────
Stream<List<Map<String, dynamic>>> getRecentChatsStream() async* {
  final userId = _supabase.auth.currentUser!.id;

  // 🔹 preload profiles once
  final profiles = await _supabase
      .from('profiles')
      .select('user_id, full_name, profile_image_url, address');

  final profileMap = {
    for (var p in profiles) p['user_id']: p
  };

  yield* _supabase
      .from('conversations')
      .stream(primaryKey: ['id'])
      .order('last_message_at', ascending: false)
      .map((data) {

        final filtered = data.where((chat) =>
            (chat['user1_id'] == userId ||
             chat['user2_id'] == userId) &&
            chat['last_message_at'] != null).toList();

        return filtered.map((chat) {
          return {
            ...chat,
            'user1': profileMap[chat['user1_id']],
            'user2': profileMap[chat['user2_id']],
          };
        }).toList();
      });
}
  // ─────────────────────────────
  // STREAM MESSAGES
  // ─────────────────────────────
 Stream<List<ChatMessage>> getMessages(String chatId) {
  return _supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('conversation_id', chatId)
      .order('created_at', ascending: true)
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

  final convo = await _supabase
      .from('conversations')
      .select('user1_id, user2_id, unread_count')
      .eq('id', chatId)
      .single();

 

  await _supabase.from('conversations').update({
    'last_message_at': DateTime.now().toIso8601String(),
    'last_sender_id': userId,
    'unread_count': (convo['unread_count'] ?? 0) + 1,
  }).eq('id', chatId);
}
// ─────────────────────────────
// SEND MEDIA
// ─────────────────────────────
Future<void> sendMedia(String chatId, String mediaUrl) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;

  await Supabase.instance.client.from('messages').insert({
    'conversation_id': chatId,
    'sender_id': userId,
    'media_url': mediaUrl,
  });

  await Supabase.instance.client
      .from('conversations')
      .update({
        'last_message_at': DateTime.now().toIso8601String(),
        'last_sender_id': userId,
           })
      .eq('id', chatId);
}

// ─────────────────────────────
// MARK AS SEEN
// ─────────────────────────────
Future<void> markMessagesAsSeen(String chatId) async {
  final userId = _supabase.auth.currentUser!.id;

  // mark messages
  await _supabase
      .from('messages')
      .update({'status': 'seen'})
      .eq('conversation_id', chatId)
      .neq('sender_id', userId);

  // reset unread count
  await _supabase
      .from('conversations')
      .update({'unread_count': 0})
      .eq('id', chatId);
}

// ─────────────────────────────
// DELETE MESSAGE
// ─────────────────────────────
Future<void> deleteMessage(String messageId, String? mediaUrl) async {

  if (mediaUrl != null) {
    final path = mediaUrl.split('/').last;

    await _supabase.storage
        .from('chat-media')
        .remove([path]);
  }

  await _supabase
      .from('messages')
      .delete()
      .eq('id', messageId);
}
// ─────────────────────────────
// GLOBAL UNREAD INDICATOR STREAM
// ─────────────────────────────
Stream<bool> hasUnreadMessages() {
  final userId = _supabase.auth.currentUser!.id;

  return _supabase
      .from('conversations')
      .stream(primaryKey: ['id'])
      .map((data) {

        final hasUnread = data.any((chat) =>
            (chat['user1_id'] == userId ||
             chat['user2_id'] == userId) &&
            (chat['unread_count'] ?? 0) > 0 &&
            chat['last_sender_id'] != userId);

        return hasUnread;
      });
}
}