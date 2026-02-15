import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/app_bar.dart';
import '/models/admin_nomination.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  List<Candidate> candidates = [];
  bool isLoading = true;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      candidates = [
        Candidate(
          name: 'Hania B.',
          location: 'Gulberg Greens',
          sellerRating: 4.7,
          buyerRating: 4.5,
        ),
        Candidate(
          name: 'Ahmed R.',
          location: 'Bahria Town',
          sellerRating: 4.2,
          buyerRating: 4.4,
        ),
        Candidate(
          name: 'Fatima K.',
          location: 'DHA Phase 2',
          sellerRating: 4.9,
          buyerRating: 4.8,
        ),
      ];
      isLoading = false;
    });
  }

  Future<void> _vote(int index) async {
    setState(() => selectedIndex = index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: dark,
        content: Text('Vote cast for ${candidates[index].name}'),
      ),
    );
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

  Widget _buildBody() {
    if (isLoading) return _LoadingSkeleton();
    if (candidates.isEmpty) return _EmptyState();

    return ListView(
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
        })
      ],
    );
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
                        Text(candidate.name,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: dark)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(candidate.location,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.black45)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _RatingMini("Seller", candidate.sellerRating),
                            const SizedBox(width: 10),
                            _RatingMini("Buyer", candidate.buyerRating),
                          ],
                        )
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
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: darkPrimary)),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded,
              size: 12, color: Color(0xFFFFA000)),
          const SizedBox(width: 2),
          Text(rating.toString(),
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: dark)),
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
      child: const Icon(Icons.person_outline,
          color: Colors.white, size: 30),
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
        child: Text("No candidates available",
            style: GoogleFonts.poppins()));
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
