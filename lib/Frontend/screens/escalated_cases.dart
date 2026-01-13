import 'package:flutter/material.dart';
import 'dispute_details.dart';

class EscalatedCases extends StatefulWidget {
  const EscalatedCases({super.key});

  @override
  State<EscalatedCases> createState() => _EscalatedCasesState();
}

class _EscalatedCasesState extends State<EscalatedCases> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: EscalatedCasesScreen(),
    );
  }
}

// 🧾 Escalated Cases Screen (unchanged except sidebar/header removed)
class EscalatedCasesScreen extends StatelessWidget {
  const EscalatedCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> caseData = [
      {"id": "#12345", "participants": "Alice Johnson vs. Bob Williams", "status": "Open", "date": "2024-07-26"},
      {"id": "#12346", "participants": "Charlie Davis vs. Eve Green", "status": "In Review", "date": "2024-07-25"},
      {"id": "#12347", "participants": "Grace Miller vs. Henry Clark", "status": "Pending", "date": "2024-07-24"},
      {"id": "#12348", "participants": "Ivy White vs. Jack Brown", "status": "Open", "date": "2024-07-23"},
      {"id": "#12349", "participants": "Kevin Lee vs. Laura Adams", "status": "In Review", "date": "2024-07-22"},
      {"id": "#12350", "participants": "Mia Turner vs. Nathan Craig", "status": "Pending", "date": "2024-07-21"},
      {"id": "#12351", "participants": "Olivia Hill vs. Paul Baker", "status": "Open", "date": "2024-07-20"},
      {"id": "#12352", "participants": "Quinn Evans vs. Ryan Carter", "status": "In Review", "date": "2024-07-19"},
      {"id": "#12353", "participants": "Sophia King vs. Tom Parker", "status": "Pending", "date": "2024-07-18"},
      {"id": "#12354", "participants": "Uma Reed vs. Victor Stone", "status": "Open", "date": "2024-07-17"},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Escalated Cases",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Manage and resolve escalated disputes.",
              style: TextStyle(fontSize: 16, color: Color.fromARGB(136, 3, 3, 3))),
          const SizedBox(height: 25),

          // 🔍 Search + Filters
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 245, 245),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color.fromARGB(255, 238, 237, 237)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search by Case ID or Participant",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _filterBox("Status"),
              const SizedBox(width: 20),
              _filterBox("Date of Escalation"),
              const SizedBox(width: 20),
              _filterBox("Participants"),
            ],
          ),
          const SizedBox(height: 25),

          // 📊 Escalated Cases Table
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1500),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color.fromARGB(255, 226, 223, 223),
                      
                    ),
                    dataRowColor: WidgetStateProperty.all(Colors.white),
                    columnSpacing: 80,
                    columns: const [
                      DataColumn(label: Text("Case ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      DataColumn(label: Text("Participants", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      DataColumn(label: Text("Date of Escalation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    ],
                    rows: caseData.map((caseInfo) {
                      return DataRow(cells: [
                        DataCell(Text(caseInfo["id"]!)),
                        DataCell(Text(caseInfo["participants"]!)),
                        DataCell(_statusBadge(caseInfo["status"]!)),
                        DataCell(Text(caseInfo["date"]!)),
                        DataCell(
                          TextButton(
                            onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EscalatedDisputeScreen(
          caseInfo: {
            'id': '123',
            'title': 'Dispute with Vendor A',
          },
        ),
      ),
    );
  },
                            child: const Text(
                              "View",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _filterBox(String label) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
         color: const Color.fromARGB(255, 245, 245, 245),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(255, 219, 218, 218)),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          const Icon(Icons.keyboard_arrow_down,
              size: 18, color: Colors.black),
        ],
      ),
    );
  }

  static Widget _statusBadge(String status) {
    const color = Color.fromARGB(255, 223, 226, 223);
  
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}
