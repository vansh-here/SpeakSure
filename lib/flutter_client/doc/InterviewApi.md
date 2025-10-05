# openapi.api.InterviewApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAudioInterviewConversationIdAudioGet**](InterviewApi.md#getaudiointerviewconversationidaudioget) | **GET** /Interview/{conversation_id}/audio | Get Audio
[**provideAnswerInterviewConversationIdAnswerPost**](InterviewApi.md#provideanswerinterviewconversationidanswerpost) | **POST** /Interview/{conversation_id}/answer | Provide Answer
[**startInterviewInterviewStartPost**](InterviewApi.md#startinterviewinterviewstartpost) | **POST** /Interview/start | Start Interview


# **getAudioInterviewConversationIdAudioGet**
> JsonObject getAudioInterviewConversationIdAudioGet(conversationId)

Get Audio

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInterviewApi();
final String conversationId = conversationId_example; // String | 

try {
    final response = api.getAudioInterviewConversationIdAudioGet(conversationId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InterviewApi->getAudioInterviewConversationIdAudioGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **provideAnswerInterviewConversationIdAnswerPost**
> JsonObject provideAnswerInterviewConversationIdAnswerPost(conversationId, audio)

Provide Answer

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInterviewApi();
final String conversationId = conversationId_example; // String | 
final MultipartFile audio = BINARY_DATA_HERE; // MultipartFile | 

try {
    final response = api.provideAnswerInterviewConversationIdAnswerPost(conversationId, audio);
    print(response);
} catch on DioException (e) {
    print('Exception when calling InterviewApi->provideAnswerInterviewConversationIdAnswerPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **conversationId** | **String**|  | 
 **audio** | **MultipartFile**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startInterviewInterviewStartPost**
> JsonObject startInterviewInterviewStartPost()

Start Interview

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getInterviewApi();

try {
    final response = api.startInterviewInterviewStartPost();
    print(response);
} catch on DioException (e) {
    print('Exception when calling InterviewApi->startInterviewInterviewStartPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

