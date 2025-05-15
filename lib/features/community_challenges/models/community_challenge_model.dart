class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int difficulty; // 1-5
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final int points;
  final List<String> tasks;
  final List<String> tips;
  final String createdBy;
  final String imageUrl;
  final bool isOfficial;
  
  // Pour les défis auxquels l'utilisateur participe
  final bool joined;
  final bool completed;
  final double progress;
  final List<String> completedTasks;
  
  // Pour les défis avec équipes
  final bool isTeamChallenge;
  final List<Team>? teams;
  
  // Récompenses
  final List<String> rewards; // Liste des badges ou points spéciaux
  
  CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
    required this.participantsCount,
    required this.points,
    required this.tasks,
    this.tips = const [],
    required this.createdBy,
    required this.imageUrl,
    this.isOfficial = false,
    this.joined = false,
    this.completed = false,
    this.progress = 0.0,
    this.completedTasks = const [],
    this.isTeamChallenge = false,
    this.teams,
    this.rewards = const [],
  });
  
  // Conversion depuis/vers JSON
  factory CommunityChallenge.fromJson(Map<String, dynamic> json) {
    return CommunityChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantsCount: json['participantsCount'] as int,
      points: json['points'] as int,
      tasks: List<String>.from(json['tasks']),
      tips: json['tips'] != null ? List<String>.from(json['tips']) : [],
      createdBy: json['createdBy'] as String,
      imageUrl: json['imageUrl'] as String,
      isOfficial: json['isOfficial'] as bool? ?? false,
      joined: json['joined'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      completedTasks: json['completedTasks'] != null ? List<String>.from(json['completedTasks']) : [],
      isTeamChallenge: json['isTeamChallenge'] as bool? ?? false,
      teams: json['teams'] != null 
          ? (json['teams'] as List).map((team) => Team.fromJson(team)).toList() 
          : null,
      rewards: json['rewards'] != null ? List<String>.from(json['rewards']) : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participantsCount': participantsCount,
      'points': points,
      'tasks': tasks,
      'tips': tips,
      'createdBy': createdBy,
      'imageUrl': imageUrl,
      'isOfficial': isOfficial,
      'joined': joined,
      'completed': completed,
      'progress': progress,
      'completedTasks': completedTasks,
      'isTeamChallenge': isTeamChallenge,
      'teams': teams?.map((team) => team.toJson()).toList(),
      'rewards': rewards,
    };
  }
  
  // Calcule si le défi est actif en fonction des dates
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
  
  // Calcule si le défi est terminé
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }
  
  // Calcule si le défi est à venir
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }
  
  // Crée une copie modifiée de l'objet
  CommunityChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? difficulty,
    DateTime? startDate,
    DateTime? endDate,
    int? participantsCount,
    int? points,
    List<String>? tasks,
    List<String>? tips,
    String? createdBy,
    String? imageUrl,
    bool? isOfficial,
    bool? joined,
    bool? completed,
    double? progress,
    List<String>? completedTasks,
    bool? isTeamChallenge,
    List<Team>? teams,
    List<String>? rewards,
  }) {
    return CommunityChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participantsCount: participantsCount ?? this.participantsCount,
      points: points ?? this.points,
      tasks: tasks ?? this.tasks,
      tips: tips ?? this.tips,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
      isOfficial: isOfficial ?? this.isOfficial,
      joined: joined ?? this.joined,
      completed: completed ?? this.completed,
      progress: progress ?? this.progress,
      completedTasks: completedTasks ?? this.completedTasks,
      isTeamChallenge: isTeamChallenge ?? this.isTeamChallenge,
      teams: teams ?? this.teams,
      rewards: rewards ?? this.rewards,
    );
  }
}

class Team {
  final String id;
  final String name;
  final String imageUrl;
  final List<TeamMember> members;
  final double progress;
  final int points;
  
  Team({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.members,
    this.progress = 0.0,
    this.points = 0,
  });
  
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      members: (json['members'] as List).map((member) => TeamMember.fromJson(member)).toList(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      points: json['points'] as int? ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'members': members.map((member) => member.toJson()).toList(),
      'progress': progress,
      'points': points,
    };
  }
}

class TeamMember {
  final String userId;
  final String name;
  final String imageUrl;
  final int contribution; // Points contribués au défi
  final bool isLeader;
  
  TeamMember({
    required this.userId,
    required this.name,
    required this.imageUrl,
    this.contribution = 0,
    this.isLeader = false,
  });
  
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['userId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      contribution: json['contribution'] as int? ?? 0,
      isLeader: json['isLeader'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'imageUrl': imageUrl,
      'contribution': contribution,
      'isLeader': isLeader,
    };
  }
}

class LeaderboardEntry {
  final String userId;
  final String name;
  final String imageUrl;
  final int points;
  final int rank;
  final int completedChallenges;
  final List<String> badges;
  
  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.points,
    required this.rank,
    this.completedChallenges = 0,
    this.badges = const [],
  });
  
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      points: json['points'] as int,
      rank: json['rank'] as int,
      completedChallenges: json['completedChallenges'] as int? ?? 0,
      badges: json['badges'] != null ? List<String>.from(json['badges']) : [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'imageUrl': imageUrl,
      'points': points,
      'rank': rank,
      'completedChallenges': completedChallenges,
      'badges': badges,
    };
  }
} 