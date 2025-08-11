// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';

/// 앱 공용 하단 네비게이션바
/// - [currentIndex] : 현재 선택된 탭 인덱스
/// - [onTap]        : 탭 선택 시 호출되는 콜백
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
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
