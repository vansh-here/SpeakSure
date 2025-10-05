import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/di/providers.dart';
import 'presentation/pages/landing_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/interview_start_page.dart';
import 'presentation/pages/web_interview_page.dart';
import 'presentation/pages/report_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => prefs),
    ],
    child: const SpeakSureApp(),
  ));
}

class SpeakSureApp extends StatelessWidget {
  const SpeakSureApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure providers (config, api, repositories) are created
    // ignore: unused_local_variable
    final config = ProviderScope.containerOf(context, listen: false).read(appConfigProvider);
    return MaterialApp.router(
      title: 'Speak Sure',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/interview-start',
      builder: (context, state) => const InterviewStartPage(),
    ),
    GoRoute(
      path: '/interview',
      builder: (context, state) => const WebInterviewPage(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => ReportPage(
        conversationId: state.uri.queryParameters['conversation_id'],
      ),
    ),
  ],
);
