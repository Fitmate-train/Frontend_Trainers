import 'dart:async';
import '../models/lesson_request.dart';

class RequestService {
  Future<List<LessonRequest>> fetch({
    String? service,
    bool onlyUnread = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 느낌

    final data = <LessonRequest>[
      LessonRequest(
        id: 'REQ-1001',
        studentName: '김민지',
        service: 'PT',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        memo: '주 2회 오전 위주 원해요',
        unread: true,
        price: 50000,
      ),
      LessonRequest(
        id: 'REQ-1000',
        studentName: '박서준',
        service: '필라테스',
        requestedAt: DateTime.now().subtract(const Duration(hours: 5)),
        memo: '허리 재활 목적',
        unread: false,
        price: 60000,
      ),
    ];

    var list = data;
    if (service != null && service.isNotEmpty) {
      list = list.where((e) => e.service == service).toList();
    }
    if (onlyUnread) list = list.where((e) => e.unread).toList();
    list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return list;
  }
}
