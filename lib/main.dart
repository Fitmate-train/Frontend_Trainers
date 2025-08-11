import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:my_project_name/screens/lesson_chat_screen.dart';
import 'package:my_project_name/screens/lesson_detail_screen.dart';
import 'package:my_project_name/screens/lesson_explore_screen.dart';

import 'screens/home_screen.dart';
import 'screens/received_requests_screen.dart';
import 'login.dart'; // 기존 로그인 화면(그대로 사용)

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

class _Stub extends StatelessWidget {
  final String title;
  const _Stub(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('$title 화면(준비중)')),
  );
}

class FitMateTrainerApp extends StatelessWidget {
  const FitMateTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitMate Trainer',
      debugShowCheckedModeBanner: false,

      // home과 routes['/']를 동시에 쓰지 않기 위해 initialRoute 사용
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/requests': (context) => const ReceivedRequestsScreen(),

        '/profile': (context) => const _Stub('프로필'),
        '/location_edit': (context) => const _Stub('동네 수정'),
        '/lesson_explore': (context) => const LessonExploreScreen(),
        '/lesson_detail': (context) => LessonDetailScreen(),
        '/lesson_chat': (context) => LessonChatScreen(),
      },

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
    );
  }
}
