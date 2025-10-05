# openapi.api.UploadFilesApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**uploadResumeUploadResumePost**](UploadFilesApi.md#uploadresumeuploadresumepost) | **POST** /upload_resume | Upload Resume


# **uploadResumeUploadResumePost**
> JsonObject uploadResumeUploadResumePost(file)

Upload Resume

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUploadFilesApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | 

try {
    final response = api.uploadResumeUploadResumePost(file);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UploadFilesApi->uploadResumeUploadResumePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

