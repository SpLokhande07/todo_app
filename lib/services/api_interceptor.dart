import 'package:dio/dio.dart';
import '../models/base_error.dart';
import '../utils/future_handler.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    options.extra['timestamp'] = DateTime.now().millisecondsSinceEpoch;

    print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestTime = response.requestOptions.extra['timestamp'] as int?;
    final responseTime = DateTime.now().millisecondsSinceEpoch;

    if (requestTime != null) {
      print('⏱️ Request took ${responseTime - requestTime}ms');
    }

    print(
        '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');

    // Transform error to BaseError with meaningful message
    final error = BaseError(
      message: FutureHandler.getErrorMessage(err),
      statusCode: err.response?.statusCode,
      originalError: err,
    );

    // Create a new error response
    final errorResponse = Response(
      requestOptions: err.requestOptions,
      statusCode: err.response?.statusCode ?? 500,
      data: {
        'error': error.message,
        'statusCode': error.statusCode,
      },
    );

    // Return modified error response
    handler.resolve(errorResponse);
  }
}
