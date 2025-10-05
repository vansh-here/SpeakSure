import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/services/report_service.dart';
import '../../data/models/report_model.dart';

// Report state
class ReportState {
  final bool isLoading;
  final List<ReportModel> reports;
  final ReportModel? currentReport;
  final Map<String, dynamic>? analytics;
  final String? error;

  const ReportState({
    this.isLoading = false,
    this.reports = const [],
    this.currentReport,
    this.analytics,
    this.error,
  });

  ReportState copyWith({
    bool? isLoading,
    List<ReportModel>? reports,
    ReportModel? currentReport,
    Map<String, dynamic>? analytics,
    String? error,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      currentReport: currentReport ?? this.currentReport,
      analytics: analytics ?? this.analytics,
      error: error,
    );
  }
}

// Report notifier
class ReportNotifier extends StateNotifier<ReportState> {
  final ReportService _reportService;

  ReportNotifier(this._reportService) : super(const ReportState());

  Future<void> generateReport(String interviewId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Backend doesn't have a generate report endpoint
      // We can only get round-wise reports by round number
      // For now, just get round 1 as an example
      final report = await _reportService.getRoundWiseReport(1);
      
      // Convert to ReportModel format
      final reportModel = ReportModel(
        id: 'report_${report.roundNumber}',
        interviewId: interviewId,
        userId: 'current_user',
        overallScore: report.score,
        categoryScores: [
          CategoryScore(
            category: 'Overall',
            score: report.score,
            description: 'Round ${report.roundNumber} performance',
          ),
        ],
        strengths: report.strengths,
        weaknesses: report.weaknesses,
        recommendations: report.recommendations,
        generatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        isLoading: false,
        reports: [reportModel],
        currentReport: reportModel,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUserReports(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Backend doesn't have an endpoint to get all reports
      // We can only get reports by round number
      // For now, try to get reports for rounds 1-5
      final reportModels = <ReportModel>[];
      
      for (int i = 1; i <= 5; i++) {
        try {
          final report = await _reportService.getRoundWiseReport(i);
          reportModels.add(ReportModel(
            id: 'report_${report.roundNumber}',
            interviewId: 'interview_${report.roundNumber}',
            userId: userId,
            overallScore: report.score,
            categoryScores: [
              CategoryScore(
                category: 'Overall',
                score: report.score,
                description: 'Round ${report.roundNumber} performance',
              ),
            ],
            strengths: report.strengths,
            weaknesses: report.weaknesses,
            recommendations: report.recommendations,
            generatedAt: DateTime.now(),
          ));
        } catch (e) {
          // Round doesn't exist, skip it
          break;
        }
      }
      
      state = state.copyWith(
        isLoading: false,
        reports: reportModels,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadReport(String reportId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Extract round number from report ID
      final roundNumber = int.tryParse(reportId.replaceAll('report_', '')) ?? 1;
      final report = await _reportService.getRoundWiseReport(roundNumber);
      
      // Convert to ReportModel format
      final reportModel = ReportModel(
        id: reportId,
        interviewId: 'interview_$roundNumber',
        userId: 'current_user',
        overallScore: report.score,
        categoryScores: [
          CategoryScore(
            category: 'Overall',
            score: report.score,
            description: 'Round $roundNumber performance',
          ),
        ],
        strengths: report.strengths,
        weaknesses: report.weaknesses,
        recommendations: report.recommendations,
        generatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        isLoading: false,
        currentReport: reportModel,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadAnalytics(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // ReportService doesn't have getUserAnalytics, it's in the repository
      // For now, return empty analytics
      state = state.copyWith(
        isLoading: false,
        analytics: {
          'total_interviews': 0,
          'average_score': 0.0,
          'recent_interviews': [],
          'performance_metrics': {},
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<String> shareReport(String reportId, {String? email}) async {
    try {
      // For now, return a placeholder share URL
      return 'https://speaksure.com/reports/$reportId';
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<List<int>> downloadReportPdf(String reportId) async {
    try {
      // For now, return empty list as PDF download is not implemented
      return [];
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteReport(String reportId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Remove from local list
      final updatedReports = state.reports.where((r) => r.id != reportId).toList();
      state = state.copyWith(
        isLoading: false,
        reports: updatedReports,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentReport() {
    state = state.copyWith(currentReport: null);
  }
}

// Provider
final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final reportService = ref.watch(reportServiceProvider).value;
  if (reportService == null) {
    throw Exception('ReportService not available');
  }
  return ReportNotifier(reportService);
});
