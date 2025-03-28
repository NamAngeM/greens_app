class ArticleModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final List<String> categories;
  final int readTimeMinutes;
  final DateTime publishDate;
  final String? authorName;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.categories,
    required this.readTimeMinutes,
    required this.publishDate,
    this.authorName,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      categories: json['categories'] != null 
          ? List<String>.from(json['categories']) 
          : [],
      readTimeMinutes: json['readTimeMinutes'] ?? 0,
      publishDate: json['publishDate'] != null 
          ? DateTime.parse(json['publishDate']) 
          : DateTime.now(),
      authorName: json['authorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'categories': categories,
      'readTimeMinutes': readTimeMinutes,
      'publishDate': publishDate.toIso8601String(),
      'authorName': authorName,
    };
  }
}
