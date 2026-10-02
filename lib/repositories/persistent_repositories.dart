import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'repositories.dart';
import 'seed_data.dart';

class PersistentBouquetRepository implements BouquetRepository {
  static const _key = 'bouquets_v1';
  final SharedPreferences _prefs;
  List<Bouquet> _bouquets = [];

  PersistentBouquetRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _bouquets = [...seedBouquets];
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _bouquets = list
          .map((e) => Bouquet.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _bouquets = [...seedBouquets];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_bouquets.map((b) => b.toJson()).toList()),
    );
  }

  @override
  Future<PageResult<Bouquet>> find(BouquetQuery q) async {
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
    final nextId = _bouquets.isEmpty
        ? 1
        : _bouquets.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = Bouquet(
      id: nextId,
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
    await _persist();
    return created;
  }

  @override
  Future<Bouquet> update(Bouquet b) async {
    final i = _bouquets.indexWhere((x) => x.id == b.id);
    if (i == -1) throw StateError('Букет ${b.id} не найден');
    _bouquets[i] = b;
    await _persist();
    return b;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _bouquets.indexWhere((b) => b.id == id);
    if (i != -1) {
      _bouquets[i] = _bouquets[i].copyWith(deletedAt: DateTime.now());
      await _persist();
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _bouquets.removeWhere((b) => b.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _bouquets.indexWhere((b) => b.id == id);
    if (i != -1) {
      _bouquets[i] = _bouquets[i].copyWith(clearDeletedAt: true);
      await _persist();
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
    if (count > 0) await _persist();
    return count;
  }
}

class PersistentFloristRepository implements FloristRepository {
  static const _key = 'florists_v1';
  final SharedPreferences _prefs;
  List<Florist> _florists = [];

  PersistentFloristRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _florists = [...seedFlorists];
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _florists = list
          .map((e) => Florist.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _florists = [...seedFlorists];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_florists.map((f) => f.toJson()).toList()),
    );
  }

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
    final nextId = _florists.isEmpty
        ? 1
        : _florists.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = Florist(
      id: nextId,
      firstName: f.firstName,
      lastName: f.lastName,
      city: f.city,
      experienceYear: f.experienceYear,
    );
    _florists.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Florist> update(Florist f) async {
    final i = _florists.indexWhere((x) => x.id == f.id);
    if (i == -1) throw StateError('Флорист ${f.id} не найден');
    _florists[i] = f;
    await _persist();
    return f;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _florists.indexWhere((f) => f.id == id);
    if (i != -1) {
      _florists[i] = _florists[i].copyWith(deletedAt: DateTime.now());
      await _persist();
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _florists.removeWhere((f) => f.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _florists.indexWhere((f) => f.id == id);
    if (i != -1) {
      _florists[i] = _florists[i].copyWith(clearDeletedAt: true);
      await _persist();
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
    if (count > 0) await _persist();
    return count;
  }
}

class PersistentCategoryRepository implements CategoryRepository {
  static const _key = 'categories_v1';
  final SharedPreferences _prefs;
  List<Category> _categories = [];

  PersistentCategoryRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _categories = [...seedCategories];
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _categories = list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _categories = [...seedCategories];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_categories.map((c) => c.toJson()).toList()),
    );
  }

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
    final nextId = _categories.isEmpty
        ? 1
        : _categories.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = Category(
      id: nextId,
      name: c.name,
      description: c.description,
    );
    _categories.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Category> update(Category c) async {
    final i = _categories.indexWhere((x) => x.id == c.id);
    if (i == -1) throw StateError('Категория ${c.id} не найдена');
    _categories[i] = c;
    await _persist();
    return c;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i != -1) {
      _categories[i] = _categories[i].copyWith(deletedAt: DateTime.now());
      await _persist();
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _categories.removeWhere((c) => c.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _categories.indexWhere((c) => c.id == id);
    if (i != -1) {
      _categories[i] = _categories[i].copyWith(clearDeletedAt: true);
      await _persist();
    }
  }
}

class PersistentSupplierRepository implements SupplierRepository {
  static const _key = 'suppliers_v1';
  final SharedPreferences _prefs;
  final BouquetRepository _bouquets;
  List<Supplier> _suppliers = [];

  PersistentSupplierRepository(this._prefs, this._bouquets) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _suppliers = [...seedSuppliers];
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _suppliers = list
          .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _suppliers = [...seedSuppliers];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_suppliers.map((s) => s.toJson()).toList()),
    );
  }

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
    final nextId = _suppliers.isEmpty
        ? 1
        : _suppliers.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = Supplier(
      id: nextId,
      name: s.name,
      phone: s.phone,
      city: s.city,
    );
    _suppliers.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Supplier> update(Supplier s) async {
    final i = _suppliers.indexWhere((x) => x.id == s.id);
    if (i == -1) throw StateError('Поставщик ${s.id} не найден');
    _suppliers[i] = s;
    await _persist();
    return s;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    if (i != -1) {
      _suppliers[i] = _suppliers[i].copyWith(deletedAt: DateTime.now());
      await _persist();
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _suppliers.removeWhere((s) => s.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _suppliers.indexWhere((s) => s.id == id);
    if (i != -1) {
      _suppliers[i] = _suppliers[i].copyWith(clearDeletedAt: true);
      await _persist();
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

class PersistentCustomerRepository implements CustomerRepository {
  static const _key = 'customers_v1';
  final SharedPreferences _prefs;
  List<Customer> _customers = [];

  PersistentCustomerRepository(this._prefs) {
    _restore();
  }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _customers = [...seedCustomers];
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _customers = list
          .map((e) => Customer.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _customers = [...seedCustomers];
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(
      _key,
      jsonEncode(_customers.map((c) => c.toJson()).toList()),
    );
  }

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
    final nextId = _customers.isEmpty
        ? 1
        : _customers.map((x) => x.id).reduce((a, b) => a > b ? a : b) + 1;
    final created = Customer(
      id: nextId,
      firstName: c.firstName,
      lastName: c.lastName,
      email: c.email,
      phone: c.phone,
      card: c.card,
    );
    _customers.add(created);
    await _persist();
    return created;
  }

  @override
  Future<Customer> update(Customer c) async {
    final i = _customers.indexWhere((x) => x.id == c.id);
    if (i == -1) throw StateError('Покупатель ${c.id} не найден');
    _customers[i] = c;
    await _persist();
    return c;
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _customers[i] = _customers[i].copyWith(deletedAt: DateTime.now());
      await _persist();
    }
  }

  @override
  Future<void> hardDelete(int id) async {
    _customers.removeWhere((c) => c.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final i = _customers.indexWhere((c) => c.id == id);
    if (i != -1) {
      _customers[i] = _customers[i].copyWith(clearDeletedAt: true);
      await _persist();
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
