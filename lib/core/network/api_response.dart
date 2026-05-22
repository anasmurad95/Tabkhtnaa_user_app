class ApiResponse<T> {
  final bool status;
  final int errorCode;
  final String? errorMsg;
  final T? data;
  final Map<String, dynamic>? raw;

  const ApiResponse({
    required this.status,
    this.errorCode = 0,
    this.errorMsg,
    this.data,
    this.raw,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic value)? parser,
  }) {
    final ok = json['status'] == true;
    dynamic payload = json['data'];
    T? parsed;
    if (ok && parser != null && payload != null) {
      parsed = parser(payload);
    } else if (ok && payload is T) {
      parsed = payload;
    }
    return ApiResponse(
      status: ok,
      errorCode: json['error_code'] is int ? json['error_code'] as int : -1,
      errorMsg: json['error_msg']?.toString(),
      data: parsed ?? (ok ? payload as T? : null),
      raw: json,
    );
  }
}

class PaginatedList<T> {
  final List<T> items;
  final int? currentPage;
  final int? lastPage;
  final String? nextPageUrl;

  const PaginatedList({
    required this.items,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
  });

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;
}
