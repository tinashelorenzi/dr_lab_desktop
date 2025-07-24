/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  /// Create a successful response
  factory ApiResponse.success(T data, [String? message]) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
    );
  }

  /// Create an error response
  factory ApiResponse.error(String message, [Map<String, dynamic>? errors]) {
    return ApiResponse._(
      success: false,
      message: message,
      errors: errors,
    );
  }

  /// Check if the response is successful
  bool get isSuccess => success;

  /// Check if the response is an error
  bool get isError => !success;

  /// Get the error message
  String get errorMessage => message ?? 'An unknown error occurred';

  @override
  String toString() {
    if (success) {
      return 'ApiResponse.success(data: $data, message: $message)';
    } else {
      return 'ApiResponse.error(message: $message, errors: $errors)';
    }
  }
}