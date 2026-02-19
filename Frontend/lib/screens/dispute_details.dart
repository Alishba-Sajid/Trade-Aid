import 'package:flutter/material.dart';

class EscalatedDisputeScreen extends StatelessWidget {
  const EscalatedDisputeScreen({super.key, required Map<String, String> caseInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 Header with back arrow + Trade&Aid brand
          Container(
            height: 65,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔙 Back Arrow + Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () {
                        Navigator.pop(context); // 👈 Go back
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Trade&Aid",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                // 🔔 Icons & Profile
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search,
                          color: Colors.black87, size: 28),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined,
                          color: Colors.black87, size: 30),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile.png'),
                      backgroundColor: Colors.black26,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Existing Screen Content (kept exactly as you had)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Escalated Dispute Resolution",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Review and resolve disputes that community admins were unable to handle.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Dispute Details",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow("Dispute ID", "#12345"),
                    _buildDetailRow("Date Reported", "2024-07-15"),
                    _buildDetailRow("Community", "Community A"),
                    _buildDetailRow("Status", "Escalated"),
                    _buildDetailRow("Parties Involved", "User A vs. User B"),
                    _buildDetailRow("Transaction/Resource", "Transaction ID: 87580"),
                    const SizedBox(height: 30),

                    const Text(
                      "Community Admin Actions",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow("Admin Decision", "Pending"),
                    _buildDetailRow("Actions Taken", "None"),
                    _buildDetailRow("Evidence", "Review logs and communications"),
                    const SizedBox(height: 30),

                    const Text(
                      "Communication",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Community Admin",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "We’ve reviewed the evidence and believe User A is at fault. They violated community guidelines by engaging in fraudulent activity.",
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007BFF).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Admin",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Thank you for the update. We’ll review this and get back to you.",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type your message...",
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007BFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text("Send"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
