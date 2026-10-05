import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../utils/validators.dart';

class BouquetFormScreen extends StatefulWidget {
  final int? id;
  const BouquetFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<BouquetFormScreen> createState() => _BouquetFormScreenState();
}

class _BouquetFormScreenState extends State<BouquetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stemController = TextEditingController();
  final _stockTotalController = TextEditingController();
  final _stockAvailableController = TextEditingController();

  int? _supplierId;
  List<int> _categoryIds = [];

  List<Supplier> _suppliers = [];
  List<Category> _categories = [];

  /// Ошибки валидации, пришедшие с сервера (код 422).
  Map<String, String> _serverErrors = {};

  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final suppRepo = context.read<SupplierRepository>();
    final catRepo = context.read<CategoryRepository>();

    _suppliers = await suppRepo.findAll();
    _categories = await catRepo.findAll();

    if (widget.isEditing) {
      if (!mounted) return;
      final repo = context.read<BouquetRepository>();
      final b = await repo.findById(widget.id!);
      if (b != null) {
        _titleController.text = b.title;
        _skuController.text = b.sku;
        _priceController.text = b.price.toStringAsFixed(0);
        _stemController.text = '${b.stemCount}';
        _stockTotalController.text = '${b.stockTotal}';
        _stockAvailableController.text = '${b.stockAvailable}';
        _supplierId = b.supplierId;
        _categoryIds = [...b.categoryIds];
      }
    }

    if (!mounted) return;
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stemController.dispose();
    _stockTotalController.dispose();
    _stockAvailableController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Сбрасываем серверные ошибки перед новой попыткой
    setState(() => _serverErrors = {});

    if (!_formKey.currentState!.validate()) return;
    if (_supplierId == null) {
      _showSnackBar('Выберите поставщика');
      return;
    }
    if (_categoryIds.isEmpty) {
      _showSnackBar('Выберите хотя бы одну категорию');
      return;
    }

    setState(() => _loading = true);

    final repo = context.read<BouquetRepository>();
    final bouquet = Bouquet(
      id: widget.id ?? 0,
      title: _titleController.text.trim(),
      sku: _skuController.text.trim().toUpperCase(),
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      stemCount: int.tryParse(_stemController.text.trim()) ?? 0,
      supplierId: _supplierId!,
      categoryIds: _categoryIds,
      stockTotal: int.tryParse(_stockTotalController.text.trim()) ?? 0,
      stockAvailable: int.tryParse(_stockAvailableController.text.trim()) ?? 0,
    );

    try {
      if (widget.isEditing) {
        await repo.update(bouquet);
      } else {
        await repo.create(bouquet);
      }
      if (!mounted) return;
      context.go('/');
    } on ValidationException catch (e) {
      // 422 — раскладываем по полям и перерисовываем форму
      if (!mounted) return;
      setState(() => _serverErrors = e.errors);
      _formKey.currentState!.validate();
    } on ConflictException catch (e) {
      // 409 — показываем SnackBar
      if (!mounted) return;
      _showSnackBar(e.message);
    } on ApiException catch (e) {
      // Все остальные ошибки API
      if (!mounted) return;
      _showSnackBar(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final rose = Theme.of(context).colorScheme.primary;

    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Букет')),
        body: Center(child: CircularProgressIndicator(color: rose)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Редактирование букета' : 'Новый букет'),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8E1), Color(0xFFFCE4EC), Color(0xFFEDE7F6)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Название',
                            prefixIcon: Icon(Icons.local_florist),
                          ),
                          validator: (v) {
                            final server = _serverErrors['title'];
                            if (server != null) return server;
                            return Validators.lengthRange(
                              v,
                              min: 2,
                              max: 80,
                              label: 'Название',
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(
                            labelText: 'Артикул (FL-000)',
                            prefixIcon: Icon(Icons.qr_code),
                          ),
                          validator: (v) {
                            final server = _serverErrors['sku'];
                            if (server != null) return server;
                            return Validators.sku(v);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Цена, ₽',
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                validator: (v) {
                                  final server = _serverErrors['price'];
                                  if (server != null) return server;
                                  return Validators.decimalRange(
                                    v,
                                    min: 50,
                                    max: 1000000,
                                    label: 'Цена',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _stemController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Стеблей',
                                  prefixIcon: Icon(Icons.grass),
                                ),
                                validator: (v) {
                                  final server = _serverErrors['stemCount'];
                                  if (server != null) return server;
                                  return Validators.positiveInt(
                                    v,
                                    label: 'Количество стеблей',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _stockTotalController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Всего на складе',
                                  prefixIcon: Icon(Icons.inventory),
                                ),
                                validator: (v) {
                                  final server = _serverErrors['stockTotal'];
                                  if (server != null) return server;
                                  return Validators.nonNegativeInt(
                                    v,
                                    label: 'Всего на складе',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _stockAvailableController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Доступно',
                                  prefixIcon: Icon(Icons.check_circle),
                                ),
                                validator: (v) {
                                  final server =
                                      _serverErrors['stockAvailable'];
                                  if (server != null) return server;
                                  return Validators.nonNegativeInt(
                                    v,
                                    label: 'Доступно',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Связи',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: rose,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _supplierId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Поставщик',
                            prefixIcon: Icon(Icons.local_shipping),
                          ),
                          items: [
                            for (final s in _suppliers)
                              DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ),
                          ],
                          onChanged: (v) => setState(() => _supplierId = v),
                          validator: (v) {
                            final server = _serverErrors['supplierId'];
                            if (server != null) return server;
                            return v == null ? 'Выберите поставщика' : null;
                          },
                        ),
                        const SizedBox(height: 16),
                        FormField<List<int>>(
                          initialValue: _categoryIds,
                          validator: (v) {
                            final server = _serverErrors['categoryIds'];
                            if (server != null) return server;
                            return (v == null || v.isEmpty)
                                ? 'Выберите хотя бы одну категорию'
                                : null;
                          },
                          builder: (field) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Категории',
                                border: const OutlineInputBorder(),
                                errorText: field.errorText,
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _categories.map((c) {
                                  final selected = _categoryIds.contains(c.id);
                                  return FilterChip(
                                    label: Text(c.name),
                                    selected: selected,
                                    onSelected: (_) {
                                      final next = [..._categoryIds];
                                      selected
                                          ? next.remove(c.id)
                                          : next.add(c.id);
                                      setState(() => _categoryIds = next);
                                      field.didChange(next);
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        widget.isEditing
                                            ? 'Сохранить'
                                            : 'Создать',
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/'),
                              child: const Text('Отмена'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
