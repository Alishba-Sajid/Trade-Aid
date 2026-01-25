import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/app_bar.dart';

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

  String? _selectedCategory;
  File? _attachedImage;
  final List<String> _categories = ['Products', 'Resources'];

  final HelpSupportService _service = HelpSupportService();

  // ================== Submit Issue ==================
  void _submitIssue() async {
    String subject = _subjectController.text.trim();
    String description = _descriptionController.text.trim();

    if (subject.isEmpty || description.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: accentTeal),
      ),
    );

    bool success = await _service.submitIssue(
      subject: subject,
      description: description,
      category: _selectedCategory!,
      attachment: _attachedImage,
    );

    Navigator.pop(context); // remove loading

    if (success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: backgroundLight,
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: accentTeal),
              SizedBox(width: 10),
              Text(
                "Submitted",
                style: TextStyle(fontWeight: FontWeight.bold, color: darkPrimary),
              ),
            ],
          ),
          content: const Text(
              "Your issue has been sent to the admin. They will respond soon."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: accentTeal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Close"),
            ),
          ],
        ),
      );

      _subjectController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _attachedImage = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit issue. Please try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
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
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
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
  Widget build(BuildContext context) {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          // ================== Custom App Bar ==================
      // ================== Custom App Bar ==================
AppBarWidget(
  title: 'Help & Support',
  onBack: () => Navigator.pop(context),
),


          // ================== Body Content ==================
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: keyboardOpen
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: _buildFormContent(),
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

  // ================== Form Content ==================
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informational Card
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
                    color: darkPrimary),
              ),
              SizedBox(height: 8),
              Text(
                "Submit your complaint or query below and our admin team will assist you shortly.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.black54, height: 1.4),
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
                  color: accentTeal, fontWeight: FontWeight.w600)),
          style: TextButton.styleFrom(
            backgroundColor: accentTeal.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                      letterSpacing: 1.1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================== Section Label ==================
  Widget _buildSectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: accentTeal,
          letterSpacing: 1.0,
        ),
      );

  // ================== Text Field ==================
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int? maxLength,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: controller,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: accentTeal),
            prefixIconConstraints:
                const BoxConstraints(minHeight: 40, minWidth: 40),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: subtleGrey)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: accentTeal, width: 1.5)),
          ),
        ),
      );

  // ================== Dropdown ==================
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
                offset: const Offset(0, 2))
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
                .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
        ),
      );

  // ================== Description Field ==================
  Widget _buildDescriptionField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int? maxLength,
  }) =>
      Column(
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
                    offset: const Offset(0, 2))
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
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
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
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 0),
            color: backgroundLight,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${controller.text.length}/$maxLength",
                style: TextStyle(
                    color: controller.text.length >= (maxLength ?? 0)
                        ? Colors.red
                        : Colors.grey,
                    fontSize: 12),
              ),
            ),
          ),
        ],
      );
}
