import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lesson_request.dart';
import '../services/request_service.dart';

class ReceivedRequestsScreen extends StatefulWidget {
  const ReceivedRequestsScreen({super.key});

  @override
  State<ReceivedRequestsScreen> createState() => _ReceivedRequestsScreenState();
}

class _ReceivedRequestsScreenState extends State<ReceivedRequestsScreen> {
  final _svc = RequestService();
  final _services = const ['전체', 'PT', '필라테스', '요가'];

  String _selected = '전체';
  bool _onlyUnread = false;
  bool _loading = true;
  List<LessonRequest> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final service = _selected == '전체' ? null : _selected;
    final list = await _svc.fetch(service: service, onlyUnread: _onlyUnread);
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('M월 d일 (E) a h:mm', 'ko_KR');
    final won = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('받은요청'),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // 상단 "안 읽은 요청 몰아보기"
            _UnreadTile(
              count: _items.where((e) => e.unread).length,
              onTap: () {
                setState(() => _onlyUnread = !_onlyUnread);
                _load();
              },
              active: _onlyUnread,
            ),

            const SizedBox(height: 12),

            // 필터 바
            Row(
              children: [
                PopupMenuButton<String>(
                  initialValue: _selected,
                  onSelected: (v) {
                    setState(() => _selected = v);
                    _load();
                  },
                  itemBuilder:
                      (_) =>
                          _services
                              .map(
                                (s) => PopupMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                  child: Chip(label: Text('서비스 선택: $_selected')),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('지정요청'),
                  selected: false,
                  onSelected: (_) {}, // TODO: 지정요청 로직
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              _EmptyBox(onGuide: () {}, onNew: _load)
            else
              ..._items.map(
                (e) => _RequestCard(
                  req: e,
                  subtitle: e.memo ?? '메모 없음',
                  df: df,
                  priceText: won.format(e.price),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${e.id} 상세로 이동(예정)')),
                    );
                  },
                  onAccept: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${e.studentName} 수락')),
                    );
                  },
                  onDecline: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${e.studentName} 거절')),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      ),
    );
  }
}

class _UnreadTile extends StatelessWidget {
  final int count;
  final bool active;
  final VoidCallback onTap;
  const _UnreadTile({
    required this.count,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F7);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.markunread_mailbox_outlined),
            const SizedBox(width: 8),
            const Text('안 읽은 요청 몰아보기'),
            const Spacer(),
            Text(
              '$count건',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final LessonRequest req;
  final String subtitle;
  final DateFormat df;
  final String priceText;
  final VoidCallback onTap, onAccept, onDecline;

  const _RequestCard({
    required this.req,
    required this.subtitle,
    required this.df,
    required this.priceText,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(req.studentName.characters.first)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${req.service} · ${df.format(req.requestedAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (req.unread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '새 요청',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    priceText,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  OutlinedButton(onPressed: onDecline, child: const Text('거절')),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: onAccept, child: const Text('수락')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final VoidCallback onGuide;
  final VoidCallback onNew;
  const _EmptyBox({required this.onGuide, required this.onNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.mail_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            '아직 받은 요청이 없어요',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            '고객의 요청을 기다리는 동안 숨고 사용법을 확인해 보세요',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onGuide, child: const Text('숨고 사용법')),
          const SizedBox(height: 8),
          FilledButton(onPressed: onNew, child: const Text('새로고침')),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
        NavigationDestination(icon: Icon(Icons.inbox_outlined), label: '받은요청'),
        NavigationDestination(
          icon: Icon(Icons.note_alt_outlined),
          label: '바로견적',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          label: '채팅',
        ),
        NavigationDestination(icon: Icon(Icons.person_outline), label: '프로필'),
      ],
    );
  }
}
