// lib/screens/chat_collection_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:characters/characters.dart';

import '../widgets/TopNav.dart'; // ← 네 프로젝트 경로에 맞게
import '../widgets/BottomNav.dart'; // (혹시 파일명이 bottom_nav.dart라면 그걸로 바꿔줘)

/// 간단한 채팅 스레드 모델 (원하면 별도 파일로 분리)
class ChatThread {
  final String id;
  final String name; // 상대/그룹명
  final String lastMessage; // 마지막 메시지
  final DateTime updatedAt; // 최근 시각
  int unread; // 안 읽음 개수
  bool pinned; // 상단 고정
  final String? avatarUrl;

  ChatThread({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.updatedAt,
    this.unread = 0,
    this.pinned = false,
    this.avatarUrl,
  });
}

class ChatCollectionScreen extends StatefulWidget {
  const ChatCollectionScreen({super.key});

  @override
  State<ChatCollectionScreen> createState() => _ChatCollectionScreenState();
}

class _ChatCollectionScreenState extends State<ChatCollectionScreen> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();

  // 탭/필터 상태 (0 전체, 1 안 읽음, 2 고정됨)
  int _tab = 0;

  // 데모 데이터 (서버 연동 전)
  final List<ChatThread> _all = [
    ChatThread(
      id: 'c1',
      name: '김영희',
      lastMessage: '이번 주 목요일 7시에 가능하실까요?',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      unread: 2,
      pinned: true,
    ),
    ChatThread(
      id: 'c2',
      name: 'PT 6월 반(그룹)',
      lastMessage: '내일은 하체 루틴으로 진행해요!',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      unread: 0,
    ),
    ChatThread(
      id: 'c3',
      name: '이준호',
      lastMessage: '감사합니다! 결제 완료했어요.',
      updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      unread: 0,
    ),
    ChatThread(
      id: 'c4',
      name: '박하늘',
      lastMessage: '견적서 확인 부탁드려요 🙏',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 42)),
      unread: 1,
    ),
  ];

  Future<void> _refresh() async {
    // TODO: 서버에서 목록 갱신
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() {});
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChatThread> _filtered() {
    final q = _searchCtrl.text.trim().toLowerCase();
    Iterable<ChatThread> list = _all;

    if (q.isNotEmpty) {
      list = list.where(
        (e) =>
            e.name.toLowerCase().contains(q) ||
            e.lastMessage.toLowerCase().contains(q),
      );
    }

    if (_tab == 1) {
      list = list.where((e) => e.unread > 0);
    } else if (_tab == 2) {
      list = list.where((e) => e.pinned);
    }

    final sorted =
        list.toList()..sort((a, b) {
          if (a.pinned != b.pinned) return b.pinned ? 1 : -1; // pinned first
          return b.updatedAt.compareTo(a.updatedAt);
        });
    return sorted;
  }

  String _fmtTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return DateFormat('M/d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered();

    return Scaffold(
      appBar: TopNav(
        isLoggedIn: true, // 필요 시 실제 로그인 상태로 연결
        scrollController: _scroll, // 스크롤 시 색 동기화
        onLoginPressed: () => Navigator.pushNamed(context, '/login'),
        onProfilePressed: () => Navigator.pushNamed(context, '/profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            // 검색
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '대화 검색',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F7),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // 탭(전체/안읽음/고정됨)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('전체'),
                      icon: Icon(Icons.forum_outlined),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('안 읽음'),
                      icon: Icon(Icons.mark_unread_chat_alt_outlined),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text('고정됨'),
                      icon: Icon(Icons.push_pin_outlined),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
              ),
            ),

            // 리스트 or 빈 상태
            if (items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('채팅이 없습니다. 새로운 대화를 시작해 보세요.')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final t = items[i];
                  return _ChatTile(
                    thread: t,
                    timeText: _fmtTime(t.updatedAt),
                    onOpen: () {
                      // TODO: 채팅방 화면으로 이동
                      // Navigator.pushNamed(context, '/chat_room', arguments: t);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('채팅방 열기: ${t.name} (준비중)')),
                      );
                      t.unread = 0;
                      setState(() {});
                    },
                    onTogglePin: () {
                      t.pinned = !t.pinned;
                      setState(() {});
                    },
                    onMarkRead: () {
                      t.unread = 0;
                      setState(() {});
                    },
                    onDelete: () {
                      _all.removeWhere((e) => e.id == t.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('대화가 삭제되었어요.')),
                      );
                    },
                  );
                }, childCount: items.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ],
        ),
      ),

      // 새 대화
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/chat_room'),
        label: const Text('새 채팅'),
        icon: const Icon(Icons.chat_bubble_outline),
      ),

      // 하단 네비게이션 (채팅 탭 선택)
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/requests');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

/// 채팅 리스트 아이템
class _ChatTile extends StatelessWidget {
  final ChatThread thread;
  final String timeText;
  final VoidCallback onOpen;
  final VoidCallback onTogglePin;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  const _ChatTile({
    required this.thread,
    required this.timeText,
    required this.onOpen,
    required this.onTogglePin,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE0E0E0),
              foregroundColor: Colors.black87,
              child: Text(thread.name.characters.first),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    thread.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeText,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            subtitle: Text(
              thread.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (thread.unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C4EF6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${thread.unread}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                PopupMenuButton<String>(
                  tooltip: '더보기',
                  onSelected: (v) {
                    switch (v) {
                      case 'pin':
                        onTogglePin();
                        break;
                      case 'read':
                        onMarkRead();
                        break;
                      case 'del':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder:
                      (_) => [
                        PopupMenuItem(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(
                                thread.pinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(thread.pinned ? '고정 해제' : '상단 고정'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_chat_read_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('읽은 상태로 표시'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'del',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18),
                              SizedBox(width: 8),
                              Text('대화 삭제'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
