import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController current = TextEditingController();
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirm = TextEditingController();

  // Visibility state for each field
  bool _currentVisible = false;
  bool _newVisible = false;
  bool _confirmVisible = false;

  Widget field({
    required String label,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback toggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              visible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF009688)],
              ),
            ),
            child: Stack(
              children: [
                // Back arrow
                Positioned(
                  top: 60,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                // Centered title
                Positioned.fill(
                  top: 60,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: const Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Lock icon
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ],
            ),
          ),

          // Fields + Button (Expanded)
          Expanded(
            child: Stack(
              children: [
                // Scrollable fields
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      field(
                        label: "Current Password",
                        controller: current,
                        visible: _currentVisible,
                        toggle: () {
                          setState(() {
                            _currentVisible = !_currentVisible;
                          });
                        },
                      ),
                      field(
                        label: "New Password",
                        controller: newPass,
                        visible: _newVisible,
                        toggle: () {
                          setState(() {
                            _newVisible = !_newVisible;
                          });
                        },
                      ),
                      field(
                        label: "Confirm Password",
                        controller: confirm,
                        visible: _confirmVisible,
                        toggle: () {
                          setState(() {
                            _confirmVisible = !_confirmVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 80), // space for the button
                    ],
                  ),
                ),

                // Button pinned at bottom
                Positioned(
                  bottom: 15,
                  left: 20,
                  right: 20,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Update Password",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
