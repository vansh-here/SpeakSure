# openapi.api.DetailsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getInterviewStatusDetailsGet**](DetailsApi.md#getinterviewstatusdetailsget) | **GET** /Details/ | Get Interview Status


# **getInterviewStatusDetailsGet**
> JsonObject getInterviewStatusDetailsGet(conversationId)

Get Interview Status

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDetailsApi();
final String conversationId = conversationId_example; // String | 

try {
    final response = api.getInterviewStatusDetailsGet(conversationId);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DetailsApi->getInterviewStatusDetailsGet: $e\n');
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

