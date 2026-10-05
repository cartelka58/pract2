import 'package:dio/dio.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import 'repositories.dart';

class ApiBouquetRepository implements BouquetRepository {
  final Dio _dio;
  ApiBouquetRepository(this._dio);

  @override
  Future<PageResult<Bouquet>> find(
    BouquetQuery q, {
    CancelToken? cancelToken,
  }) => guard(() async {
    final response = await _dio.get(
      '/bouquets',
      queryParameters: {
        if (q.search.trim().isNotEmpty) 'search': q.search.trim(),
        if (q.categoryId != null) 'categoryId': q.categoryId,
        if (q.supplierId != null) 'supplierId': q.supplierId,
        if (q.priceFrom != null) 'priceFrom': q.priceFrom,
        if (q.priceTo != null) 'priceTo': q.priceTo,
        'sort': '${q.sortField},${q.sortAscending ? 'asc' : 'desc'}',
        'page': q.page,
        'size': q.size,
        if (q.includeDeleted) 'includeDeleted': true,
      },
      cancelToken: cancelToken,
    );

    final data = response.data as Map<String, dynamic>;
    final items = (data['items'] as List)
        .whereType<Map<String, dynamic>>()
        .map(_bouquetFromServer)
        .toList();

    return PageResult(
      items: items,
      page: data['page'] as int? ?? q.page,
      size: data['size'] as int? ?? q.size,
      total: data['total'] as int? ?? 0,
    );
  });

  @override
  Future<Bouquet?> findById(int id) => guard(() async {
    final response = await _dio.get('/bouquets/$id');
    return _bouquetFromServer(response.data as Map<String, dynamic>);
  });

  @override
  Future<Bouquet> create(Bouquet b) => guard(() async {
    final response = await _dio.post(
      '/bouquets',
      data: {
        'title': b.title,
        'sku': b.sku,
        'price': b.price,
        'stemCount': b.stemCount,
        'supplierId': b.supplierId,
        'categoryIds': b.categoryIds,
        'stockTotal': b.stockTotal,
        'stockAvailable': b.stockAvailable,
      },
    );
    return _bouquetFromServer(response.data as Map<String, dynamic>);
  });

  @override
  Future<Bouquet> update(Bouquet b) => guard(() async {
    final response = await _dio.put(
      '/bouquets/${b.id}',
      data: {
        'title': b.title,
        'sku': b.sku,
        'price': b.price,
        'stemCount': b.stemCount,
        'supplierId': b.supplierId,
        'categoryIds': b.categoryIds,
        'stockTotal': b.stockTotal,
        'stockAvailable': b.stockAvailable,
      },
    );
    return _bouquetFromServer(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> softDelete(int id) => guard(() => _dio.delete('/bouquets/$id'));

  @override
  Future<void> hardDelete(int id) => guard(
    () => _dio.delete('/bouquets/$id', queryParameters: {'hard': true}),
  );

  @override
  Future<void> restore(int id) =>
      guard(() => _dio.post('/bouquets/$id/restore'));

  @override
  Future<int> deleteMany(List<int> ids) => guard(() async {
    final response = await _dio.post(
      '/bouquets/bulk-delete',
      data: {'ids': ids},
    );
    return (response.data as Map<String, dynamic>)['deleted'] as int? ?? 0;
  });

  /// Преобразует ответ сервера (с развёрнутыми объектами) в плоский вид.
  static Bouquet _bouquetFromServer(Map<String, dynamic> json) {
    final supplierId = (json['supplier'] as Map?)?['id'] as int? ?? 0;
    final categoryIds = (json['categories'] as List? ?? [])
        .whereType<Map>()
        .map((c) => c['id'] as int)
        .toList();

    return Bouquet(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stemCount: json['stemCount'] as int? ?? 0,
      supplierId: supplierId,
      categoryIds: categoryIds,
      stockTotal: json['stockTotal'] as int? ?? 0,
      stockAvailable: json['stockAvailable'] as int? ?? 0,
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }
}
