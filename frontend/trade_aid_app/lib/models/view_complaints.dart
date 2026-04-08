class ComplaintModel {
  final String id;
  final String subject;
  final String reporterName;
  final String description;
  final String? imageUrl;

  final String complainantId;
  final String accusedUserId;
  final String communityId;

  final String status;

  final String? accusedName;
  final String? accusedImage;
  final String? accusedAddress;
final bool? isValid;
final String? complainantName;
  ComplaintModel({
    required this.id,
    required this.subject,
    required this.reporterName,
    required this.description,
    this.imageUrl,
    required this.complainantId,
    required this.accusedUserId,
    required this.communityId,
    required this.status,
    this.accusedName,
    this.accusedImage,
    this.accusedAddress,
    this.isValid,
    this.complainantName,
  });
}