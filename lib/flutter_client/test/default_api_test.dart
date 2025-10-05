import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DefaultApi
void main() {
  final instance = Openapi().getDefaultApi();

  group(DefaultApi, () {
    // Create User
    //
    //Future<JsonObject> createUserUserPost(String name) async
    test('test createUserUserPost', () async {
      // TODO
    });

    // Health Check
    //
    //Future<JsonObject> healthCheckGet() async
    test('test healthCheckGet', () async {
      // TODO
    });

  });
}
