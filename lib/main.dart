// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: 'dffe940431e8285758476bbe7217c04e',
    javaScriptAppKey: '45f011c401b4fb7e681e48c49055b79a',
  );
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
      home: const LoginScreen(), // ✅ 첫 화면
    );
  }
}

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
 