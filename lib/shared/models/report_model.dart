import 'dart:convert';

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
    // Helper function to ensure all values are JSON-serializable
    dynamic serializeValue(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is DateTime) return value.toIso8601String();
      if (value is List) return value; // Lists are already serializable
      if (value is Map) return value; // Maps are already serializable
      // For any other type, convert to string
      return value.toString();
    }

    return {
      'id': serializeValue(id),
      'name': serializeValue(name),
      'reportType': serializeValue(reportType),
      'type': serializeValue(type),
      'receiverName': serializeValue(receiverName),
      'objective': serializeValue(objective),
      'description': serializeValue(description),
      'importance': serializeValue(importance),
      'mainPoints': serializeValue(mainPoints),
      'sources': serializeValue(sources),
      'roles': serializeValue(roles),
      'trends': serializeValue(trends),
      'themes': serializeValue(themes),
      'implications': serializeValue(implications),
      'scenarios': serializeValue(scenarios),
      'futurePlans': serializeValue(futurePlans),
      'approvingBody': serializeValue(approvingBody),
      'senderName': serializeValue(senderName),
      'role': serializeValue(role),
      'date': serializeValue(date),
      'userId': serializeValue(userId),
      'attachments': serializeValue(attachments),
      'linkAttachment': serializeValue(linkAttachment),
      'createdAt': serializeValue(createdAt),
      'updatedAt': serializeValue(updatedAt),
      'status': serializeValue(status),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to string
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map && value.containsKey('\$oid')) {
        // Handle MongoDB ObjectId format: {"$oid": "actual_id"}
        return value['\$oid'] ?? jsonEncode(value);
      }
      if (value is Map || value is List) return jsonEncode(value);
      return value.toString();
    }

    return Report(
      id: json['id'],
      name: safeString(json['name']),
      reportType: safeString(json['reportType'] ?? json['report_type']),
      type: safeString(json['type']),
      receiverName: safeString(json['receiverName'] ?? json['receiver_name']),
      objective: safeString(json['objective']),
      description: safeString(json['description']),
      importance: safeString(json['importance']),
      mainPoints: safeString(json['mainPoints'] ?? json['main_points']),
      sources: safeString(json['sources']),
      roles: safeString(json['roles']),
      trends: safeString(json['trends']),
      themes: safeString(json['themes']),
      implications: safeString(json['implications']),
      scenarios: safeString(json['scenarios']),
      futurePlans: safeString(json['futurePlans'] ?? json['future_plans']),
      approvingBody: safeString(
        json['approvingBody'] ?? json['approving_body'],
      ),
      senderName: safeString(json['senderName'] ?? json['sender_name']),
      role: safeString(json['role']),
      date: safeString(json['date']),
      userId: json['userId'] != null
          ? safeString(json['userId'])
          : (json['user_id'] != null ? safeString(json['user_id']) : null),
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      linkAttachment: safeString(
        json['linkAttachment'] ?? json['link_attachment'],
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      status: safeString(json['status']),
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
