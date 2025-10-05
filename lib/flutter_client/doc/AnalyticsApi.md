# openapi.api.AnalyticsApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getUserAnalyticsAnalyticsGet**](AnalyticsApi.md#getuseranalyticsanalyticsget) | **GET** /Analytics/ | Get User Analytics


# **getUserAnalyticsAnalyticsGet**
> JsonObject getUserAnalyticsAnalyticsGet()

Get User Analytics

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAnalyticsApi();

try {
    final response = api.getUserAnalyticsAnalyticsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling AnalyticsApi->getUserAnalyticsAnalyticsGet: $e\n');
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

