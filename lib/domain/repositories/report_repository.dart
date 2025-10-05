import '../../data/models/report_model.dart';

abstract class ReportRepository {
  Future<ReportModel> generateReport({required String interviewId});
  Future<List<ReportModel>> listReports({required String userId});
}







