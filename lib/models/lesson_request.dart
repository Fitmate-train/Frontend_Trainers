class LessonRequest {
  final String id;
  final String studentName;
  final String service; // 예: PT/필라테스/요가
  final DateTime requestedAt;
  final String? memo;
  final bool unread;
  final int price; // 원화(원)

  LessonRequest({
    required this.id,
    required this.studentName,
    required this.service,
    required this.requestedAt,
    this.memo,
    this.unread = false,
    this.price = 0,
  });
}
