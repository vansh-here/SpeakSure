// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
//
// class InterviewApiService {
//   static const String _baseUrl = 'http://localhost:8000'; // Update with your actual API URL
//
//   // Health Check
//   Future<Map<String, dynamic>> checkHealth() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Health check failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Health check error: $e');
//     }
//   }
//
//   // Create User
//   Future<Map<String, dynamic>> createUser(String name) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/user?name=$name'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to create user: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Create user error: $e');
//     }
//   }
//
//   // Upload Resume
//   Future<Map<String, dynamic>> uploadResume(File resumeFile) async {
//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/upload_resume'),
//       );
//
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'file',
//           resumeFile.path,
//           filename: path.basename(resumeFile.path),
//         ),
//       );
//
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to upload resume: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Upload resume error: $e');
//     }
//   }
//
//   // Start Interview
//   Future<Map<String, dynamic>> startInterview() async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/Interview/start'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to start interview: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Start interview error: $e');
//     }
//   }
//
//   // Submit Answer
//   Future<Map<String, dynamic>> submitAnswer(
//     String conversationId,
//     File audioFile,
//   ) async {
//     try {
//       final request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$_baseUrl/Interview/$conversationId/answer'),
//       );
//
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'audio',
//           audioFile.path,
//           filename: path.basename(audioFile.path),
//         ),
//       );
//
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to submit answer: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Submit answer error: $e');
//     }
//   }
//
//   // Get Analytics
//   Future<Map<String, dynamic>> getAnalytics() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/Analytics/'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to get analytics: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Get analytics error: $e');
//     }
//   }
//
//   // Get Interview Details
//   Future<Map<String, dynamic>> getInterviewDetails(String conversationId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/Details/?conversation_id=$conversationId'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to get interview details: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Get interview details error: $e');
//     }
//   }
//
//   // Get Round Wise Report
//   Future<Map<String, dynamic>> getRoundWiseReport(int roundNumber) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/RoundWiseReport/$roundNumber'),
//         headers: {'Content-Type': 'application/json'},
//       );
//
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         throw Exception('Failed to get round report: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Get round report error: $e');
//     }
//   }
//
//   // Helper method to save audio file temporarily
//   Future<File> saveAudioFile(String audioData) async {
//     try {
//       final directory = await getTemporaryDirectory();
//       final file = File('${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav');
//       await file.writeAsBytes(base64Decode(audioData));
//       return file;
//     } catch (e) {
//       throw Exception('Failed to save audio file: $e');
//     }
//   }
//
//   // Helper method to create audio file from bytes
//   Future<File> createAudioFile(List<int> audioBytes) async {
//     try {
//       final directory = await getTemporaryDirectory();
//       final file = File('${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav');
//       await file.writeAsBytes(audioBytes);
//       return file;
//     } catch (e) {
//       throw Exception('Failed to create audio file: $e');
//     }
//   }
// }
//
