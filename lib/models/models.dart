class PageResult<T> {
  final List<T> items;
  final int page;
  final int size;
  final int total;

  const PageResult({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
  });

  int get totalPages => total == 0 ? 1 : (total / size).ceil();
  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;

  PageResult.empty() : items = <T>[], page = 1, size = 10, total = 0;
}

class Bouquet {
  final int id;
  final String title;
  final String sku;
  final double price;
  final int stemCount;
  final int supplierId;
  final List<int> categoryIds;
  final int stockTotal;
  final int stockAvailable;
  final DateTime? deletedAt;

  const Bouquet({
    required this.id,
    required this.title,
    required this.sku,
    required this.price,
    required this.stemCount,
    required this.supplierId,
    required this.categoryIds,
    required this.stockTotal,
    required this.stockAvailable,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Bouquet copyWith({DateTime? deletedAt, bool clearDeletedAt = false}) {
    return Bouquet(
      id: id,
      title: title,
      sku: sku,
      price: price,
      stemCount: stemCount,
      supplierId: supplierId,
      categoryIds: categoryIds,
      stockTotal: stockTotal,
      stockAvailable: stockAvailable,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}

class Florist {
  final int id;
  final String firstName;
  final String lastName;
  final String city;
  final int? experienceYear;
  final DateTime? deletedAt;

  const Florist({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.city,
    this.experienceYear,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  String get fullName => '$lastName $firstName';

  Florist copyWith({DateTime? deletedAt, bool clearDeletedAt = false}) {
    return Florist(
      id: id,
      firstName: firstName,
      lastName: lastName,
      city: city,
      experienceYear: experienceYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}

class BouquetQuery {
  final String search;
  final int? categoryId;
  final int? supplierId;
  final double? priceFrom;
  final double? priceTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const BouquetQuery({
    this.search = '',
    this.categoryId,
    this.supplierId,
    this.priceFrom,
    this.priceTo,
    this.sortField = 'title',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  BouquetQuery copyWith({
    String? search,
    Object? categoryId = _unset,
    Object? supplierId = _unset,
    Object? priceFrom = _unset,
    Object? priceTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BouquetQuery(
      search: search ?? this.search,
      categoryId: categoryId == _unset ? this.categoryId : categoryId as int?,
      supplierId: supplierId == _unset ? this.supplierId : supplierId as int?,
      priceFrom: priceFrom == _unset ? this.priceFrom : priceFrom as double?,
      priceTo: priceTo == _unset ? this.priceTo : priceTo as double?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();
}
