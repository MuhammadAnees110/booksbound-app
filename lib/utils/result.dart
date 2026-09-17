enum ResultStatus {
  success(200),
  created(201),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  paymentRequired(402),
  forbidden(403),
  notFound(404),
  methodNotAllowed(405),
  conflict(409),
  gone(410),
  unprocessable(422),
  rateLimited(429),
  networkError(0),
  serverError(500),
  notImplemented(501),
  badGateway(502),
  serviceUnavailable(503),
  gatewayTimeout(504),
  unknown(999);

  final int code;
  const ResultStatus(this.code);
}

class Result<T> {
  final ResultStatus status;
  final String message;
  final T? data;
  final int? statusCode;

  const Result({
    required this.status,
    this.message = '',
    this.data,
    this.statusCode,
  });

  bool get isSuccess =>
      status == ResultStatus.success ||
      status == ResultStatus.created ||
      status == ResultStatus.noContent;

  factory Result.success(T data, [String? message]) {
    return Result<T>(
      status: ResultStatus.success,
      data: data,
      message: message ?? 'Success',
      statusCode: ResultStatus.success.code,
    );
  }

  factory Result.created(T data, [String? message]) {
    return Result<T>(
      status: ResultStatus.created,
      data: data,
      message: message ?? 'Created',
      statusCode: ResultStatus.created.code,
    );
  }

  factory Result.noContent([String? message]) {
    return Result<T>(
      status: ResultStatus.noContent,
      data: null,
      message: message ?? 'No Content',
      statusCode: ResultStatus.noContent.code,
    );
  }

  factory Result.error(
    ResultStatus status,
    String message, [
    int? statusCode,
  ]) {
    return Result<T>(
      status: status,
      data: null,
      message: message,
      statusCode: statusCode ?? status.code,
    );
  }
}
