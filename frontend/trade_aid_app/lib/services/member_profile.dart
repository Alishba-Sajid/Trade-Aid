
import 'package:trade_aid_app/models/member_profile.dart';
class MemberProfileService {
  Future<MemberProfile> fetchMemberProfile() async {
    // ⏳ Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // 🔹 Dummy backend response
    return MemberProfile(
      name: "Ahmed Khan",
      address: "House #23, Block A • Active Member",
      phone: "+92 300 1234567",
      email: "ahmed.khan@community.com",
      joinedDate: "12 Jan 2024",
      avatarUrl: "https://i.pravatar.cc/150?img=11",
      rating: 4.9, // ⭐ Backend-friendly rating
    );
  }
}
