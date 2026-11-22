/// Mirrors the backend's shared error envelope, returned on every non-2xx
/// response: `{"error": "...", "message": "..."}`.
class ApiErrorDto {
  const ApiErrorDto({required this.error, required this.message});

  final String error;
  final String message;

  factory ApiErrorDto.fromJson(Map<String, dynamic> json) => ApiErrorDto(
    error: json['error'] as String? ?? 'Unknown',
    message: json['message'] as String? ?? 'An unknown error occurred.',
  );
}
