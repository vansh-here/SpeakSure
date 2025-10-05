import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for InterviewApi
void main() {
  final instance = Openapi().getInterviewApi();

  group(InterviewApi, () {
    // Get Audio
    //
    //Future<JsonObject> getAudioInterviewConversationIdAudioGet(String conversationId) async
    test('test getAudioInterviewConversationIdAudioGet', () async {
      // TODO
    });

    // Provide Answer
    //
    //Future<JsonObject> provideAnswerInterviewConversationIdAnswerPost(String conversationId, MultipartFile audio) async
    test('test provideAnswerInterviewConversationIdAnswerPost', () async {
      // TODO
    });

    // Start Interview
    //
    //Future<JsonObject> startInterviewInterviewStartPost() async
    test('test startInterviewInterviewStartPost', () async {
      // TODO
    });

  });
}
