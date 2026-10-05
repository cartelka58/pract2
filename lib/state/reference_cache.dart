import 'package:flutter/foundation.dart' hide Category;
import '../core/api_exceptions.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class ReferenceCache extends ChangeNotifier {
  final CategoryRepository _categoryRepo;
  final SupplierRepository _supplierRepo;

  ReferenceCache(this._categoryRepo, this._supplierRepo);

  List<Category>? _categories;
  List<Supplier>? _suppliers;

  bool _loadingCategories = false;
  bool _loadingSuppliers = false;
  String? _categoriesError;
  String? _suppliersError;

  List<Category> get categories => _categories ?? const [];
  List<Supplier> get suppliers => _suppliers ?? const [];

  bool get loadingCategories => _loadingCategories;
  bool get loadingSuppliers => _loadingSuppliers;
  String? get categoriesError => _categoriesError;
  String? get suppliersError => _suppliersError;

  bool get hasCategories => _categories != null;
  bool get hasSuppliers => _suppliers != null;

  Future<List<Category>> ensureCategories() async {
    if (_categories != null) return _categories!;

    _loadingCategories = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _categoryRepo.findAll();
      return _categories!;
    } on ApiException catch (e) {
      _categoriesError = e.message;
      rethrow;
    } catch (e) {
      _categoriesError = '$e';
      rethrow;
    } finally {
      _loadingCategories = false;
      notifyListeners();
    }
  }

  Future<List<Supplier>> ensureSuppliers() async {
    if (_suppliers != null) return _suppliers!;

    _loadingSuppliers = true;
    _suppliersError = null;
    notifyListeners();

    try {
      _suppliers = await _supplierRepo.findAll();
      return _suppliers!;
    } on ApiException catch (e) {
      _suppliersError = e.message;
      rethrow;
    } catch (e) {
      _suppliersError = '$e';
      rethrow;
    } finally {
      _loadingSuppliers = false;
      notifyListeners();
    }
  }

  Future<void> invalidateCategories() async {
    _categories = null;
    await ensureCategories();
  }

  Future<void> invalidateSuppliers() async {
    _suppliers = null;
    await ensureSuppliers();
  }

  void clear() {
    _categories = null;
    _suppliers = null;
    notifyListeners();
  }
}
