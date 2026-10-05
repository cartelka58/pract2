import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import 'repositories.dart';

class ApiCustomerRepository implements CustomerRepository {
  final Dio _dio;
  ApiCustomerRepository(this._dio);

  @override
  Future<List<Customer>> findAll({bool includeDeleted = false}) =>
      guard(() async {
        final response = await _dio.get(
          '/customers',
          queryParameters: {
            'size': 100,
            if (includeDeleted) 'includeDeleted': true,
          },
        );
        final data = response.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Customer.fromJson)
            .toList();
      });

  @override
  Future<Customer?> findById(int id) => guard(() async {
    final response = await _dio.get('/customers/$id');
    return Customer.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Customer> create(Customer c) => guard(() async {
    final response = await _dio.post(
      '/customers',
      data: {
        'firstName': c.firstName,
        'lastName': c.lastName,
        'email': c.email,
        'phone': c.phone,
      },
    );
    return Customer.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Customer> update(Customer c) => guard(() async {
    final response = await _dio.put(
      '/customers/${c.id}',
      data: {
        'firstName': c.firstName,
        'lastName': c.lastName,
        'email': c.email,
        'phone': c.phone,
      },
    );
    return Customer.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/customers/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete('/customers/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/customers/$id/restore'));


  @override
  Future<bool> emailExists(String email, {int? exceptId}) => guard(() async {
    final response = await _dio.get(
      '/customers',
      queryParameters: {'search': email.trim(), 'size': 100},
    );
    final data = response.data as Map<String, dynamic>;
    final target = email.trim().toLowerCase();
    return (data['items'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Customer.fromJson)
        .any((c) => c.email.toLowerCase() == target && c.id != exceptId);
  });
}
