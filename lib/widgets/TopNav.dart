import 'package:flutter/material.dart';

class TopNav extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onLogoutPressed;
  final VoidCallback? onProfilePressed;

  const TopNav({
    super.key,
    required this.isLoggedIn,
    this.onLoginPressed,
    this.onLogoutPressed,
    this.onProfilePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: const Text(
        'FitMateTrainer',
        style: TextStyle(color: Colors.black),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          child: Text(isLoggedIn ? '로그아웃' : '로그인'),
          onPressed: () {
            if (isLoggedIn) {
              onLogoutPressed?.call();
            } else {
              // 콜백이 있으면 그거 호출, 없으면 기본으로 /login 이동
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
          color: Colors.black,
          tooltip: '마이페이지',
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
