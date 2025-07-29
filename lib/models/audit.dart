class AuditEvent {
  final int eventId;
  final String time;
  final String eventType;
  final String refId;

  AuditEvent({
    required this.eventId,
    required this.time,
    required this.eventType,
    required this.refId,
  });

  factory AuditEvent.fromMap(Map<String, dynamic> map) {
    return AuditEvent(
      eventId: map['EventID'],
      time: map['Time'],
      eventType: map['EventType'],
      refId: map['RefID'],
    );
  }
}
