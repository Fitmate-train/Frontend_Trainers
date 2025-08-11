// lib/screens/login.dart
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ 사용자 취소 감지 함수 (전역)
bool _isUserCancelled(Object e) {
  // 카카오 SDK의 취소 사유 체크
  if (e is KakaoAuthException && e.error == AuthErrorCause.accessDenied)
    return true;
  if (e is KakaoApiException && e.code == ApiErrorCause.accessDenied)
    return true;
  // 혹시 문자열만 들어오는 경우도 대비
  final s = e.toString().toLowerCase();
  return s.contains('access_denied') || s.contains('cancel');
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _loginWithKakao() async {
    setState(() => _loading = true);
    try {
      OAuthToken token;
      final installed = await isKakaoTalkInstalled();
      print('Talk installed: $installed');

      if (installed) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('KakaoTalk login OK: ${token.accessToken}');
        } catch (e, st) {
          print('KakaoTalk login error: $e\n$st');
          if (_isUserCancelled(e)) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('로그인이 취소되었어요.')));
            return;
          }
          // 톡 로그인 실패 시 웹 로그인 폴백
          print('Falling back to KakaoAccount (web) login...');
          try {
            token = await UserApi.instance.loginWithKakaoAccount();
            print('KakaoAccount login OK: ${token.accessToken}');
          } catch (e2, st2) {
            print('KakaoAccount login error: $e2\n$st2');
            if (_isUserCancelled(e2)) {
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('로그인이 취소되었어요.')));
              return;
            }
            rethrow;
          }
        }
      } else {
        try {
          token = await UserApi.instance.loginWithKakaoAccount();
          print('KakaoAccount login OK: ${token.accessToken}');
        } catch (e, st) {
          print('KakaoAccount login error: $e\n$st');
          if (_isUserCancelled(e)) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('로그인이 취소되었어요.')));
            return;
          }
          rethrow;
        }
      }

      // ✅ 프로필 정보 동의가 필요한 경우만 추가 스코프 요청
      final me0 = await UserApi.instance.me();
      final needsProfile = me0.kakaoAccount?.profileNeedsAgreement ?? false;

      if (needsProfile) {
        try {
          await UserApi.instance.loginWithNewScopes([
            'profile_nickname',
            'profile_image',
          ]);
          print('추가 스코프 OK');
        } catch (e, st) {
          print('loginWithNewScopes error: $e\n$st');
          if (_isUserCancelled(e)) {
            if (!mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('권한 동의가 취소되었어요.')));
            return;
          }
          rethrow;
        }
      } else {
        print('추가 스코프 불필요');
      }

      // 최종 사용자 정보 조회
      final me = await UserApi.instance.me();
      final nickname = me.kakaoAccount?.profile?.nickname ?? '사용자';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', nickname);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$nickname님 환영해요!')));
    } catch (e, st) {
      print('로그인 처리 중 오류: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kakaoYellow = const Color(0xFFFEE500);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    'FitMate',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text('간편하게 카카오로 로그인하세요'),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _loginWithKakao,
                      icon: const Icon(
                        Icons.chat_bubble,
                        size: 20,
                        color: Colors.black,
                      ),
                      label: Text(
                        _loading ? '로그인 중...' : '카카오로 시작하기',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kakaoYellow,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
