import 'package:flutter/material.dart';

class CommunityElectionHistoryScreen extends StatelessWidget {
  const CommunityElectionHistoryScreen({super.key});

  // Sample data for the election history table
  final List<Map<String, String>> electionHistoryData = const [
    {
      "date": "2023-04-15",
      "candidates": "Alice Johnson, Robert Smith",
      "results": "Alice Johnson (Winner)",
      "turnout": "65%",
    },
    {
      "date": "2022-11-20",
      "candidates": "Emily Davis, Michael Brown",
      "results": "Emily Davis (Winner)",
      "turnout": "72%",
    },
    {
      "date": "2022-05-10",
      "candidates": "Sarah Clark, David Wilson",
      "results": "Sarah Clark (Winner)",
      "turnout": "58%",
    },
    {
      "date": "2021-12-05",
      "candidates": "Jessica Lee, Christopher Taylor",
      "results": "Jessica Lee (Winner)",
      "turnout": "69%",
    },
    {
      "date": "2021-06-20",
      "candidates": "Olivia Martinez, Daniel Anderson",
      "results": "Olivia Martinez (Winner)",
      "turnout": "62%",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Defines the padding used for the entire screen content
    const screenPadding = EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0);
    // Defines the internal padding for table cells
    const cellPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);

    return Scaffold(
      backgroundColor: Colors.white, // Use white background for the screen
      body: Padding(
        padding: screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title
            const Text(
              "Community Election History",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height:15 ),

            // 2. Description
            const Text(
              "View the complete historical record of past elections for each community.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

           

            // 4. Table Header
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 216, 216), // Very light background for the header
                border: Border.symmetric(
                  vertical: BorderSide(color: Colors.grey[300]!, width: 1.0),
                ),
              ),
              padding: cellPadding,
              child: const Row(
                children: [
                  // Election Date
                  Expanded(
                      flex: 2,
                      child: Text("Election Date",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87))),
                  // Candidates
                  Expanded(
                      flex: 4,
                      child: Text("Candidates",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87))),
                  // Results
                  Expanded(
                      flex: 3,
                      child: Text("Results",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87))),
                  // Voter Turnout
                  Expanded(
                      flex: 2,
                      child: Text("Voter Turnout",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87))),
                ],
              ),
            ),

            // 5. Table Body (Scrollable List)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
                  ),
                ),
                child: ListView.separated(
                  itemCount: electionHistoryData.length,
                  // Use a thin divider for horizontal separation
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  itemBuilder: (context, index) {
                    final item = electionHistoryData[index];
                    return Container(
                      // Add padding to match header
                      padding: cellPadding, 
                      color: Colors.white, // Ensure row background is white
                      child: Row(
                        children: [
                          // Election Date
                          Expanded(
                              flex: 2,
                              child: Text(item["date"]!,
                                  style: const TextStyle(
                                      color: Colors.black87))),
                          // Candidates
                          Expanded(
                              flex: 4,
                              child: Text(item["candidates"]!,
                                  style: const TextStyle(
                                      color: Colors.black87))),
                          // Results
                          Expanded(
                              flex: 3,
                              child: Text(item["results"]!,
                                  style: const TextStyle(
                                      color: Colors.black87))),
                          // Voter Turnout
                          Expanded(
                              flex: 2,
                              child: Text(item["turnout"]!,
                                  style: const TextStyle(
                                      color: Colors.black87))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}