class StyleModel {
  final String imageUrl;
  final String userId;
  int counter;

  StyleModel({
    required this.imageUrl,
    required this.userId,
    this.counter = 0,
  });

  // Convert Firestore document to StyleModel
  factory StyleModel.fromJson(Map<String, dynamic> json) {
    return StyleModel(
      imageUrl: json['imageUrl'] ?? '',
      userId: json['userId'] ?? '',
      counter: json['counter'] ?? 0,
    );
  }

  // Convert StyleModel to a Map
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'userId': userId,
      'counter': counter,
    };
  }
}
