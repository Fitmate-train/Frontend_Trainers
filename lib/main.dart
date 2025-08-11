// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

// ====== 스크린 임포트 ======
// 실제 파일 경로/이름에 맞게 수정해줘.
import 'login.dart'; // 로그인

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kakao SDK 초기화 (키는 본인 앱 키로 교체)
  KakaoSdk.init(
    nativeAppKey: 'dffe940431e8285758476bbe7217c04e',
    javaScriptAppKey:
        '45f011c401b4fb7e681e48c49055b79a', // 웹 뷰/계정로그인 쓸 때 편의상 추가
  );

  // 로케일 초기화
  await initializeDateFormatting('ko_KR', null);
  Intl.defaultLocale = 'ko_KR';

  runApp(const FitMateTrainerApp());
}

class FitMateTrainerApp extends StatelessWidget {
  const FitMateTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMate Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A68A)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),

      // 최초 진입 화면
      initialRoute: '/',

      // 정적 라우트 매핑
      routes: {'/login': (context) => const LoginScreen()},

      // 동적 라우트(인자 전달 등) 처리
      /*  onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/request_detail':
            final requestId =
                settings.arguments as String?; // ex) 'REQ-2025-0001'
            return MaterialPageRoute(
              builder:
                  (_) => RequestDetailScreen(requestId: requestId ?? 'unknown'),
              settings: settings,
            );

          // 필요 시 케이스 추가...
          default:
            // 알 수 없는 라우트 처리 (404 대용)
            return MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Unknown route: ${settings.name}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              settings: settings, */
      //   );
      //   }
      //  },
    );
  }
}
