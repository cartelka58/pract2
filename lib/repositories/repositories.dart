import '../models/models.dart';
import 'seed_data.dart';

abstract interface class BouquetRepository {
  Future<PageResult<Bouquet>> find(BouquetQuery q);
  Future<Bouquet?> findById(int id);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

class InMemoryBouquetRepository implements BouquetRepository {
  final List<Bouquet> _bouquets = [...seedBouquets];

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
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}

class InMemoryFloristRepository implements FloristRepository {
  final List<Florist> _florists = [...seedFlorists];

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
