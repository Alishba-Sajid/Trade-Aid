import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ Your header section
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,

        // Left side title
        title: const Padding(
          padding: EdgeInsets.only(left: 30),
          child: Text(
            'Trade&Aid',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),

        // Right side profile icon
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 50.0),
            child: CircleAvatar(
              backgroundColor: Color.fromARGB(255, 204, 194, 194),
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],

        // Bottom divider line
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            color: Colors.grey,
            height: 1,
            thickness: 0.3,
          ),
        ),
      ),

      // ✅ Forgot Password Body
      body: Center(
        child: SingleChildScrollView(
          
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 0),

              // Heading
              const Padding(padding: EdgeInsets.only(top: 0)),
              const Text(
                "Forgot your password?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              // Subtitle
              const Text(
                "Enter the email address associated with your account and we’ll send you instructions to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // Email input
              SizedBox(
  width: 400, // 👈 Controls width
  height: 45, // 👈 Controls height
  child: TextFormField(
    decoration: InputDecoration(
      hintText: 'Email address',
      hintStyle: TextStyle(color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
),

              const SizedBox(height: 20),

              // Button
              SizedBox(
            width: 400,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    
                  },
                  child: const Text(
                    "Send reset instructions",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Sign-in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Remember your password?",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
