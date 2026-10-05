import 'package:dio/dio.dart';

import '../models/models.dart';
import 'seed_data.dart';

abstract interface class BouquetRepository {
  Future<PageResult<Bouquet>> find(BouquetQuery q, {CancelToken? cancelToken});
  Future<Bouquet?> findById(int id);
  Future<Bouquet> create(Bouquet b);
  Future<Bouquet> update(Bouquet b);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

class InMemoryBouquetRepository implements BouquetRepository {
  final List<Bouquet> _bouquets = [...seedBouquets];
  int _nextId = seedBouquets.length + 1;

  @override
  Future<PageResult<Bouquet>> find(
    BouquetQuery q, {
    CancelToken? cancelToken,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var rows = _bouquets
        .where((b) => q.includeDeleted || !b.isDeleted)
        .toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (b) =>
                b.title.toLowerCase().contains(needle) ||
                b.sku.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.categoryId != null) {
      rows = rows.where((b) => b.categoryIds.contains(q.categoryId)).toList();
    }
    if (q.supplierId != null) {
      rows = rows.where((b) => b.supplierId == q.supplierId).toList();
    }
    if (q.priceFrom != null) {
      rows = rows.where((b) => b.price >= q.priceFrom!).toList();
    }
    if (q.priceTo != null) {
      rows = rows.where((b) => b.price <= q.priceTo!).toList();
    }
    rows.sort((a, b) {
      final r = switch (q.sortField) {
        'price' => a.price.compareTo(b.price),
        'stemCount' => a.stemCount.compareTo(b.stemCount),
        _ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      };
      return q.sortAscending ? r : -r;
    });
    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Bouquet>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Bouquet?> findById(int id) async {
    final i = _bouquets.indexWhere((b) => b.id == id);
    return i == -1 ? null : _bouquets[i];
  }

  @override
  Future<Bouquet> create(Bouquet b) async {
    final created = Bouquet(
      id: _nextId++,
      title: b.title,
      sku: b.sku,
      price: b.price,
      stemCount: b.stemCount,
      supplierId: b.supplierId,
      categoryIds: b.categoryIds,
      stockTotal: b.stockTotal,
      stockAvailable: b.stockAvailable,
    );
    _bouquets.add(created);
    return created;
  }

  @override
  Future<Bouquet> update(Bouquet b) async {
    final i = _bouquets.indexWhere((x) => x.id == b.id);
    if (i == -1) throw StateError('Букет ${b.id} не найден');
    _bouquets[i] = b;
    return b;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _bouquets.indexWhere((b) => b.id == id);
    if (i != -1) {
      _bouquets[i] = _bouquets[i].copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _bouquets.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _bouquets.indexWhere((b) => b.id == id);
    if (i != -1) {
      _bouquets[i] = _bouquets[i].copyWith(clearDeletedAt: true);
    }
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _bouquets.indexWhere((b) => b.id == id && !b.isDeleted);
      if (i != -1) {
        _bouquets[i] = _bouquets[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}

abstract interface class FloristRepository {
  Future<PageResult<Florist>> find(BouquetQuery q);
  Future<Florist?> findById(int id);
  Future<Florist> create(Florist f);
  Future<Florist> update(Florist f);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

class InMemoryFloristRepository implements FloristRepository {
  final List<Florist> _florists = [...seedFlorists];
  int _nextId = seedFlorists.length + 1;

  @override
  Future<PageResult<Florist>> find(BouquetQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var rows = _florists
        .where((f) => q.includeDeleted || !f.isDeleted)
        .toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where(
            (f) =>
                f.lastName.toLowerCase().contains(needle) ||
                f.firstName.toLowerCase().contains(needle) ||
                f.city.toLowerCase().contains(needle),
          )
          .toList();
    }
    rows.sort((a, b) {
      final r = switch (q.sortField) {
        'firstName' => a.firstName.toLowerCase().compareTo(
          b.firstName.toLowerCase(),
        ),
        'city' => a.city.toLowerCase().compareTo(b.city.toLowerCase()),
        _ => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
      };
      return q.sortAscending ? r : -r;
    });
    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Florist>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Florist?> findById(int id) async {
    final i = _florists.indexWhere((f) => f.id == id);
    return i == -1 ? null : _florists[i];
  }

  @override
  Future<Florist> create(Florist f) async {
    final created = Florist(
      id: _nextId++,
      firstName: f.firstName,
      lastName: f.lastName,
      city: f.city,
      experienceYear: f.experienceYear,
    );
    _florists.add(created);
    return created;
  }

  @override
  Future<Florist> update(Florist f) async {
    final i = _florists.indexWhere((x) => x.id == f.id);
    if (i == -1) throw StateError('Флорист ${f.id} не найден');
    _florists[i] = f;
    return f;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _florists.indexWhere((f) => f.id == id);
    if (i != -1) {
      _florists[i] = _florists[i].copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _florists.removeWhere((f) => f.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _florists.indexWhere((f) => f.id == id);
    if (i != -1) {
      _florists[i] = _florists[i].copyWith(clearDeletedAt: true);
    }
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      final i = _florists.indexWhere((f) => f.id == id && !f.isDeleted);
      if (i != -1) {
        _florists[i] = _florists[i].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}

abstract interface class CategoryRepository {
  Future<List<Category>> findAll({bool includeDeleted = false});
  Future<Category?> findById(int id);
  Future<Category> create(Category c);
  Future<Category> update(Category c);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
}

class InMemoryCategoryRepository implements CategoryRepository {
  final List<Category> _categories = [...seedCategories];
  int _nextId = seedCategories.length + 1;

  @override
  Future<List<Category>> findAll({bool includeDeleted = false}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _categories.where((c) => includeDeleted || !c.isDeleted).toList();
  }

  @override
  Future<Category?> findById(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    return i == -1 ? null : _categories[i];
  }

  @override
  Future<Category> create(Category c) async {
    final created = Category(
      id: _nextId++,
      name: c.name,
      description: c.description,
    );
    _categories.add(created);
    return created;
  }

  @override
  Future<Category> update(Category c) async {
    final i = _categories.indexWhere((x) => x.id == c.id);
    if (i == -1) throw StateError('Категория ${c.id} не найдена');
    _categories[i] = c;
    return c;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i != -1) {
      _categories[i] = _categories[i].copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i != -1) {
      _categories[i] = _categories[i].copyWith(clearDeletedAt: true);
    }
  }
}

abstract interface class SupplierRepository {
  Future<List<Supplier>> findAll({bool includeDeleted = false});
  Future<Supplier?> findById(int id);
  Future<Supplier> create(Supplier s);
  Future<Supplier> update(Supplier s);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> countBouquets(int supplierId);
}

class InMemorySupplierRepository implements SupplierRepository {
  final List<Supplier> _suppliers = [...seedSuppliers];
  final BouquetRepository _bouquets = InMemoryBouquetRepository();
  int _nextId = seedSuppliers.length + 1;

  @override
  Future<List<Supplier>> findAll({bool includeDeleted = false}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _suppliers.where((s) => includeDeleted || !s.isDeleted).toList();
  }

  @override
  Future<Supplier?> findById(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    return i == -1 ? null : _suppliers[i];
  }

  @override
  Future<Supplier> create(Supplier s) async {
    final created = Supplier(
      id: _nextId++,
      name: s.name,
      phone: s.phone,
      city: s.city,
    );
    _suppliers.add(created);
    return created;
  }

  @override
  Future<Supplier> update(Supplier s) async {
    final i = _suppliers.indexWhere((x) => x.id == s.id);
    if (i == -1) throw StateError('Поставщик ${s.id} не найден');
    _suppliers[i] = s;
    return s;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    if (i != -1) {
      _suppliers[i] = _suppliers[i].copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _suppliers.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    if (i != -1) {
      _suppliers[i] = _suppliers[i].copyWith(clearDeletedAt: true);
    }
  }

  @override
  Future<int> countBouquets(int supplierId) async {
    final all = await _bouquets.find(const BouquetQuery(size: 10000));
    return all.items
        .where((b) => b.supplierId == supplierId && !b.isDeleted)
        .length;
  }
}

abstract interface class CustomerRepository {
  Future<List<Customer>> findAll({bool includeDeleted = false});
  Future<Customer?> findById(int id);
  Future<Customer> create(Customer c);
  Future<Customer> update(Customer c);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<bool> emailExists(String email, {int? exceptId});
}

class InMemoryCustomerRepository implements CustomerRepository {
  final List<Customer> _customers = [...seedCustomers];
  int _nextId = seedCustomers.length + 1;

  @override
  Future<List<Customer>> findAll({bool includeDeleted = false}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _customers.where((c) => includeDeleted || !c.isDeleted).toList();
  }

  @override
  Future<Customer?> findById(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    return i == -1 ? null : _customers[i];
  }

  @override
  Future<Customer> create(Customer c) async {
    final created = Customer(
      id: _nextId++,
      firstName: c.firstName,
      lastName: c.lastName,
      email: c.email,
      phone: c.phone,
      card: c.card,
    );
    _customers.add(created);
    return created;
  }

  @override
  Future<Customer> update(Customer c) async {
    final i = _customers.indexWhere((x) => x.id == c.id);
    if (i == -1) throw StateError('Покупатель ${c.id} не найден');
    _customers[i] = c;
    return c;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _customers[i] = _customers[i].copyWith(deletedAt: DateTime.now());
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _customers.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _customers[i] = _customers[i].copyWith(clearDeletedAt: true);
    }
  }

  @override
  Future<bool> emailExists(String email, {int? exceptId}) async {
    final target = email.trim().toLowerCase();
    return _customers.any(
      (c) => c.email.trim().toLowerCase() == target && c.id != exceptId,
    );
  }
}
