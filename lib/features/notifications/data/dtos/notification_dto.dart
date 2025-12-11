/// DTO: NotificationDto (Espelho do schema remoto/Supabase)
class NotificationDto {
  final String id;
  final String deadline_id; // snake_case do backend
  final String user_id;     // snake_case do backend
  final String title;
  final String body;
  final String scheduled_for; // ISO 8601 string
  final bool is_sent;         // snake_case do backend
  final String? sent_at;      // ISO 8601 string, nullable
  final String priority;      // enum como string
  final String created_at;    // ISO 8601 string

  const NotificationDto({
    required this.id,
    required this.deadline_id,
    required this.user_id,
    required this.title,
    required this.body,
    required this.scheduled_for,
    required this.is_sent,
    this.sent_at,
    required this.priority,
    required this.created_at,
  });

  /// Serialização para JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'deadline_id': deadline_id,
        'user_id': user_id,
        'title': title,
        'body': body,
        'scheduled_for': scheduled_for,
        'is_sent': is_sent,
        if (sent_at != null) 'sent_at': sent_at,
        'priority': priority,
        'created_at': created_at,
      };

  /// Desserialização do JSON
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      deadline_id: json['deadline_id'] as String,
      user_id: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      scheduled_for: json['scheduled_for'] as String,
      is_sent: json['is_sent'] as bool,
      sent_at: json['sent_at'] as String?,
      priority: json['priority'] as String,
      created_at: json['created_at'] as String,
    );
  }

  @override
  String toString() => 'NotificationDto(id: $id, title: $title, is_sent: $is_sent)';
}
