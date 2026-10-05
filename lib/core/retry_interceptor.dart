import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxAttempts;
  final Duration baseDelay;

  RetryInterceptor({
    required this.dio,
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 400),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final method = options.method.toUpperCase();

    final isRetryableMethod = method == 'GET';
    final isRetryableError =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;

    if (!isRetryableMethod || !isRetryableError) {
      return handler.next(err);
    }

    final attempt = (options.extra['retryAttempt'] as int?) ?? 0;
    if (attempt >= maxAttempts) {
      if (kDebugMode) {
        debugPrint('[RETRY] сдался после $attempt попыток: ${options.uri}');
      }
      return handler.next(err);
    }

    options.extra['retryAttempt'] = attempt + 1;
    final delay = baseDelay * (1 << attempt);

    if (kDebugMode) {
      debugPrint(
        '[RETRY] попытка ${attempt + 1} через ${delay.inMilliseconds}мс: ${options.uri}',
      );
    }

    await Future.delayed(delay);

    try {
      final response = await dio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
