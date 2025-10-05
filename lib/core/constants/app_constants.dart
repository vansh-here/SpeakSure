class AppConstants {
  // App Information
  static const String appName = 'Speak Sure';
  static const String appVersion = '1.0.0';

  // Base URL
  static const String baseUrl = 'http://13.126.11.187:8000';

  // API Endpoints (FastAPI)
  static const String healthCheck = '/';
  static const String createUser = '/user';
  static const String uploadResume = '/upload_resume';
  static const String startInterview = '/Interview/start';
  static const String provideAnswer = '/Interview/{conversation_id}/answer';
  static const String getAudio = '/Interview/{conversation_id}/audio';
  static const String getCurrentQuestion = '/Interview/{conversation_id}/question';
  static const String getAnalytics = '/Analytics/';
  static const String getInterviewStatus = '/Details/';
  static const String getRoundWiseReport = '/RoundWiseReport/{round_number}';

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String interviewHistoryKey = 'interview_history';
  static const String settingsKey = 'app_settings';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // File Upload
  static const List<String> allowedFileTypes = ['.pdf', '.doc', '.docx'];
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB

  // Interview Settings
  static const int maxQuestionsPerSession = 20;
  static const int minQuestionsPerSession = 5;
  static const Duration questionTimeout = Duration(minutes: 3);
}
