import 'package:flutter/material.dart';

class WelcomeTermsScreen extends StatefulWidget {
  const WelcomeTermsScreen({super.key});

  @override
  State<WelcomeTermsScreen> createState() => _WelcomeTermsScreenState();
}

class _WelcomeTermsScreenState extends State<WelcomeTermsScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header gradient
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00695C), Color(0xFF009688)],
              ),
            ),
            child: SingleChildScrollView(
              // <-- added
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Welcome to Trade&Aid",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/whitelogo.png', height: 170, width: 170),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),

          // Scrollable T&C preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Please read and accept our Terms & Conditions to continue using Trade&Aid.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Key Points:",
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF009688),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "• Users must register with valid credentials.\n"
                        "• Community-based interaction only.\n"
                        "• Buy, sell, and share resources responsibly.\n"
                        "• Follow community rules and admin decisions.\n"
                        "• Use the app at your own risk; Trade&Aid is not liable for disputes or damages.",
                        style: TextStyle(
                          fontSize: 14.5,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreed,
                            activeColor: const Color(0xFF009688),
                            onChanged: (val) {
                              setState(() {
                                _agreed = val ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text(
                              "I have read and agree to the Terms & Conditions",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _agreed
                                ? const Color(0xFF009688)
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _agreed
                              ? () {
                                  // Navigate to Create Account Screen
                                  Navigator.pushNamed(context, '/register');
                                }
                              : null,
                          child: const Text(
                            "Continue",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // Navigate to full Terms & Conditions screen
                          Navigator.pushNamed(context, '/terms_conditions');
                        },
                        child: const Text(
                          "Read Full Terms & Conditions",
                          style: TextStyle(
                            color: Color(0xFF009688),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
