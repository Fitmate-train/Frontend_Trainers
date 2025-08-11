// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'screens/home_screen.dart';
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

      // ✅ 집 하나만: 추천은 home 사용
      home: const HomeScreen(),

      // ✅ 네임드 라우트 테이블
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(), // 안전망
      },

      // ❌ 아래 onGenerateRoute 주석 블록/중복 MaterialApp은 전부 삭제
    );
  }
}
