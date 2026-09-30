import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

enum LoadStatus { idle, loading, success, error }

class BouquetListNotifier extends ChangeNotifier {
  final BouquetRepository _repo;
  BouquetListNotifier(this._repo);

  BouquetQuery _query = const BouquetQuery();
  PageResult<Bouquet> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  BouquetQuery get query => _query;
  PageResult<Bouquet> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repo.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = '$e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(BouquetQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repo.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  Future<void> softDeleteOne(int id) async {
    await _repo.softDelete(id);
    await load();
  }

  Future<void> hardDeleteOne(int id) async {
    await _repo.hardDelete(id);
    await load();
  }

  Future<void> restoreOne(int id) async {
    await _repo.restore(id);
    await load();
  }

  /// Преобразует текущий query в строку URL-параметров.
  String toQueryString() {
    final params = <String, String>{};
    if (_query.search.isNotEmpty) params['search'] = _query.search;
    if (_query.categoryId != null) {
      params['categoryId'] = '${_query.categoryId}';
    }
    if (_query.supplierId != null) {
      params['supplierId'] = '${_query.supplierId}';
    }
    if (_query.priceFrom != null) {
      params['priceFrom'] = '${_query.priceFrom}';
    }
    if (_query.priceTo != null) {
      params['priceTo'] = '${_query.priceTo}';
    }
    if (_query.sortField != 'title') params['sort'] = _query.sortField;
    if (!_query.sortAscending) params['dir'] = 'desc';
    if (_query.page != 1) params['page'] = '${_query.page}';
    if (_query.size != 10) params['size'] = '${_query.size}';
    if (_query.includeDeleted) params['deleted'] = '1';

    if (params.isEmpty) return '';
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  /// Восстанавливает query из URL-параметров.
  static BouquetQuery queryFromUri(Map<String, String> p) {
    return BouquetQuery(
      search: p['search'] ?? '',
      categoryId: int.tryParse(p['categoryId'] ?? ''),
      supplierId: int.tryParse(p['supplierId'] ?? ''),
      priceFrom: double.tryParse(p['priceFrom'] ?? ''),
      priceTo: double.tryParse(p['priceTo'] ?? ''),
      sortField: p['sort'] ?? 'title',
      sortAscending: p['dir'] != 'desc',
      page: int.tryParse(p['page'] ?? '') ?? 1,
      size: int.tryParse(p['size'] ?? '') ?? 10,
      includeDeleted: p['deleted'] == '1',
    );
  }
}

class FloristListNotifier extends ChangeNotifier {
  final FloristRepository _repo;
  FloristListNotifier(this._repo);

  BouquetQuery _query = const BouquetQuery(sortField: 'lastName');
  PageResult<Florist> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  BouquetQuery get query => _query;
  PageResult<Florist> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _result = await _repo.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = '$e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(BouquetQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repo.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  Future<void> softDeleteOne(int id) async {
    await _repo.softDelete(id);
    await load();
  }

  Future<void> hardDeleteOne(int id) async {
    await _repo.hardDelete(id);
    await load();
  }

  Future<void> restoreOne(int id) async {
    await _repo.restore(id);
    await load();
  }
}
