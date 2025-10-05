import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DetailsApi
void main() {
  final instance = Openapi().getDetailsApi();

  group(DetailsApi, () {
    // Get Interview Status
    //
    //Future<JsonObject> getInterviewStatusDetailsGet(String conversationId) async
    test('test getInterviewStatusDetailsGet', () async {
      // TODO
    });

  });
}
