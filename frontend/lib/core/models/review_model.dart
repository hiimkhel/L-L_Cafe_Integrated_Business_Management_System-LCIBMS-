enum ReviewStatus { pending, published, archived }

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
      id: e['id'].toString(),
      customerId: '#${e['user_id']}',
      customerName: e['customer_name'],
      submittedAt: DateTime.parse(e['created_at']),
      content: e['review_text'],
      rating: (e['rating'] as num).toDouble(),
      status: _mapStatus(e['status']),
      avatarUrl: e['profile_picture'],
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