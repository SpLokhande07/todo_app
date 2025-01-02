class BaseResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  BaseResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory BaseResponse.success(T data) {
    return BaseResponse(
      success: true,
      data: data,
      message: 'Success',
    );
  }

  factory BaseResponse.error(String message) {
    return BaseResponse(
      success: false,
      message: message,
    );
  }
}
