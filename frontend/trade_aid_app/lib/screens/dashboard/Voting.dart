import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/app_bar.dart';
import '/models/candidate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VotingScreen extends StatefulWidget {
  final String communityId;

  const VotingScreen({super.key, required this.communityId});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final supabase = Supabase.instance.client;
  List<Candidate> candidates = [];
  bool isLoading = true;
  int? selectedIndex;
  bool isNominated = false;
  String phase = "loading";
  bool debugMode = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    try {
      setState(() {
        isLoading = true;
        candidates = [];
      });

      final userId = supabase.auth.currentUser!.id;

      // 1. Get active election for this community
      final election = await supabase
          .from('elections')
          .select('id, nomination_end, voting_end')
          .eq('community_id', widget.communityId)
          .eq('is_active', true)
          .maybeSingle();
      print("ELECTION: $election");

      if (election == null) {
        setState(() => isLoading = false);
        return;
      }

      final electionId = election['id'];

      DateTime now;

      if (debugMode) {
        now = DateTime.parse("2026-04-14T00:00:00Z");
      } else {
        now = DateTime.now().toUtc();
      }

      final nominationEnd = DateTime.parse(election['nomination_end']);
      final votingEnd = DateTime.parse(election['voting_end']);

      setState(() {
        if (now.isBefore(nominationEnd)) {
          phase = "nomination";
        } else if (now.isBefore(votingEnd)) {
          phase = "voting";
        } else {
          phase = "closed";
        }
      });

      print("CURRENT PHASE: $phase");

      // 2. Check if current user already nominated
      final existingNomination = await supabase
          .from('nominations')
          .select('id')
          .eq('election_id', electionId)
          .eq('user_id', userId)
          .maybeSingle();

      setState(() {
        isNominated = existingNomination != null;
      });

      // 3. Get all nominations for this election
      final nominations = await supabase
          .from('nominations')
          .select('user_id')
          .eq('election_id', electionId);

      print("NOMINATIONS: $nominations");

      if (nominations.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // 4. Fetch profiles for those users
      final userIds = (nominations as List)
          .map((e) => e['user_id'].toString())
          .toList();

      final profiles = await supabase
          .from('profiles')
          .select('*')
          .inFilter('user_id', userIds);

      print("PROFILES: $profiles");

      // 5. Convert to Candidate model
      setState(() {
        candidates = (profiles as List).map((profile) {
          return Candidate(
            userId: profile['user_id'],
            name: profile['full_name'] ?? 'Unknown',
            location: profile['address'] ?? 'Unknown',
            sellerRating: (profile['seller_rating_avg'] ?? 0).toDouble(),
            buyerRating: (profile['buyer_rating_avg'] ?? 0).toDouble(),
          );
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print("Error loading candidates: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _vote(int index) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final election = await supabase
          .from('elections')
          .select('id')
          .eq('community_id', widget.communityId)
          .eq('is_active', true)
          .maybeSingle();

      if (election == null) return;

      final electionId = election['id'];
      final candidate = candidates[index];

      // INSERT VOTE INTO DATABASE
      await supabase.from('votes').insert({
        'election_id': electionId,
        'voter_id': userId,
        'candidate_id': candidate.userId,
      });

      setState(() => selectedIndex = index);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote casted for ${candidate.name}')),
      );
    } catch (e) {
      print("VOTE ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vote failed: $e")));
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Select one trusted nominee to be the Admin of your community.\n"
        "Once you vote, your vote cannot be changed.",
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          height: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBarWidget(
        title: 'Cast Your Vote',
        onBack: () => Navigator.maybePop(context),
      ),
      body: _buildBody(),
    );
  }

  Future<void> _nominateMe() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      // 1. Get active election for this community
      final election = await supabase
          .from('elections')
          .select('id')
          .eq('community_id', widget.communityId)
          .eq('is_active', true)
          .maybeSingle();

      if (election == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No active election found")),
        );
        return;
      }

      final electionId = election['id'];

      // 2. Insert nomination
      await supabase.from('nominations').insert({
        'election_id': electionId,
        'user_id': userId,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("You are now nominated")));

      // 3. Reload candidates
      _loadCandidates();
    } catch (e) {
      print("Nomination error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildNominateButton() {
    if (phase != "nomination") {
      return const SizedBox(); // hide after nomination ends
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: ElevatedButton(
        onPressed: isNominated ? null : _nominateMe,
        style: ElevatedButton.styleFrom(
          backgroundColor: isNominated
              ? Colors.grey
              : const Color.fromARGB(255, 30, 171, 148),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          isNominated ? "Already Nominated" : "Nominate Me",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return _LoadingSkeleton();

    // NOMINATION PHASE → only nominate button
    if (phase == "nomination") {
      return Column(
        children: [
          _buildNominateButton(),
          const SizedBox(height: 20),
          const Center(child: Text("Nominations are open")),
        ],
      );
    }

    // VOTING PHASE → show candidates
    if (phase == "voting") {
      return Column(
        children: [
          _buildNominateButton(),
          Expanded(
            child: candidates.isEmpty
                ? _EmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(25, 14, 25, 14),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      ...List.generate(candidates.length, (index) {
                        return _CandidateCard(
                          candidate: candidates[index],
                          isSelected: selectedIndex == index,
                          isVoted: selectedIndex != null,
                          onVote: () => _vote(index),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      );
    }

    // CLOSED PHASE
    return const Center(child: Text("Election is closed"));
  }
}

/* =========================
   CANDIDATE CARD
========================= */

class _CandidateCard extends StatelessWidget {
  final Candidate candidate;
  final bool isSelected;
  final bool isVoted;
  final VoidCallback onVote;

  const _CandidateCard({
    required this.candidate,
    required this.isSelected,
    required this.isVoted,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.03 : 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected ? darkPrimary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? darkPrimary.withOpacity(0.15)
                  : dark.withOpacity(0.05),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  _Avatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              candidate.location,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _RatingMini("Seller", candidate.sellerRating),
                            const SizedBox(width: 10),
                            _RatingMini("Buyer", candidate.buyerRating),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _VoteButton(
              isSelected: isSelected,
              isVoted: isVoted,
              onTap: onVote,
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
   MINI RATING TAG
========================= */

class _RatingMini extends StatelessWidget {
  final String label;
  final double rating;

  const _RatingMini(this.label, this.rating);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: darkPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFA000)),
          const SizedBox(width: 2),
          Text(
            rating.toString(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: dark,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================
   COMMON WIDGETS
========================= */

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.person_outline, color: Colors.white, size: 30),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final bool isSelected;
  final bool isVoted;
  final VoidCallback onTap;

  const _VoteButton({
    required this.isSelected,
    required this.isVoted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isVoted ? null : onTap,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(26),
        bottomRight: Radius.circular(26),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isSelected ? appGradient : null,
          color: isSelected
              ? null
              : (isVoted ? Colors.grey[100] : backgroundLight),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
        ),
        child: Center(
          child: Text(
            isSelected
                ? 'VOTE CAST'
                : isVoted
                ? 'VOTING LOCKED'
                : 'CAST VOTE',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: isSelected
                  ? Colors.white
                  : isVoted
                  ? Colors.black26
                  : darkPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No candidates available", style: GoogleFonts.poppins()),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        height: 130,
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(26),
        ),
      ),
    );
  }
}
