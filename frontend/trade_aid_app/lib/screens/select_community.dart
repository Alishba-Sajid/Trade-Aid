import 'package:flutter/material.dart';
import 'create_community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectCommunityScreen extends StatefulWidget {
  const SelectCommunityScreen({super.key});

  @override
  State<SelectCommunityScreen> createState() => _SelectCommunityScreenState();
}

class _SelectCommunityScreenState extends State<SelectCommunityScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> nearbyCommunities = [];
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      nearbyCommunities = List<Map<String, dynamic>>.from(
        args['nearbyCommunities'] ?? [],
      );
    }
  }

  // =========================
  // ✅ Step 1: Send Join Request
  // =========================
  Future<void> joinCommunity(Map<String, dynamic> community) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to join a community'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if already a member
      final memberCheck = await supabase
          .from('community_members')
          .select()
          .eq('community_id', community['id'])
          .eq('user_id', userId)
          .maybeSingle();

      if (memberCheck != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are already a member of this community'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Check if join request already exists
      final existingRequest = await supabase
          .from('community_join_requests')
          .select()
          .eq('community_id', community['id'])
          .eq('requester_id', userId)
          .maybeSingle();

      if (existingRequest != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already requested to join this community'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // ✅ Insert join request with proper response check
      final response = await supabase
          .from('community_join_requests')
          .insert({
            'community_id': community['id'],
            'requester_id': userId,
            'status': 'pending',
          })
          .select() // make sure it returns the inserted row
          .maybeSingle();

      // response will contain the inserted row or null if failed
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request sent to join "${community['name']}"'),
            backgroundColor: Colors.teal,
          ),
        );
      } else {
        // fallback in case Supabase did not throw but returned null
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send join request'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending join request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send join request'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool noCommunitiesNearby = nearbyCommunities.isEmpty;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 15, 119, 124),
              Color.fromARGB(255, 17, 158, 144),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              const Icon(
                Icons.location_city_rounded,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Your Community',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                noCommunitiesNearby
                    ? 'No communities found near your location.'
                    : 'Choose a community from the list below.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!noCommunitiesNearby)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: nearbyCommunities.map((community) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  community['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => joinCommunity(community),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Join',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              if (noCommunitiesNearby)
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateCommunityScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_location_alt_rounded,
                      color: Colors.teal,
                    ),
                    label: const Text(
                      'Create Community',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
