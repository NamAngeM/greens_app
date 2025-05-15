enum PostCategory {
  tips,
  achievements,
  questions,
  products,
  events,
}

enum SortOrder {
  newest,
  mostLiked,
  mostCommented,
}

class SocialPost {
  final String id;
  final String content;
  final List<String> images;
  final Author author;
  final DateTime createdAt;
  final PostCategory category;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isBookmarked;
  final List<Comment>? comments;
  final Map<String, dynamic>? metadata;
  
  // Liens vers d'autres entités
  final String? productId;
  final String? challengeId;
  final String? goalId;
  
  SocialPost({
    required this.id,
    required this.content,
    this.images = const [],
    required this.author,
    required this.createdAt,
    required this.category,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.comments,
    this.metadata,
    this.productId,
    this.challengeId,
    this.goalId,
  });
  
  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as String,
      content: json['content'] as String,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      author: Author.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: _categoryFromString(json['category'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      productId: json['productId'] as String?,
      challengeId: json['challengeId'] as String?,
      goalId: json['goalId'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'images': images,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'category': _categoryToString(category),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'comments': comments?.map((c) => c.toJson()).toList(),
      'metadata': metadata,
      'productId': productId,
      'challengeId': challengeId,
      'goalId': goalId,
    };
  }
  
  SocialPost copyWith({
    String? id,
    String? content,
    List<String>? images,
    Author? author,
    DateTime? createdAt,
    PostCategory? category,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isBookmarked,
    List<Comment>? comments,
    Map<String, dynamic>? metadata,
    String? productId,
    String? challengeId,
    String? goalId,
  }) {
    return SocialPost(
      id: id ?? this.id,
      content: content ?? this.content,
      images: images ?? this.images,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
      productId: productId ?? this.productId,
      challengeId: challengeId ?? this.challengeId,
      goalId: goalId ?? this.goalId,
    );
  }
  
  static PostCategory _categoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'tips':
        return PostCategory.tips;
      case 'achievements':
        return PostCategory.achievements;
      case 'questions':
        return PostCategory.questions;
      case 'products':
        return PostCategory.products;
      case 'events':
        return PostCategory.events;
      default:
        return PostCategory.tips;
    }
  }
  
  static String _categoryToString(PostCategory category) {
    switch (category) {
      case PostCategory.tips:
        return 'tips';
      case PostCategory.achievements:
        return 'achievements';
      case PostCategory.questions:
        return 'questions';
      case PostCategory.products:
        return 'products';
      case PostCategory.events:
        return 'events';
    }
  }
  
  static String getCategoryDisplayName(PostCategory category) {
    switch (category) {
      case PostCategory.tips:
        return 'Astuces';
      case PostCategory.achievements:
        return 'Réalisations';
      case PostCategory.questions:
        return 'Questions';
      case PostCategory.products:
        return 'Produits';
      case PostCategory.events:
        return 'Événements';
    }
  }
}

class Author {
  final String id;
  final String name;
  final String imageUrl;
  final int ecoScore; // Score écologique de l'utilisateur
  final bool isVerified; // Indique si l'utilisateur est vérifié
  
  Author({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.ecoScore = 0,
    this.isVerified = false,
  });
  
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      ecoScore: json['ecoScore'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'ecoScore': ecoScore,
      'isVerified': isVerified,
    };
  }
}

class Comment {
  final String id;
  final String content;
  final Author author;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  
  Comment({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });
  
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      content: json['content'] as String,
      author: Author.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }
  
  Comment copyWith({
    String? id,
    String? content,
    Author? author,
    DateTime? createdAt,
    int? likeCount,
    bool? isLiked,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
} 