import 'package:trade_aid_app/models/member_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class MemberProfileService {
  final _supabase = Supabase.instance.client;

Future<MemberProfile> fetchMemberProfile(String userId) async {
  final data = await _supabase
      .from('profiles')
      .select()
      .eq('user_id', userId)
      .single();

  return MemberProfile(
    name: data['full_name'] ?? 'Unknown',
    avatarUrl: data['profile_image_url'] ?? '',
    address: data['address'] ?? 'No address',
    phone: data['phone'] ?? 'No phone',
    joinedDate: data['created_at'] != null
        ? data['created_at'].toString().split('T')[0]
        : 'N/A',

    email: "example@email.com",

    // ✅ REAL VALUES FROM DB
  buyerRating: double.parse(
  ((data['buyer_rating_avg'] ?? 0) as num)
      .toDouble()
      .toStringAsFixed(2),
),

sellerRating: double.parse(
  ((data['seller_rating_avg'] ?? 0) as num)
      .toDouble()
      .toStringAsFixed(2),
),
  );
}
}