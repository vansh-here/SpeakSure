// Test script to verify FastAPI integration
// Run this with: dart test_api_integration.dart

import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing SpeakSure FastAPI Integration');
  print('=====================================\n');

  const baseUrl = 'http://13.126.11.187:8000';
  
  // Test 1: Health Check
  await testHealthCheck(baseUrl);
  
  // Test 2: API Documentation
  await testApiDocumentation(baseUrl);
  
  // Test 3: Authentication Endpoints
  await testAuthEndpoints(baseUrl);
  
  // Test 4: Interview Endpoints
  await testInterviewEndpoints(baseUrl);
  
  // Test 5: Report Endpoints
  await testReportEndpoints(baseUrl);
  
  print('\n✅ API Integration Tests Completed');
}

Future<void> testHealthCheck(String baseUrl) async {
  print('🔍 Testing Health Check...');
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('$baseUrl/health'));
    final response = await request.close();
    
    if (response.statusCode == 200) {
      print('✅ Health check passed');
    } else {
      print('❌ Health check failed: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Health check error: $e');
  }
}

Future<void> testApiDocumentation(String baseUrl) async {
  print('🔍 Testing API Documentation...');
  try {
    final client = HttpClient();
    
    // Test Swagger UI
    final swaggerRequest = await client.getUrl(Uri.parse('$baseUrl/docs'));
    final swaggerResponse = await swaggerRequest.close();
    print('📚 Swagger UI: ${swaggerResponse.statusCode == 200 ? '✅ Available' : '❌ Not available'}');
    
    // Test ReDoc
    final redocRequest = await client.getUrl(Uri.parse('$baseUrl/redoc'));
    final redocResponse = await redocRequest.close();
    print('📖 ReDoc: ${redocResponse.statusCode == 200 ? '✅ Available' : '❌ Not available'}');
    
  } catch (e) {
    print('❌ Documentation test error: $e');
  }
}

Future<void> testAuthEndpoints(String baseUrl) async {
  print('🔍 Testing Authentication Endpoints...');
  try {
    final client = HttpClient();
    
    // Test register endpoint
    final registerRequest = await client.postUrl(Uri.parse('$baseUrl/auth/register'));
    registerRequest.headers.set('Content-Type', 'application/json');
    registerRequest.write(jsonEncode({
      'name': 'Test User',
      'email': 'test@example.com',
      'password': 'testpassword',
      'age': 25,
      'goal': 'Software Engineer'
    }));
    final registerResponse = await registerRequest.close();
    print('📝 Register endpoint: ${registerResponse.statusCode}');
    
    // Test login endpoint
    final loginRequest = await client.postUrl(Uri.parse('$baseUrl/auth/login'));
    loginRequest.headers.set('Content-Type', 'application/json');
    loginRequest.write(jsonEncode({
      'email': 'test@example.com',
      'password': 'testpassword'
    }));
    final loginResponse = await loginRequest.close();
    print('🔑 Login endpoint: ${loginResponse.statusCode}');
    
  } catch (e) {
    print('❌ Auth endpoints test error: $e');
  }
}

Future<void> testInterviewEndpoints(String baseUrl) async {
  print('🔍 Testing Interview Endpoints...');
  try {
    final client = HttpClient();
    
    // Test questions endpoint
    final questionsRequest = await client.getUrl(Uri.parse('$baseUrl/questions/random?limit=5'));
    final questionsResponse = await questionsRequest.close();
    print('❓ Questions endpoint: ${questionsResponse.statusCode}');
    
    // Test categories endpoint
    final categoriesRequest = await client.getUrl(Uri.parse('$baseUrl/questions/categories'));
    final categoriesResponse = await categoriesRequest.close();
    print('📂 Categories endpoint: ${categoriesResponse.statusCode}');
    
  } catch (e) {
    print('❌ Interview endpoints test error: $e');
  }
}

Future<void> testReportEndpoints(String baseUrl) async {
  print('🔍 Testing Report Endpoints...');
  try {
    final client = HttpClient();
    
    // Test report generation endpoint (this might fail without valid interview ID)
    final reportRequest = await client.postUrl(Uri.parse('$baseUrl/report/generate'));
    reportRequest.headers.set('Content-Type', 'application/json');
    reportRequest.write(jsonEncode({
      'interview_id': 'test-interview-id'
    }));
    final reportResponse = await reportRequest.close();
    print('📊 Report generation endpoint: ${reportResponse.statusCode}');
    
  } catch (e) {
    print('❌ Report endpoints test error: $e');
  }
}

