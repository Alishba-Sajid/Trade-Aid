import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF009688),
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.5,
        color: Colors.black87,
        height: 1.5,
      ),
      textAlign: TextAlign.justify,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 15, 119, 124),
              Color.fromARGB(255, 17, 158, 144),],
              ),
            ),
            child: Stack(
              children: [
                // Back button
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
                // Title and icon centered
                Positioned.fill(
                  top: 60,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: const [
                        Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 25),
                        Icon(
                          Icons.description_outlined,
                          size: 100,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Trade&Aid – Terms & Conditions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Last Updated: January 2026",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    _sectionTitle("1. Acceptance of Terms"),
                    _sectionText(
                      "By using the Trade&Aid application, you agree to comply with and be bound by these Terms and Conditions. If you do not agree, please discontinue use of the application.",
                    ),
                    _sectionTitle("2. Purpose of the Application"),
                    _sectionText(
                      "Trade&Aid is a location-based community platform that allows users to buy and sell products, share household resources, and interact within nearby communities.",
                    ),
                    _sectionTitle("3. User Accounts"),
                    _sectionText(
                      "Users are responsible for maintaining the confidentiality of their accounts. All activities performed through an account are the responsibility of the account holder.",
                    ),
                    _sectionTitle("4. Location-Based Communities"),
                    _sectionText(
                      "The application uses location services to display communities within a 2-kilometer radius. Access to communities is automatically restricted if the user moves outside this range.",
                    ),
                    _sectionTitle("5. Buying, Selling & Resource Sharing"),
                    _sectionText(
                      "Users may list products for sale or share personal resources with others. Users are responsible for providing accurate descriptions, availability times, and pricing.",
                    ),
                    _sectionTitle("6. Payments"),
                    _sectionText(
                      "Trade&Aid supports online payments and cash-on-delivery or cash-on-usage options. The platform does not take responsibility for disputes arising from payment transactions.",
                    ),
                    _sectionTitle("7. Cancellations & Emergencies"),
                    _sectionText(
                      "Users may cancel bookings due to emergencies. Repeated last-minute cancellations may impact user ratings or access to platform features.",
                    ),
                    _sectionTitle("8. Community Administration"),
                    _sectionText(
                      "Community admins are responsible for managing members, handling complaints, and ensuring fair usage. Admins may be changed through democratic voting within the community.",
                    ),
                    _sectionTitle("9. Ratings & Conduct"),
                    _sectionText(
                      "Users can rate and review others based on their experience. Harassment, fraud, or misuse of the platform is strictly prohibited.",
                    ),
                    _sectionTitle("10. Limitation of Liability"),
                    _sectionText(
                      "Trade&Aid acts only as a facilitator. The platform is not responsible for the quality of products, services, or user behavior.",
                    ),
                    _sectionTitle("11. Changes to Terms"),
                    _sectionText(
                      "These Terms and Conditions may be updated periodically. Continued use of the application implies acceptance of the updated terms.",
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
