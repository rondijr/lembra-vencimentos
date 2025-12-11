/// DTO: ReminderDto (Espelho do schema remoto/Supabase)
class ReminderDto {
  final String id;
  final String user_id;      // snake_case do backend
  final String deadline_id;  // snake_case do backend
  final int days_before;     // snake_case do backend
  final String time_of_day;  // formato "HH:MM"
  final bool is_active;      // snake_case do backend
  final String frequency;    // enum como string
  final String created_at;   // ISO 8601 string
  final String? last_sent_at; // ISO 8601 string, nullable

  const ReminderDto({
    required this.id,
    required this.user_id,
    required this.deadline_id,
    required this.days_before,
    required this.time_of_day,
    required this.is_active,
    required this.frequency,
    required this.created_at,
    this.last_sent_at,
  });

  /// Serialização para JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': user_id,
        'deadline_id': deadline_id,
        'days_before': days_before,
        'time_of_day': time_of_day,
        'is_active': is_active,
        'frequency': frequency,
        'created_at': created_at,
        if (last_sent_at != null) 'last_sent_at': last_sent_at,
      };

  /// Desserialização do JSON
  factory ReminderDto.fromJson(Map<String, dynamic> json) {
    return ReminderDto(
      id: json['id'] as String,
      user_id: json['user_id'] as String,
      deadline_id: json['deadline_id'] as String,
      days_before: json['days_before'] as int,
      time_of_day: json['time_of_day'] as String,
      is_active: json['is_active'] as bool,
      frequency: json['frequency'] as String,
      created_at: json['created_at'] as String,
      last_sent_at: json['last_sent_at'] as String?,
    );
  }

  @override
  String toString() => 'ReminderDto(id: $id, days_before: $days_before, is_active: $is_active)';
}
