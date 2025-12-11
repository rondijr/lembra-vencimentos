/// Entity: Notification (Domínio)
/// Representa uma notificação agendada com regras de negócio
class Notification {
  final String id;
  final String deadlineId;
  final String userId;
  final String title;
  final String body;
  final DateTime scheduledFor;
  final bool isSent;
  final DateTime? sentAt;
  final NotificationPriority priority;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.deadlineId,
    required this.userId,
    required this.title,
    required this.body,
    required this.scheduledFor,
    required this.isSent,
    this.sentAt,
    required this.priority,
    required this.createdAt,
  }) {
    _validate();
  }

  /// Invariantes de domínio
  void _validate() {
    if (id.isEmpty) {
      throw ArgumentError('Notification ID cannot be empty');
    }
    if (deadlineId.isEmpty) {
      throw ArgumentError('Deadline ID cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (title.isEmpty || title.length > 100) {
      throw ArgumentError('Title must be between 1 and 100 characters');
    }
    if (body.isEmpty || body.length > 500) {
      throw ArgumentError('Body must be between 1 and 500 characters');
    }
    if (isSent && sentAt == null) {
      throw ArgumentError('Sent notifications must have a sentAt timestamp');
    }
    if (!isSent && sentAt != null) {
      throw ArgumentError('Unsent notifications cannot have a sentAt timestamp');
    }
    if (sentAt != null && sentAt!.isBefore(createdAt)) {
      throw ArgumentError('Sent date cannot be before created date');
    }
  }

  /// Regra de negócio: verifica se notificação está atrasada
  bool get isOverdue {
    return !isSent && DateTime.now().isAfter(scheduledFor);
  }

  /// Regra de negócio: verifica se deve ser enviada agora
  bool get shouldSendNow {
    if (isSent) return false;
    final now = DateTime.now();
    return now.isAfter(scheduledFor) || 
           now.difference(scheduledFor).abs().inMinutes < 5;
  }

  /// Regra de negócio: tempo até o envio
  Duration get timeUntilScheduled {
    return scheduledFor.difference(DateTime.now());
  }

  /// Marca notificação como enviada
  Notification markAsSent() {
    if (isSent) {
      throw StateError('Notification already sent');
    }
    return Notification(
      id: id,
      deadlineId: deadlineId,
      userId: userId,
      title: title,
      body: body,
      scheduledFor: scheduledFor,
      isSent: true,
      sentAt: DateTime.now(),
      priority: priority,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Notification(id: $id, title: $title, isSent: $isSent)';
}

/// Enum para prioridade de notificação
enum NotificationPriority {
  low,
  medium,
  high,
  urgent;

  String get value => name;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (p) => p.name == value.toLowerCase(),
      orElse: () => NotificationPriority.medium,
    );
  }
}
