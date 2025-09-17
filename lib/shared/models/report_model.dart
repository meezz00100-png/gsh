class Report {
  final String? id;
  final String name;
  final String reportType;
  final String type;
  final String receiverName;
  final String objective;
  final String description;
  final String importance;
  final String mainPoints;
  final String sources;
  final String roles;
  final String trends;
  final String themes;
  final String implications;
  final String scenarios;
  final String futurePlans;
  final String approvingBody;
  final String senderName;
  final String role;
  final String date;
  final String? userId;
  final List<String> attachments;
  final String? linkAttachment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'draft', 'completed'

  Report({
    this.id,
    required this.name,
    required this.reportType,
    required this.type,
    required this.receiverName,
    required this.objective,
    required this.description,
    required this.importance,
    required this.mainPoints,
    required this.sources,
    required this.roles,
    required this.trends,
    required this.themes,
    required this.implications,
    required this.scenarios,
    required this.futurePlans,
    required this.approvingBody,
    required this.senderName,
    required this.role,
    required this.date,
    this.userId,
    this.attachments = const [],
    this.linkAttachment,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'draft',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'report_type': reportType,
      'type': type,
      'receiver_name': receiverName,
      'objective': objective,
      'description': description,
      'importance': importance,
      'main_points': mainPoints,
      'sources': sources,
      'roles': roles,
      'trends': trends,
      'themes': themes,
      'implications': implications,
      'scenarios': scenarios,
      'future_plans': futurePlans,
      'approving_body': approvingBody,
      'sender_name': senderName,
      'role': role,
      'date': date,
      'user_id': userId,
      'attachments': attachments,
      'link_attachment': linkAttachment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      name: json['name'] ?? '',
      reportType: json['report_type'] ?? '',
      type: json['type'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      objective: json['objective'] ?? '',
      description: json['description'] ?? '',
      importance: json['importance'] ?? '',
      mainPoints: json['main_points'] ?? '',
      sources: json['sources'] ?? '',
      roles: json['roles'] ?? '',
      trends: json['trends'] ?? '',
      themes: json['themes'] ?? '',
      implications: json['implications'] ?? '',
      scenarios: json['scenarios'] ?? '',
      futurePlans: json['future_plans'] ?? '',
      approvingBody: json['approving_body'] ?? '',
      senderName: json['sender_name'] ?? '',
      role: json['role'] ?? '',
      date: json['date'] ?? '',
      userId: json['user_id'],
      attachments: List<String>.from(json['attachments'] ?? []),
      linkAttachment: json['link_attachment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      status: json['status'] ?? 'draft',
    );
  }

  Report copyWith({
    String? id,
    String? name,
    String? reportType,
    String? type,
    String? receiverName,
    String? objective,
    String? description,
    String? importance,
    String? mainPoints,
    String? sources,
    String? roles,
    String? trends,
    String? themes,
    String? implications,
    String? scenarios,
    String? futurePlans,
    String? approvingBody,
    String? senderName,
    String? role,
    String? date,
    String? userId,
    List<String>? attachments,
    String? linkAttachment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Report(
      id: id ?? this.id,
      name: name ?? this.name,
      reportType: reportType ?? this.reportType,
      type: type ?? this.type,
      receiverName: receiverName ?? this.receiverName,
      objective: objective ?? this.objective,
      description: description ?? this.description,
      importance: importance ?? this.importance,
      mainPoints: mainPoints ?? this.mainPoints,
      sources: sources ?? this.sources,
      roles: roles ?? this.roles,
      trends: trends ?? this.trends,
      themes: themes ?? this.themes,
      implications: implications ?? this.implications,
      scenarios: scenarios ?? this.scenarios,
      futurePlans: futurePlans ?? this.futurePlans,
      approvingBody: approvingBody ?? this.approvingBody,
      senderName: senderName ?? this.senderName,
      role: role ?? this.role,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      attachments: attachments ?? this.attachments,
      linkAttachment: linkAttachment ?? this.linkAttachment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  String get summary {
    if (description.isNotEmpty) {
      return description.length > 100 
          ? '${description.substring(0, 100)}...' 
          : description;
    }
    if (objective.isNotEmpty) {
      return objective.length > 100 
          ? '${objective.substring(0, 100)}...' 
          : objective;
    }
    return 'No description available';
  }
}
