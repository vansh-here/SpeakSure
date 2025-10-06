# SpeakSure FastAPI Integration

This document outlines the complete integration of the SpeakSure Flutter app with the FastAPI backend at `http://13.126.11.187:8000`.

## Overview

The app has been fully integrated with the FastAPI backend, replacing all mock data with real API calls. The integration includes:

- **Authentication System**: Complete login/register flow with JWT tokens
- **Interview Management**: Start, resume, and complete interviews via API
- **Report Generation**: Generate and retrieve detailed interview reports
- **User Management**: Profile management and user data synchronization
- **Error Handling**: Comprehensive error handling for all API operations

## Architecture

### Core Components

1. **API Client** (`lib/core/network/api_client.dart`)
   - Enhanced with authentication interceptors
   - Automatic token refresh
   - Comprehensive error handling
   - Request/response logging

2. **Services** (`lib/core/services/`)
   - `AuthService`: Authentication operations
   - `InterviewService`: Interview management
   - `ReportService`: Report generation and retrieval
   - `QuestionService`: Question management

3. **State Management** (`lib/presentation/providers/`)
   - `AuthProvider`: Authentication state
   - `InterviewProvider`: Interview state
   - `ReportProvider`: Report state

4. **API Models** (`lib/data/models/api_models.dart`)
   - Request/response models matching FastAPI documentation
   - Type-safe API communication

## API Endpoints Integration

### Authentication Endpoints
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `GET /auth/me` - Get current user
- `PUT /auth/profile` - Update user profile
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh JWT token

### Interview Endpoints
- `POST /interview/start` - Start new interview
- `GET /interview/session/{session_id}` - Get interview session
- `POST /interview/answer` - Submit answer
- `POST /interview/session/{session_id}/complete` - Complete interview
- `GET /interview/history/{user_id}` - Get interview history
- `GET /interview/stats/{user_id}` - Get interview statistics
- `POST /interview/session/{session_id}/resume` - Resume interview
- `POST /interview/session/{session_id}/abandon` - Abandon interview

### Report Endpoints
- `POST /report/generate` - Generate report
- `GET /report/{report_id}` - Get report
- `GET /report/{report_id}/status` - Get report status
- `GET /report/user/{user_id}` - Get user reports
- `GET /report/analytics/{user_id}` - Get report analytics
- `GET /report/{report_id}/download` - Download report PDF
- `POST /report/share` - Share report
- `DELETE /report/{report_id}` - Delete report

### Question Endpoints
- `GET /questions/category/{category}` - Get questions by category
- `GET /questions/difficulty/{difficulty}` - Get questions by difficulty
- `GET /questions/random` - Get random questions
- `GET /questions/{question_id}` - Get specific question
- `GET /questions/categories` - Get question categories
- `GET /questions/difficulties` - Get difficulty levels
- `GET /questions/search` - Search questions
- `GET /questions/{question_id}/stats` - Get question statistics

## Configuration

### Environment Variables
The app is configured to use the FastAPI backend by default:

```dart
// lib/core/config/app_config.dart
const envBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://13.126.11.187:8000');
```

### SharedPreferences Integration
The app uses SharedPreferences for:
- Storing JWT tokens
- Storing refresh tokens
- Storing user ID
- Managing authentication state

## Authentication Flow

1. **Login/Register**: User enters credentials
2. **Token Storage**: JWT and refresh tokens stored in SharedPreferences
3. **Automatic Headers**: All API requests include Authorization header
4. **Token Refresh**: Automatic token refresh on 401 responses
5. **Logout**: Clear all stored tokens and redirect to login

## Error Handling

The app includes comprehensive error handling for:

- **Network Errors**: Connection timeouts, network failures
- **HTTP Errors**: 400, 401, 403, 404, 500 status codes
- **API Errors**: Server-side validation errors
- **Authentication Errors**: Token expiration, invalid credentials

## State Management

### Authentication State
```dart
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
}
```

### Interview State
```dart
class InterviewState {
  final bool isLoading;
  final InterviewModel? currentInterview;
  final List<InterviewModel> interviewHistory;
  final QuestionModel? currentQuestion;
  final int currentQuestionIndex;
  final String? error;
}
```

### Report State
```dart
class ReportState {
  final bool isLoading;
  final List<ReportModel> reports;
  final ReportModel? currentReport;
  final Map<String, dynamic>? analytics;
  final String? error;
}
```

## UI Integration

### Updated Pages
- **Landing Page**: Now includes authentication buttons
- **Login Page**: Complete login form with validation
- **Register Page**: Complete registration form with validation
- **Dashboard Page**: Shows user-specific data from API
- **Interview Pages**: Integrated with real interview API
- **Report Pages**: Shows real reports from API

### Navigation
- Authentication-based routing
- Automatic redirects for unauthenticated users
- Protected routes for authenticated users

## Testing the Integration

### Prerequisites
1. FastAPI backend running at `http://13.126.11.187:8000`
2. Flutter app dependencies installed
3. Device/emulator with internet connectivity

### Test Scenarios
1. **User Registration**: Create new account
2. **User Login**: Login with existing credentials
3. **Start Interview**: Begin new interview session
4. **Submit Answers**: Answer interview questions
5. **Generate Report**: Generate interview report
6. **View History**: View past interviews and reports
7. **Logout**: Clear session and redirect to login

## API Documentation

The FastAPI backend provides interactive documentation:
- **Swagger UI**: http://13.126.11.187:8000/docs
- **ReDoc**: http://13.126.11.187:8000/redoc

## Dependencies

### New Dependencies Added
- `shared_preferences: ^2.2.3` - Local storage for tokens
- `dio: ^5.4.3+1` - HTTP client with interceptors
- `flutter_riverpod: ^2.5.1` - State management

### Updated Dependencies
- All existing dependencies maintained
- No breaking changes to existing functionality

## Performance Considerations

### API Call Optimization
- Token refresh handled automatically
- Request/response logging for debugging
- Connection timeouts configured (30 seconds)
- Retry logic for failed requests

### Memory Management
- Proper disposal of controllers and listeners
- State cleanup on logout
- Efficient state updates

## Security Features

### Token Management
- Secure token storage in SharedPreferences
- Automatic token refresh
- Token cleanup on logout
- Authorization headers on all requests

### Data Validation
- Client-side form validation
- Server-side error handling
- Input sanitization
- Type-safe API models

## Future Enhancements

### Planned Features
1. **Offline Support**: Cache data for offline access
2. **Push Notifications**: Report generation notifications
3. **File Upload**: Resume upload functionality
4. **Analytics**: User behavior tracking
5. **Multi-language**: Internationalization support

### API Optimizations
1. **Caching**: Implement response caching
2. **Pagination**: Add pagination for large datasets
3. **Real-time Updates**: WebSocket integration
4. **Batch Operations**: Bulk API operations

## Troubleshooting

### Common Issues
1. **Connection Errors**: Check network connectivity
2. **Authentication Errors**: Verify token validity
3. **API Errors**: Check backend server status
4. **Data Sync Issues**: Refresh app state

### Debug Information
- Enable HTTP logging in `app_config.dart`
- Check console for API request/response logs
- Verify token storage in SharedPreferences
- Test API endpoints directly via Swagger UI

## Conclusion

The SpeakSure Flutter app is now fully integrated with the FastAPI backend, providing a complete interview practice platform with real-time data synchronization, user authentication, and comprehensive reporting capabilities.


