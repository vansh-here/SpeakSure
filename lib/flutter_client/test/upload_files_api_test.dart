import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for UploadFilesApi
void main() {
  final instance = Openapi().getUploadFilesApi();

  group(UploadFilesApi, () {
    // Upload Resume
    //
    //Future<JsonObject> uploadResumeUploadResumePost(MultipartFile file) async
    test('test uploadResumeUploadResumePost', () async {
      // TODO
    });

  });
}
