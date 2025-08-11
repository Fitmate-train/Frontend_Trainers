// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';

/// 앱 공용 하단 네비게이션바
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == 2) {
          // ✅ 채팅 탭 -> /lesson_chat
          final current = ModalRoute.of(context)?.settings.name;
          if (current != '/chat_collection') {
            Navigator.pushReplacementNamed(context, '/chat_collection');
          }
          return;
        }
        onTap(index); // 그 외 탭은 부모가 처리
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: '홈'),
        NavigationDestination(icon: Icon(Icons.inbox_outlined), label: '받은요청'),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          label: '채팅',
        ),
        NavigationDestination(icon: Icon(Icons.person_outline), label: '프로필'),
      ],
    );
  }
}
