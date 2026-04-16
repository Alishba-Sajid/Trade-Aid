import 'dart:io';
import 'dart:ui'; // Added for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/notification_service.dart';

// ================== Backend Service ==================
class HelpSupportService {
  Future<bool> submitIssue({
    required String subject,
    required String description,
    required String category,
    File? attachment,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}

// ================== Help & Support Screen ==================
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _complaintaboutController =
      TextEditingController();
  String? _selectedCategory;
  File? _attachedImage;
  List<dynamic> _members = [];
  String? _selectedUserId;
  final List<String> _categories = ['Products', 'Resources', 'Others'];

  // Custom Animated Error SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: const Border(
              left: BorderSide(color: Colors.redAccent, width: 6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchMembers() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      Navigator.pop(context);
      return;
    }

    final member = await supabase
        .from('community_members')
        .select('community_id')
        .eq('user_id', user.id)
        .single();

    final communityId = member['community_id'];

    final data = await supabase
        .from('community_members')
        .select('user_id, profiles(full_name)')
        .eq('community_id', communityId);

    setState(() {
      _members = data;
    });
  }

  // ================== Submit Issue ==================
  void _submitIssue() async {
    String subject = _subjectController.text.trim();
    String description = _descriptionController.text.trim();

    if (subject.isEmpty ||
        description.isEmpty ||
        _selectedUserId == null ||
        _selectedCategory == null) {
      _showErrorSnackBar("Please fill in all fields");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: accentTeal)),
    );
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final member = await supabase
        .from('community_members')
        .select('community_id')
        .eq('user_id', user.id)
        .single();

    final communityId = member['community_id'];

    String? imageUrl;
    if (_attachedImage != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'complaints/$fileName';
      await supabase.storage.from('complaints').upload(path, _attachedImage!);
      imageUrl = supabase.storage.from('complaints').getPublicUrl(path);
    }

    await supabase.from('complaints').insert({
      'community_id': communityId,
      'complainant_id': user.id,
      'accused_user_id': _selectedUserId,
      'subject': subject,
      'description': description,
      'attachment_url': imageUrl,
    });

    final admins = await supabase
        .from('community_members')
        .select('user_id')
        .eq('community_id', communityId)
        .eq('role', 'admin');

    for (var admin in admins) {
      await NotificationService.createNotification(
        userId: admin['user_id'],
        title: "🚨 New Complaint",
        message: "A new complaint has been filed.",
        type: "complaint",
      );
    }

    Navigator.pop(context); // remove loading

    // Branded Success Dialog with Teal Border & Blur
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: accentTeal,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: accentTeal,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Report Submitted",
                  style: TextStyle(
                    color: darkPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your issue has been sent to the admin. They will respond soon.",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: appGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _subjectController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _attachedImage = null;
    });
  }

  // ================== Pick Image ==================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _attachedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      _attachedImage = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          AppBarWidget(
            title: 'Help & Support',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(child: _buildFormContent()),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Column(
            children: [
              Icon(Icons.support_agent, size: 40, color: accentTeal),
              SizedBox(height: 10),
              Text(
                "How can we help you today?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Submit your complaint or query below and our admin team will assist you shortly.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _buildSectionLabel("SUBJECT"),
        const SizedBox(height: 5),
        _buildTextField(
          controller: _subjectController,
          hintText: "Enter the topic of your concern",
          icon: Icons.title,
          maxLength: 50,
        ),
        const SizedBox(height: 15),
        _buildSectionLabel("DESCRIPTION"),
        const SizedBox(height: 5),
        _buildDescriptionField(
          controller: _descriptionController,
          hintText: "Describe your issue in detail...",
          icon: Icons.edit_note,
          maxLength: 250,
        ),
        const SizedBox(height: 0),
        _buildSectionLabel("COMPLAINT ABOUT"),
        const SizedBox(height: 5),
        _buildAutocompleteField(),
        const SizedBox(height: 15),
        _buildSectionLabel("CATEGORY"),
        const SizedBox(height: 5),
        _buildDropdown(),
        const SizedBox(height: 15),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.attach_file, color: accentTeal),
          label: Text(
            _attachedImage != null
                ? "Attachment Selected"
                : "Attach Screenshot (optional)",
            style: const TextStyle(
              color: accentTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: accentTeal.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_attachedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_attachedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _attachedImage = null;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 45),
        SizedBox(
          width: double.infinity,
          height: 75,
          child: ElevatedButton(
            onPressed: _submitIssue,
            style: ElevatedButton.styleFrom(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  "Submit Report",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutocompleteField() {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, dynamic>>.empty();
        }
        return _members.where((member) {
          final name = member['profiles']['full_name'] ?? '';
          return name.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        }).cast<Map<String, dynamic>>();
      },
      displayStringForOption: (option) => option['profiles']['full_name'] ?? '',
      onSelected: (option) {
        setState(() {
          _selectedUserId = option['user_id'];
          _complaintaboutController.text = option['profiles']['full_name'];
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) {
            _complaintaboutController.text = value;
            _selectedUserId = null;
          },
          decoration: InputDecoration(
            hintText: "Search member name...",
            prefixIcon: const Icon(Icons.person, color: accentTeal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: accentTeal,
      letterSpacing: 1.0,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int? maxLength,
  }) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: accentTeal),
        prefixIconConstraints: const BoxConstraints(
          minHeight: 40,
          minWidth: 40,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: subtleGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: accentTeal, width: 1.5),
        ),
      ),
    ),
  );

  Widget _buildDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: subtleGrey),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedCategory,
        hint: const Text("Select Category"),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: accentTeal),
        style: const TextStyle(color: darkPrimary, fontSize: 14),
        dropdownColor: Colors.white,
        items: _categories
            .map(
              (category) =>
                  DropdownMenuItem(value: category, child: Text(category)),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
      ),
    ),
  );

  Widget _buildDescriptionField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int? maxLength,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentTeal),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  counterText: "",
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 0),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        color: backgroundLight,
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${controller.text.length}/$maxLength",
            style: TextStyle(
              color: controller.text.length >= (maxLength ?? 0)
                  ? Colors.red
                  : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      ),
    ],
  );
}