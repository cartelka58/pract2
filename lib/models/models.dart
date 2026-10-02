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

class Category {
  final int id;
  final String name;
  final String description;
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  Category copyWith({
    String? name,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}

class Supplier {
  final int id;
  final String name;
  final String phone;
  final String city;
  final DateTime? deletedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'city': city,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    city: json['city'] as String? ?? '',
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  Supplier copyWith({
    String? name,
    String? phone,
    String? city,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}

class LoyaltyCard {
  final String number;
  final int discountPercent;
  final DateTime issuedAt;

  const LoyaltyCard({
    required this.number,
    required this.discountPercent,
    required this.issuedAt,
  });

  Map<String, dynamic> toJson() => {
    'number': number,
    'discountPercent': discountPercent,
    'issuedAt': issuedAt.toIso8601String(),
  };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
    number: json['number'] as String? ?? '',
    discountPercent: json['discountPercent'] as int? ?? 0,
    issuedAt: json['issuedAt'] == null
        ? DateTime.now()
        : DateTime.parse(json['issuedAt'] as String),
  );

  LoyaltyCard copyWith({
    String? number,
    int? discountPercent,
    DateTime? issuedAt,
  }) {
    return LoyaltyCard(
      number: number ?? this.number,
      discountPercent: discountPercent ?? this.discountPercent,
      issuedAt: issuedAt ?? this.issuedAt,
    );
  }
}

class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final LoyaltyCard? card;
  final DateTime? deletedAt;

  const Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.card,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  String get fullName => '$lastName $firstName';

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'card': card?.toJson(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as int,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    card: json['card'] == null
        ? null
        : LoyaltyCard.fromJson(json['card'] as Map<String, dynamic>),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  Customer copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    LoyaltyCard? card,
    bool clearCard = false,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Customer(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      card: clearCard ? null : (card ?? this.card),
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sku': sku,
    'price': price,
    'stemCount': stemCount,
    'supplierId': supplierId,
    'categoryIds': categoryIds,
    'stockTotal': stockTotal,
    'stockAvailable': stockAvailable,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Bouquet.fromJson(Map<String, dynamic> json) => Bouquet(
    id: json['id'] as int,
    title: json['title'] as String? ?? '',
    sku: json['sku'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0,
    stemCount: json['stemCount'] as int? ?? 0,
    supplierId: json['supplierId'] as int? ?? 0,
    categoryIds: (json['categoryIds'] as List?)?.cast<int>() ?? const [],
    stockTotal: json['stockTotal'] as int? ?? 0,
    stockAvailable: json['stockAvailable'] as int? ?? 0,
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  Bouquet copyWith({
    String? title,
    String? sku,
    double? price,
    int? stemCount,
    int? supplierId,
    List<int>? categoryIds,
    int? stockTotal,
    int? stockAvailable,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Bouquet(
      id: id,
      title: title ?? this.title,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stemCount: stemCount ?? this.stemCount,
      supplierId: supplierId ?? this.supplierId,
      categoryIds: categoryIds ?? this.categoryIds,
      stockTotal: stockTotal ?? this.stockTotal,
      stockAvailable: stockAvailable ?? this.stockAvailable,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'city': city,
    'experienceYear': experienceYear,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Florist.fromJson(Map<String, dynamic> json) => Florist(
    id: json['id'] as int,
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    city: json['city'] as String? ?? '',
    experienceYear: json['experienceYear'] as int?,
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String),
  );

  Florist copyWith({
    String? firstName,
    String? lastName,
    String? city,
    int? experienceYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Florist(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      city: city ?? this.city,
      experienceYear: experienceYear ?? this.experienceYear,
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
  