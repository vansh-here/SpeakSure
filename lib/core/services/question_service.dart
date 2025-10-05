import '../network/api_client.dart';
import '../../data/models/question_model.dart';

class QuestionService {
  final ApiClient _apiClient;

  QuestionService(this._apiClient);

  // Get questions by category
  Future<List<QuestionModel>> getQuestionsByCategory(String category) async {
    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/category/$category'),
    );

    return (response as List)
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get questions by difficulty
  Future<List<QuestionModel>> getQuestionsByDifficulty(String difficulty) async {
    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/difficulty/$difficulty'),
    );

    return (response as List)
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get random questions
  Future<List<QuestionModel>> getRandomQuestions({
    int limit = 10,
    String? category,
    String? difficulty,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    if (category != null) query['category'] = category;
    if (difficulty != null) query['difficulty'] = difficulty;

    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/random', query: query),
    );

    return (response as List)
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get question by ID
  Future<QuestionModel> getQuestion(String questionId) async {
    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/$questionId'),
    );

    return QuestionModel.fromJson(response as Map<String, dynamic>);
  }

  // Get question categories
  Future<List<String>> getCategories() async {
    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/categories'),
    );

    return List<String>.from(response as List);
  }

  // Get difficulty levels
  Future<List<String>> getDifficultyLevels() async {
    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/difficulties'),
    );

    return List<String>.from(response as List);
  }

  // Search questions
  Future<List<QuestionModel>> searchQuestions(String query) async {
    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/search', query: {'q': query}),
    );

    return (response as List)
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get question statistics
  Future<Map<String, dynamic>> getQuestionStats(String questionId) async {
    final response = await _apiClient.handleApiCall(
      () => _apiClient.get('/questions/$questionId/stats'),
    );

    return response as Map<String, dynamic>;
  }
}
