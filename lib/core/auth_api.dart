import 'package:dio/dio.dart';

import '../models/models.dart';
import 'api_exceptions.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<AuthResult> login(String username, String password) => guard(() async {
    final response = await _dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  });

  Future<AuthResult> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
  }) => guard(() async {
    await _dio.post(
      '/auth/register',
      data: {
        'username': username,
        'password': password,
        'email': email,
        'fullName': fullName,
      },
    );
    return login(username, password);
  });

  Future<AppUser> me() => guard(() async {
    final response = await _dio.get('/auth/me');
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  });

  Future<AuthResult> refresh(String refreshToken) => guard(() async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return AuthResult.fromJson(response.data as Map<String, dynamic>);
  });

  Future<void> logout(String? refreshToken) => guard(() async {
    await _dio.post(
      '/auth/logout',
      data: {if (refreshToken != null) 'refreshToken': refreshToken},
    );
  });
}
