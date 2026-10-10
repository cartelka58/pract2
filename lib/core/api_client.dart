import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exceptions.dart';
import 'config.dart';
import 'retry_interceptor.dart';

Dio buildDio({
  String? Function()? tokenProvider,
  Future<void> Function()? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: apiConnectTimeout,
      receiveTimeout: apiReceiveTimeout,
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.addAll([
    RetryInterceptor(dio: dio),
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = tokenProvider?.call();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('[API] → ${options.method} ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
            '[API] ← ${response.statusCode} ${response.requestOptions.uri}',
          );
        }
        final status = response.statusCode ?? 0;
        if (status >= 400) {
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: mapHttpError(status, response.data),
            ),
            true,
          );
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('[API] ✗ ${error.requestOptions.uri}: ${error.type}');
        }

        final status = error.response?.statusCode;
        final path = error.requestOptions.path;

        if (status == 401 &&
            onUnauthorized != null &&
            !path.contains('/auth/')) {
          try {
            await onUnauthorized();
            final options = error.requestOptions;
            options.headers['Authorization'] =
                'Bearer ${tokenProvider?.call()}';
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (_) {
            // не удалось обновить — идём дальше
          }
        }

        return handler.next(error);
      },
    ),
  ]);

  return dio;
}
