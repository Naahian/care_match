enum NotificationType {
  appointmentCreated,
  appointmentCancelled,
  appointmentReminder,
  appointmentCreationFailure,
  paymentFailure,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.seen = false,
    this.appointmentId,
    this.remindAt,
  });
  final String id;
  final NotificationType type;
  final String title, message;
  final DateTime createdAt;
  final bool seen;
  final String? appointmentId;
  final DateTime? remindAt;
  AppNotification copyWith({bool? seen}) => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    createdAt: createdAt,
    seen: seen ?? this.seen,
    appointmentId: appointmentId,
    remindAt: remindAt,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'message': message,
    'created_at': createdAt.toIso8601String(),
    'seen': seen,
    'appointment_id': appointmentId,
    'remind_at': remindAt?.toIso8601String(),
  };
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final id = json['id'],
        type = json['type'],
        title = json['title'],
        message = json['message'],
        date = json['created_at'];
    if ([id, type, title, message, date].any((v) => v is! String) ||
        json['seen'] is! bool ||
        !NotificationType.values.any((t) => t.name == type)) {
      throw const FormatException('Invalid stored notification.');
    }
    final created = DateTime.tryParse(date as String);
    final remind = json['remind_at'] == null
        ? null
        : DateTime.tryParse(json['remind_at'] as String);
    if (created == null || (json['remind_at'] != null && remind == null)) {
      throw const FormatException('Invalid notification date.');
    }
    return AppNotification(
      id: id as String,
      type: NotificationType.values.byName(type as String),
      title: title as String,
      message: message as String,
      createdAt: created,
      seen: json['seen'] as bool,
      appointmentId: json['appointment_id'] as String?,
      remindAt: remind,
    );
  }
}
