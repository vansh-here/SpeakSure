import '../../data/models/interview_model.dart';
import '../../data/models/question_model.dart';

abstract class InterviewRepository {
  Future<List<QuestionModel>> fetchQuestions({required String userId});
  Future<InterviewModel> startInterview({required String userId, required List<QuestionModel> questions});
  Future<InterviewModel> submitAnswer({required String interviewId, required AnswerModel answer});
  Future<InterviewModel> completeInterview({required String interviewId});
}








