import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import 'repositories.dart';

class ApiSupplierRepository implements SupplierRepository {
  final Dio _dio;
  ApiSupplierRepository(this._dio);

  @override
  Future<List<Supplier>> findAll({bool includeDeleted = false}) =>
      guard(() async {
        final response = await _dio.get(
          '/suppliers',
          queryParameters: {
            'size': 100,
            if (includeDeleted) 'includeDeleted': true,
          },
        );
        final data = response.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Supplier.fromJson)
            .toList();
      });

  @override
  Future<Supplier?> findById(int id) => guard(() async {
    final response = await _dio.get('/suppliers/$id');
    return Supplier.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Supplier> create(Supplier s) => guard(() async {
    final response = await _dio.post(
      '/suppliers',
      data: {'name': s.name, 'phone': s.phone, 'city': s.city},
    );
    return Supplier.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Supplier> update(Supplier s) => guard(() async {
    final response = await _dio.put(
      '/suppliers/${s.id}',
      data: {'name': s.name, 'phone': s.phone, 'city': s.city},
    );
    return Supplier.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/suppliers/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete('/suppliers/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/suppliers/$id/restore'));

  @override
  Future<int> countBouquets(int supplierId) => guard(() async {
    final response = await _dio.get(
      '/bouquets',
      queryParameters: {'supplierId': supplierId, 'size': 1},
    );
    final data = response.data as Map<String, dynamic>;
    return data['total'] as int? ?? 0;
  });
}
