import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔹 INDUSTRIAL THEME COLORS
const LinearGradient appGradient = LinearGradient(
  colors: [Color(0xFF0F777C), Color(0xFF119E90)],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const Color dark = Color(0xFF0B2F2A);
const Color darkPrimary = Color(0xFF004D40);
const Color backgroundLight = Color(0xFFF4FAF9);
const Color surface = Colors.white;
const Color subtleGrey = Color(0xFFF1F1F1);
const Color accent = Color(0xFF119E90);

class CommunityDetails extends StatefulWidget {
  final String communityId;

  const CommunityDetails({super.key, required this.communityId});

  @override
  State<CommunityDetails> createState() => _CommunityDetailsState();
}

class _CommunityDetailsState extends State<CommunityDetails> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  Map<String, dynamic>? communityData;
  List<dynamic> memberStats = []; // 🔹 Added class-level list for table

  @override
  void initState() {
    super.initState();
    fetchCommunityData();
  }

  /// 🔹 FETCH LOGIC
  Future<void> fetchCommunityData() async {
    setState(() => isLoading = true);
    try {
      // 1. Fetch main community info
      final communityRes = await supabase
          .from('community_management')
          .select('*')
          .eq('id', widget.communityId)
          .single();

      // 2. Fetch members/beneficiaries for the table
      // Note: Replace 'community_member_details' with your actual table name
      final membersRes = await supabase
          .from('community_member_details') 
          .select('*')
          .eq('community_id', widget.communityId);

      if (!mounted) return;

      setState(() {
        communityData = communityRes;
        memberStats = membersRes as List<dynamic>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar("Error: ${e.toString()}", isError: true);
    }
  }

  /// 🔹 DELETE COMMUNITY LOGIC
  Future<void> _deleteCommunity() async {
    final confirm = await _showConfirmDialog("Delete Community", "This action is permanent.");
    if (confirm != true) return;

    try {
      await supabase.from('community_management').delete().eq('id', widget.communityId);
      if (!mounted) return;
      Navigator.pop(context); // Go back after delete
      _showSnackBar("Community deleted successfully");
    } catch (e) {
      _showSnackBar("Failed to delete", isError: true);
    }
  }

  /// 🔹 BAN MEMBER LOGIC (Example: Banning the first member in the list)
  Future<void> _banMember(String memberId) async {
    try {
      await supabase
          .from('community_member_details')
          .update({'status': 'Banned'})
          .eq('id', memberId);
      
      fetchCommunityData(); // Refresh data
      _showSnackBar("Member has been banned");
    } catch (e) {
      _showSnackBar("Action failed", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Confirm", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: backgroundLight, body: Center(child: CircularProgressIndicator()));
    }

    if (communityData == null) {
      return const Scaffold(body: Center(child: Text("Data not found")));
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          // HEADER
          Container(
            height: 70,
            decoration: const BoxDecoration(gradient: appGradient),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trade&Aid — Admin Panel", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Row(
                  children: const [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 20),
                    Icon(Icons.notifications_none_outlined, color: Colors.white),
                    SizedBox(width: 16),
                    CircleAvatar(radius: 22, backgroundColor: Colors.white12, child: Icon(Icons.person, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          // SCROLLABLE BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(60, 40, 60, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _card(Row(
                    children: [
                      CircleAvatar(radius: 50, backgroundColor: accent, child: const Icon(Icons.group, size: 50, color: Colors.white)),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(communityData!['name'] ?? "Unnamed Community", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkPrimary)),
                          const SizedBox(height: 6),
                          Text("ID: ${widget.communityId}", style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ],
                  )),

                  const SizedBox(height: 30),
                  sectionTitle("Community Statistics"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard("Total Members", communityData!['members']?.toString() ?? "0"),
                      _StatCard("Items", communityData!['items']?.toString() ?? "0"),
                      _StatCard("Beneficiaries", communityData!['beneficiaries']?.toString() ?? "0"),
                    ],
                  ),

                  const SizedBox(height: 30),
                  sectionTitle("Beneficiary Information"),
                  const SizedBox(height: 16),
                  _beneficiaryTable(),

                  const SizedBox(height: 30),
                  // ACTIONS
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _deleteCommunity,
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete Community"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (memberStats.isNotEmpty) _banMember(memberStats[0]['id'].toString());
                        },
                        icon: const Icon(Icons.block),
                        label: const Text("Ban Recent Member"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _beneficiaryTable() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Table(
        border: TableBorder.symmetric(inside: const BorderSide(color: subtleGrey)),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: subtleGrey),
            children: [
              _Cell("Name", header: true),
              _Cell("Email", header: true),
              _Cell("Role", header: true),
              _Cell("Bought", header: true),
              _Cell("Sold", header: true),
               _Cell("Resource_booked", header: true),
                _Cell("Resource_given", header: true),
              _Cell("Status", header: true),
            ],
          ),
          if (memberStats.isEmpty)
            const TableRow(children: [_Cell("No data"), _Cell("-"), _Cell("-"), _Cell("-"), _Cell("-"), _Cell("-")])
          else
            ...memberStats.map((m) => TableRow(
                  children: [
                    _Cell(m['full_name']?.toString() ?? "N/A"),
                    _Cell(m['email']?.toString() ?? "N/A"),
                    _Cell(m['role']?.toString() ?? "Member"),
                    _Cell(m['items_bought']?.toString() ?? "0"),
                    _Cell(m['items_sold']?.toString() ?? "0"),
                     _Cell(m['resources_booked']?.toString() ?? "0"),
                      _Cell(m['resources_given']?.toString() ?? "0"),
                    _Cell(m['status']?.toString() ?? "Active"),
                  ],
                )),
        ],
      ),
    );
  }

  static Widget sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: dark));

  static Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: child,
      );
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard(this.title, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))]),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
}

class _Cell extends StatelessWidget {
  final String text;
  final bool header;
  const _Cell(this.text, {this.header = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text, style: TextStyle(fontWeight: header ? FontWeight.bold : FontWeight.normal, color: header ? dark : Colors.black87)),
      );
}