import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ReportDetailsPage extends StatefulWidget {
  const ReportDetailsPage({super.key});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  Uint8List? _imageBytes; // stores image data for web
  final ScrollController _scrollController = ScrollController(); // ✅ added

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ✅ cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      // ✅ Scrollbar with controller
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _scrollController, // ✅ connected
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController, // ✅ same controller
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  minWidth: constraints.maxWidth, // full page width
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Report Details",
                        style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Review and manage the reported issue",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        "Reported Issue",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SizedBox(
                          height: 150,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Reporting Member",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 158, 156, 156),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Sophia Bennett",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Reported Date",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 158, 156, 156),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "July 26, 2024",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Community name",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 158, 156, 156),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Green Valley (Gulberg greens)",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      const Text(
                        "Issue Description",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "The user is posting inappropriate content that violates our community guidelines. "
                        "The posts contain offensive language and are disrespectful to other members. "
                        "Please take immediate action to remove the content and warn the user.",
                        style: TextStyle(color: Colors.black87, height: 2),
                      ),

                      const SizedBox(height: 50),

                      const Text(
                        "Evidence",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100,
                          ),
                          child: _imageBytes == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.cloud_upload_outlined,
                                        size: 60, color: Colors.grey),
                                    SizedBox(height: 10),
                                    Text("Tap to upload evidence image",
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "Status",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: [
                          _statusChip("Pending",
                              const Color.fromARGB(255, 207, 207, 206)),
                          _statusChip("Investigating",
                              const Color.fromARGB(255, 48, 154, 241)),
                          _statusChip("Resolved", Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
