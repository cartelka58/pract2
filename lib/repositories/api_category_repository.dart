import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import 'repositories.dart';

class ApiCategoryRepository implements CategoryRepository {
  final Dio _dio;
  ApiCategoryRepository(this._dio);

  @override
  Future<List<Category>> findAll({bool includeDeleted = false}) =>
      guard(() async {
        final response = await _dio.get('/categories', queryParameters: {
          'size': 100,
          if (includeDeleted) 'includeDeleted': true,
        });
        final data = response.data as Map<String, dynamic>;
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Category.fromJson)
            .toList();
      });

  @override
  Future<Category?> findById(int id) => guard(() async {
        final response = await _dio.get('/categories/$id');
        return Category.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<Category> create(Category c) => guard(() async {
        final response = await _dio.post('/categories', data: {
          'name': c.name,
          'description': c.description,
        });
        return Category.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<Category> update(Category c) => guard(() async {
        final response = await _dio.put('/categories/${c.id}', data: {
          'name': c.name,
          'description': c.description,
        });
        return Category.fromJson(response.data as Map<String, dynamic>);
      });

  @override
  Future<void> softDelete(int id) =>
      guard(() => _dio.delete('/categories/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
      () => _dio.delete('/categories/$id', queryParameters: {'hard': true}));

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/categories/$id/restore'));
}