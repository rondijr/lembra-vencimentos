/// Entity: Reminder (Domínio)
/// Representa um lembrete personalizado com regras de negócio
class Reminder {
  final String id;
  final String userId;
  final String deadlineId;
  final int daysBefore;
  final TimeOfDay timeOfDay;
  final bool isActive;
  final ReminderFrequency frequency;
  final DateTime createdAt;
  final DateTime? lastSentAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.deadlineId,
    required this.daysBefore,
    required this.timeOfDay,
    required this.isActive,
    required this.frequency,
    required this.createdAt,
    this.lastSentAt,
  }) {
    _validate();
  }

  /// Invariantes de domínio
  void _validate() {
    if (id.isEmpty) {
      throw ArgumentError('Reminder ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (deadlineId.isEmpty) {
      throw ArgumentError('Deadline ID cannot be empty');
    }
    if (daysBefore < 0 || daysBefore > 365) {
      throw ArgumentError('Days before must be between 0 and 365');
    }
    if (lastSentAt != null && lastSentAt!.isBefore(createdAt)) {
      throw ArgumentError('Last sent date cannot be before created date');
    }
  }

  /// Regra de negócio: verifica se deve enviar lembrete hoje
  bool shouldSendToday(DateTime deadlineDate) {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final targetDate = deadlineDate.subtract(Duration(days: daysBefore));
    
    return now.year == targetDate.year &&
           now.month == targetDate.month &&
           now.day == targetDate.day;
  }

  /// Regra de negócio: calcula próximo envio
  DateTime? calculateNextSend(DateTime deadlineDate) {
    if (!isActive) return null;
    
    final targetDate = deadlineDate.subtract(Duration(days: daysBefore));
    final nextSend = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    
    return nextSend.isAfter(DateTime.now()) ? nextSend : null;
  }

  /// Regra de negócio: verifica se é muito frequente
  bool get isTooFrequent {
    return frequency == ReminderFrequency.hourly || 
           (frequency == ReminderFrequency.daily && daysBefore > 30);
  }

  /// Marca lembrete como enviado
  Reminder markAsSent() {
    return Reminder(
      id: id,
      userId: userId,
      deadlineId: deadlineId,
      daysBefore: daysBefore,
      timeOfDay: timeOfDay,
      isActive: isActive,
      frequency: frequency,
      createdAt: createdAt,
      lastSentAt: DateTime.now(),
    );
  }

  /// Ativa/desativa lembrete
  Reminder toggleActive() {
    return Reminder(
      id: id,
      userId: userId,
      deadlineId: deadlineId,
      daysBefore: daysBefore,
      timeOfDay: timeOfDay,
      isActive: !isActive,
      frequency: frequency,
      createdAt: createdAt,
      lastSentAt: lastSentAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Reminder(id: $id, daysBefore: $daysBefore, isActive: $isActive)';
}

/// Value Object: TimeOfDay
class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute}) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError('Hour must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError('Minute must be between 0 and 59');
    }
  }

  String toFormattedString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  factory TimeOfDay.fromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeOfDay &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => toFormattedString();
}

/// Enum para frequência de lembretes
enum ReminderFrequency {
  once,
  daily,
  weekly,
  monthly,
  hourly;

  String get value => name;

  static ReminderFrequency fromString(String value) {
    return ReminderFrequency.values.firstWhere(
      (f) => f.name == value.toLowerCase(),
      orElse: () => ReminderFrequency.once,
    );
  }
}
