import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import 'repositories.dart';

class ApiFloristRepository implements FloristRepository {
  final Dio _dio;
  ApiFloristRepository(this._dio);

  @override
  Future<PageResult<Florist>> find(BouquetQuery q) => guard(() async {
    final response = await _dio.get(
      '/florists',
      queryParameters: {
        if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
        'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
        'page': q.page,
        'size': q.size,
        if (q.includeDeleted) 'includeDeleted': true,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final items = (data['items'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Florist.fromJson)
        .toList();

    return PageResult(
      items: items,
      page: data['page'] as int? ?? q.page,
      size: data['size'] as int? ?? q.size,
      total: data['total'] as int? ?? 0,
    );
  });

  @override
  Future<Florist?> findById(int id) => guard(() async {
    final response = await _dio.get('/florists/$id');
    return Florist.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Florist> create(Florist f) => guard(() async {
    final response = await _dio.post(
      '/florists',
      data: {
        'firstName': f.firstName,
        'lastName': f.lastName,
        'city': f.city,
        if (f.experienceYear != null) 'experienceYear': f.experienceYear,
      },
    );
    return Florist.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<Florist> update(Florist f) => guard(() async {
    final response = await _dio.put(
      '/florists/${f.id}',
      data: {
        'firstName': f.firstName,
        'lastName': f.lastName,
        'city': f.city,
        if (f.experienceYear != null) 'experienceYear': f.experienceYear,
      },
    );
    return Florist.fromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/florists/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete('/florists/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/florists/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post(
      '/florists/bulk-delete',
      data: {'ids': ids},
    );
    return (response.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
  });
}
