import 'package:flutter/material.dart';

class AdminRotationScreen extends StatelessWidget {
  const AdminRotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rotationData = [
      {
        "community": "Tech Enthusiasts Group",
        "status": "Active",
        "progress": 75,
      },
      {
        "community": "Local Book Club",
        "status": "Pending",
        "progress": 0,
      },
      {
        "community": "Photography Club",
        "status": "Completed",
        "progress": 100,
      },
      {
        "community": "Gardens",
        "status": "Pending",
        "progress": 100,
      },
    ];

    Color statusColor(String status) {
      switch (status) {
        case "Active":
          return const Color(0xFF4CAF50); // Green
        case "Pending":
          return const Color(0xFFFFC107); // Yellow
        case "Completed":
          return const Color(0xFF2196F3); // Blue
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Page Title
            const Text(
              "Admin Rotation",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Election Progress",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 25),

            // 🔹 Table Container (Header + Rows)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withValues(alpha:0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // 🔹 Table Header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            "Community",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Election Status",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Progress",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Table Body
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rotationData.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 0,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    itemBuilder: (context, index) {
                      final item = rotationData[index];
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Community
                            Expanded(
                              flex: 4,
                              child: Text(
                                item["community"],
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),

                            // Election Status Chip
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 130),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor(item["status"])
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["status"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: statusColor(item["status"]),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Progress Bar
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: item["progress"] / 100,
                                    backgroundColor:
                                        Colors.grey.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      statusColor(item["status"]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
