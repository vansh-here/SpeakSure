# openapi.api.RoundWiseReportApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getRoundWiseReportRoundWiseReportRoundNumberGet**](RoundWiseReportApi.md#getroundwisereportroundwisereportroundnumberget) | **GET** /RoundWiseReport/{round_number} | Get Round Wise Report


# **getRoundWiseReportRoundWiseReportRoundNumberGet**
> JsonObject getRoundWiseReportRoundWiseReportRoundNumberGet(roundNumber)

Get Round Wise Report

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getRoundWiseReportApi();
final int roundNumber = 56; // int | 

try {
    final response = api.getRoundWiseReportRoundWiseReportRoundNumberGet(roundNumber);
    print(response);
} catch on DioException (e) {
    print('Exception when calling RoundWiseReportApi->getRoundWiseReportRoundWiseReportRoundNumberGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **roundNumber** | **int**|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

