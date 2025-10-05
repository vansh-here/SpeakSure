# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createUserUserPost**](DefaultApi.md#createuseruserpost) | **POST** /user | Create User
[**healthCheckGet**](DefaultApi.md#healthcheckget) | **GET** / | Health Check


# **createUserUserPost**
> JsonObject createUserUserPost(name)

Create User

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();
final String name = name_example; // String | 

try {
    final response = api.createUserUserPost(name);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->createUserUserPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **name** | **String**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **healthCheckGet**
> JsonObject healthCheckGet()

Health Check

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getDefaultApi();

try {
    final response = api.healthCheckGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->healthCheckGet: $e\n');
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

