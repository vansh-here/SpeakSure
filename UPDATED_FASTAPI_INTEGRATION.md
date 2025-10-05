# SpeakSure FastAPI Integration - Updated

This document outlines the updated integration of the SpeakSure Flutter app with the actual FastAPI backend at `http://13.126.11.187:8000`.

## Overview

The app has been updated to match the actual FastAPI backend structure, which has a different workflow than traditional authentication systems.

## Actual API Endpoints

Based on the FastAPI documentation at `http://13.126.11.187:8000/docs`, the backend provides:

### Core Endpoints
- `GET /` - Health Check
- `POST /user` - Create User
- `POST /upload_resume` - Upload Resume

### Interview Endpoints
- `POST /Interview/start` - Start Interview
- `POST /Interview/{conversation_id}/answer` - Provide Answer
- `GET /Interview/{conversation_id}/audio` - Get Audio

### Analytics & Reports
- `GET /Analytics/` - Get User Analytics
- `GET /Details/` - Get Interview Status
- `GET /RoundWiseReport/{round_number}` - Get Round Wise Report

## Key Differences from Traditional Auth

1. **No Login/Register**: The backend doesn't have traditional authentication endpoints
2. **User Creation**: Users are created via `POST /user` endpoint
3. **No JWT Tokens**: Authentication is handled differently (likely session-based)
4. **Conversation-based**: Interviews use conversation IDs instead of session IDs
5. **Round-wise Reports**: Reports are generated per round, not per interview

## Updated Architecture

### API Models (`lib/data/models/api_models.dart`)

#### Request Models
- `CreateUserRequest`: For user creation
- `UploadResumeRequest`: For resume upload
- `StartInterviewRequest`: For starting interviews
- `ProvideAnswerRequest`: For answering questions

#### Response Models
- `CreateUserResponse`: User creation response
- `StartInterviewResponse`: Interview start response
- `ProvideAnswerResponse`: Answer submission response
- `UserAnalyticsResponse`: User analytics data
- `InterviewStatusResponse`: Interview status information
- `RoundWiseReportResponse`: Round-wise report data

### Services (`lib/core/services/`)

#### AuthService
- `createUser()`: Create new user
- `uploadResume()`: Upload user resume
- `getUserAnalytics()`: Get user analytics
- `logout()`: Clear local data

#### InterviewService
- `startInterview()`: Start new interview
- `provideAnswer()`: Submit answer to question
- `getInterviewAudio()`: Get interview audio
- `getInterviewStatus()`: Get interview status
- `getRoundWiseReport()`: Get round-wise report
- `getUserAnalytics()`: Get user analytics

#### ReportService
- `getUserAnalytics()`: Get user analytics
- `getInterviewStatus()`: Get interview status
- `getRoundWiseReport()`: Get specific round report
- `getAllRoundWiseReports()`: Get all round reports

### State Management (`lib/presentation/providers/`)

#### AuthProvider
- Manages user creation and authentication state
- Handles resume upload
- Provides user analytics
- No traditional login/logout flow

#### InterviewProvider
- Manages interview sessions using conversation IDs
- Handles answer submission
- Manages interview status
- Provides round-wise reports

#### ReportProvider
- Manages user analytics
- Handles round-wise reports
- Provides interview status information

## Updated Workflow

### 1. User Onboarding
1. User lands on the app
2. User creates account via `POST /user`
3. User uploads resume via `POST /upload_resume`
4. User is ready to start interviews

### 2. Interview Process
1. User starts interview via `POST /Interview/start`
2. System returns conversation ID and first question
3. User answers questions via `POST /Interview/{conversation_id}/answer`
4. System provides next question or completion status
5. User can get interview status via `GET /Details/`

### 3. Analytics & Reports
1. User can view analytics via `GET /Analytics/`
2. User can get round-wise reports via `GET /RoundWiseReport/{round_number}`
3. Reports provide detailed analysis per round

## Updated UI Components

### Landing Page
- Updated to show the new workflow
- Removed traditional login/register buttons
- Added user creation flow

### User Creation Page
- Form for user details (name, email, age, goal)
- Resume upload functionality
- Direct integration with `POST /user` endpoint

### Dashboard
- Shows user analytics from `GET /Analytics/`
- Displays interview status from `GET /Details/`
- Provides access to round-wise reports

### Interview Pages
- Updated to use conversation IDs
- Integrated with `POST /Interview/start`
- Answer submission via `POST /Interview/{conversation_id}/answer`
- Audio support via `GET /Interview/{conversation_id}/audio`

## Configuration

### API Base URL
```dart
const envBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://13.126.11.187:8000');
```

### Endpoint Mapping
- User creation: `POST /user`
- Resume upload: `POST /upload_resume`
- Interview start: `POST /Interview/start`
- Answer submission: `POST /Interview/{conversation_id}/answer`
- Audio retrieval: `GET /Interview/{conversation_id}/audio`
- Analytics: `GET /Analytics/`
- Interview status: `GET /Details/`
- Round reports: `GET /RoundWiseReport/{round_number}`

## Error Handling

The app includes comprehensive error handling for:
- Network connectivity issues
- API endpoint errors
- Data validation errors
- File upload errors
- Interview session errors

## Testing the Integration

### Prerequisites
1. FastAPI backend running at `http://13.126.11.187:8000`
2. Flutter app dependencies installed
3. Device/emulator with internet connectivity

### Test Scenarios
1. **User Creation**: Create new user account
2. **Resume Upload**: Upload user resume
3. **Start Interview**: Begin new interview session
4. **Answer Questions**: Submit answers to interview questions
5. **Get Analytics**: View user analytics
6. **Get Reports**: View round-wise reports
7. **Get Status**: Check interview status

## API Documentation

The FastAPI backend provides interactive documentation:
- **Swagger UI**: http://13.126.11.187:8000/docs
- **ReDoc**: http://13.126.11.187:8000/redoc

## Key Features

### User Management
- User creation without traditional authentication
- Resume upload functionality
- User analytics and insights

### Interview System
- Conversation-based interview sessions
- Real-time question answering
- Audio support for interviews
- Round-wise progress tracking

### Analytics & Reporting
- User performance analytics
- Round-wise detailed reports
- Interview status tracking
- Performance metrics

## Security Considerations

- No traditional JWT authentication
- Session-based or stateless authentication
- Secure file upload handling
- Data validation on both client and server

## Performance Optimizations

- Efficient API call management
- Proper error handling and retry logic
- Optimized data structures
- Efficient state management
- Memory management for large datasets

## Conclusion

The SpeakSure Flutter app has been successfully updated to integrate with the actual FastAPI backend structure. The integration provides a complete interview practice platform with user management, interview sessions, and detailed analytics and reporting capabilities.

The updated architecture follows the backend's conversation-based approach and provides a seamless user experience for interview practice and performance tracking.

