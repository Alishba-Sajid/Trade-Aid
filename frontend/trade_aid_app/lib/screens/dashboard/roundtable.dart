import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/app_bar.dart';
import '/widgets/time_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/services/notification_service.dart';

const LinearGradient appGradient = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 119, 124),
    Color.fromARGB(255, 17, 158, 144),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);
const Color dark = Color(0xFF00382E);
const Color light = Color(0xFFF8FAF9);
const Color accent = Color(0xFF119E90);
const Color surface = Colors.white;
const Color borderStroke = Color(0xFFE0E7E6);

class CommunityRoundtableScreen extends StatefulWidget {
  final bool isAdmin;
  final String communityId;
  final String adminName;
  const CommunityRoundtableScreen({
    super.key,
    required this.isAdmin,
    required this.communityId,
    required this.adminName,
  });

  @override
  State<CommunityRoundtableScreen> createState() =>
      _CommunityRoundtableScreenState();
}

class _CommunityRoundtableScreenState extends State<CommunityRoundtableScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  DateTime? selectedDate;
  Meeting? currentMeeting;

  @override
  void initState() {
    super.initState();
    fetchMeeting();

    supabase
        .channel('meetings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'community_meetings',
          callback: (payload) {
            fetchMeeting();
          },
        )
        .subscribe();
  }

  Future<void> _launchGoogleMeet() async {
    final Uri url = Uri.parse('https://meet.google.com/new');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) _showSnackBar("Could not open Google Meet");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: dark,
      ),
    );
  }

  Future<void> fetchMeeting() async {
    try {
      final now = DateTime.now();

      final data = await supabase
          .from('community_meetings')
          .select()
          .eq('community_id', widget.communityId)
          .order('scheduled_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        final meetingTime = DateTime.parse(data['scheduled_at']);
        final expiryTime = meetingTime.add(const Duration(minutes: 45));

        if (now.isAfter(expiryTime)) {
          await supabase
              .from('community_meetings')
              .delete()
              .eq('id', data['id']);

          setState(() {
            currentMeeting = null;
          });
          return;
        }

        setState(() {
          currentMeeting = Meeting(
            id: data['id'], // ✅ ADD THIS
            title: data['title'],
            link: data['meeting_link'],
            date: meetingTime,
          );
        });
      } else {
        setState(() {
          currentMeeting = null;
        });
      }
    } catch (e) {
      debugPrint("Fetch meeting error: $e");
    }
  }

  Future<void> _deleteMeeting() async {
    if (currentMeeting == null) return;

    try {
      await supabase
          .from('community_meetings')
          .delete()
          .eq('id', currentMeeting!.id); // ✅ FIX HERE

      setState(() {
        currentMeeting = null;
      });

      _showSnackBar("Meeting deleted");
    } catch (e) {
      _showSnackBar("Error deleting meeting");
    }
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime threeDaysFromNow = now.add(const Duration(days: 3));

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        threeDaysFromNow.year,
        threeDaysFromNow.month,
        threeDaysFromNow.day,
      ),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: accent,
            onPrimary: Colors.white,
            onSurface: dark,
          ),
        ),
        child: child!,
      ),
    );

    if (date == null) return;

    final time = await showTealTimePicker(
      context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      primary: accent,
    );

    if (time == null) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _publishMeeting() async {
    if (_titleController.text.isEmpty ||
        _linkController.text.isEmpty ||
        selectedDate == null) {
      _showSnackBar("Please complete all session details");
      return;
    }

    try {
      await supabase.from('community_meetings').insert({
        'community_id': widget.communityId,
        'title': _titleController.text,
        'meeting_link': _linkController.text,
        'scheduled_at': selectedDate!.toIso8601String(),
        'created_by': supabase.auth.currentUser!.id,
      });

      await NotificationService.createNotification(
        communityId: widget.communityId,
        title: "📢 New Community Meeting",
        message:
            "${widget.adminName} scheduled a meeting on ${DateFormat('EEE, MMM dd • hh:mm a').format(selectedDate!)}",
        type: "meeting",
      );

      _titleController.clear();
      _linkController.clear();
      setState(() {
        selectedDate = null;
      });

      fetchMeeting();
      _showSnackBar("Roundtable is now live for members");
    } catch (e) {
      _showSnackBar("Error publishing meeting");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: light,
      appBar: AppBarWidget(
        title: 'Community Roundtable',
        onBack: () => Navigator.maybePop(context),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            key: ValueKey(widget.isAdmin),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isAdmin) _buildAdminLayout() else _buildMemberLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminLayout() {
    return Column(
      children: [
        _buildInstantMeetCard(),
        const SizedBox(height: 32),
        _buildSectionHeader("Schedule Session", ""),
        const SizedBox(height: 16),
        _buildScheduleForm(),
        if (currentMeeting != null) ...[
          const SizedBox(height: 32),
          _buildSectionHeader("Active Session", "Publicly visible"),
          const SizedBox(height: 16),
          _buildMeetingCard(currentMeeting!, isAdmin: true),
        ],
      ],
    );
  }

  Widget _buildMemberLayout() {
    if (currentMeeting == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: dark.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_off_outlined,
                size: 64,
                color: dark.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No active roundtables",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Check back soon or wait for a notification\nfrom the community admin.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black45,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Upcoming Session", "Join the community live talk"),
        const SizedBox(height: 16),
        _buildMeetingCard(currentMeeting!),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: dark,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
          ),
      ],
    );
  }

  Widget _buildInstantMeetCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _launchGoogleMeet,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Instant Meeting",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Generate a Meet link instantly",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleForm() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.97),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderStroke),
      ),
      child: Column(
        children: [
          _buildField(
            "SESSION TITLE",
            _titleController,
            Icons.short_text_rounded,
            "e.g. Product Strategy Sync",
          ),
          const SizedBox(height: 16),
          _buildField(
            "MEETING LINK",
            _linkController,
            Icons.link_rounded,
            "https://meet.google.com/...",
          ),
          const SizedBox(height: 16),
          _buildDateTimePickerField(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton(
                onPressed: _publishMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Publish Roundtable",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: dark.withOpacity(0.5),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: dark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: accent, size: 20),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 14),
            filled: true,
            fillColor: light,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SCHEDULE (WITHIN 3 DAYS)",
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: dark.withOpacity(0.5),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: light,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: accent,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedDate == null
                      ? "Select Date & Time"
                      : DateFormat(
                          'EEE, MMM dd • hh:mm a',
                        ).format(selectedDate!),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: selectedDate == null ? Colors.black26 : dark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.expand_more_rounded, color: Colors.black26),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingCard(Meeting meeting, {bool isAdmin = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: dark.withOpacity(0.04),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meeting.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: dark,
                  ),
                ),
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _deleteMeeting,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                color: accent.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, MMM dd • hh:mm a').format(meeting.date),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isAdmin)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: light.withOpacity(0.98),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                meeting.link,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: accent,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse(meeting.link);
                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    _showSnackBar("Error opening link");
                  }
                },
                icon: const Icon(
                  Icons.video_call_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  "Join Now",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Meeting {
  final String id;
  final String title;
  final String link;
  final DateTime date;

  Meeting({
    required this.id,
    required this.title,
    required this.link,
    required this.date,
  });
}
