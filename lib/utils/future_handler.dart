import 'dart:io';
import 'package:dio/dio.dart';
import '../models/base_error.dart';

class FutureHandler {
  static String getErrorMessage(dynamic error) {
    if (error is BaseError) {
      return error.message;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.sendTimeout:
          return 'Request timed out while sending data. Please try again.';
        case DioExceptionType.receiveTimeout:
          return 'Request timed out while receiving data. Please try again.';
        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case 400:
              return 'Invalid request. Please check your input.';
            case 401:
              return 'Unauthorized access. Please login again.';
            case 403:
              return 'Access forbidden. You don\'t have permission for this action.';
            case 404:
              return 'The requested resource was not found.';
            case 500:
              return 'Server error occurred. Please try again later.';
            default:
              return 'Server error (${error.response?.statusCode}). Please try again.';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled. Please try again.';
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return 'No internet connection. Please check your network.';
          }
          return 'An unexpected error occurred. Please try again.';
        default:
          return 'Network error occurred. Please try again.';
      }
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }

    if (error is FormatException) {
      return 'Invalid data format received from server.';
    }

    if (error is TypeError) {
      return 'Data processing error. Please try again.';
    }

    return error?.toString() ?? 'An unexpected error occurred.';
  }

  static Future<T> handle<T>(Future<T> Function() future) async {
    try {
      return await future();
    } catch (e) {
      throw BaseError(
        message: getErrorMessage(e),
        originalError: e,
        statusCode: e is DioException ? e.response?.statusCode : null,
      );
    }
  }
}
