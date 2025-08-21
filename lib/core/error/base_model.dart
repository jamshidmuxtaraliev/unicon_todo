//============================================================================================

class BaseData<T> {
  final bool error;
  final String? message;
  final int? error_code;
  final T? data;

  BaseData({required this.error, this.message, this.error_code, this.data});

  factory BaseData.fromJson(Map<String, dynamic> json, T Function(Object? json)? fromJsonT) {
    final isError = json['error'] as bool? ?? true;

    return BaseData<T>(
      error: isError,
      message: json['message'] as String?,
      error_code: json['errorCode'] as int?,
      data: (!isError && fromJsonT != null && json['data'] != null) ? fromJsonT(json['data']) : null,
    );
  }
}
