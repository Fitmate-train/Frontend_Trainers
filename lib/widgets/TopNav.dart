// lib/widgets/TopNav.dart
import 'package:flutter/material.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onProfilePressed;

  /// 스크롤 감지용 컨트롤러 (권장)
  final ScrollController? scrollController;

  /// 필요 시 강제로 지정할 스크롤 색 (null이면 BottomNav 색 따라감)
  final Color? scrolledColorOverride;

  const TopNav({
    super.key,
    required this.isLoggedIn,
    this.onLoginPressed,
    this.onLogoutPressed,
    this.onProfilePressed,
    this.scrollController,
    this.scrolledColorOverride,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool _isScrolled(ScrollController? c) =>
      c != null && c.hasClients && c.offset > 0.5;

  @override
  Widget build(BuildContext context) {
    final ctrl = scrollController ?? PrimaryScrollController.maybeOf(context);

    // ✅ BottomNav( NavigationBar )가 쓰는 배경색을 그대로 사용
    final bottomNavBg =
        scrolledColorOverride ??
        NavigationBarTheme.of(context).backgroundColor ??
        Theme.of(context).colorScheme.surface;

    Widget buildAppBar(bool scrolled) {
      return AppBar(
        backgroundColor: scrolled ? bottomNavBg : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        title: InkWell(
          onTap: () => Navigator.pushNamed(context, '/'),
          child: SizedBox(
            height: 80,
            child: Image.asset(
              'assets/logo.jpg',
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const Text(
                    'Fitmate',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: Text(isLoggedIn ? '로그아웃' : '로그인'),
            onPressed: () {
              if (isLoggedIn) {
                onLogoutPressed?.call();
              } else {
                if (onLoginPressed != null) {
                  onLoginPressed!();
                } else {
                  final current = ModalRoute.of(context)?.settings.name;
                  if (current != '/login') {
                    Navigator.of(context).pushNamed('/login');
                  }
                }
              }
            },
          ),
          IconButton(
            onPressed: onProfilePressed,
            icon: const Icon(Icons.person_outline),
            tooltip: '마이페이지',
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    // 컨트롤러 없으면(감지 불가) 항상 투명
    if (ctrl == null) return buildAppBar(false);

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => buildAppBar(_isScrolled(ctrl)),
    );
  }
}
