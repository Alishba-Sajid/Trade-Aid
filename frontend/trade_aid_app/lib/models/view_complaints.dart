
enum ComplaintStatus { pending, resolved, suspended }
/// ================= MODEL =================
class ComplaintModel {
  final String id;
  final String subject;
  final String reporterName;
  final String category;
  final String description;
  final String? imageUrl;
  ComplaintStatus status;
  DateTime? suspensionEndDate;

  ComplaintModel({
    required this.id,
    required this.subject,
    required this.reporterName,
    required this.category,
    required this.description,
    this.imageUrl,
    this.status = ComplaintStatus.pending,
    this.suspensionEndDate,
  });
}
