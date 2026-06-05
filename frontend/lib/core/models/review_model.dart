enum ReviewStatus { pending, published, archived }

  ReviewStatus reviewStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReviewStatus.pending;
      case 'published':
        return ReviewStatus.published;
      case 'archived':
        return ReviewStatus.archived;
      default:
        return ReviewStatus.pending; // fallback
    }
  }

class ReviewModel {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime submittedAt;
  final String content;
  final double rating;
  final ReviewStatus status;
  final String? avatarUrl;
  

  ReviewModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.submittedAt,
    required this.content,
    required this.rating,
    required this.status,
    this.avatarUrl,
  });

  ReviewModel copyWith({ReviewStatus? status}) => ReviewModel(
        id: id,
        customerId: customerId,
        customerName: customerName,
        submittedAt: submittedAt,
        content: content,
        rating: rating,
        status: status ?? this.status,
        avatarUrl: avatarUrl,
      );

  factory ReviewModel.fromJson(Map<String, dynamic> e) {
    return ReviewModel(
      id: e['id']?.toString() ?? '',
      customerId: e['user_id']?.toString() ?? '',
      customerName: e['customer_name']?.toString() ?? 'Anonymous',
      submittedAt: DateTime.tryParse(
            e['submitted_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
      content: e['review_text']?.toString() ?? '',
      rating: (e['rating'] as num?)?.toDouble() ?? 0.0,
      status: reviewStatusFromString(e['status']?.toString() ?? ''),
      avatarUrl: e['profile_picture']?.toString(),
    );
  }

  static ReviewStatus _mapStatus(String status) {
    switch (status) {
      case 'published': return ReviewStatus.published;
      case 'archived': return ReviewStatus.archived;
      default: return ReviewStatus.pending;
    }
  }
  

}