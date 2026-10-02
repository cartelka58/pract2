import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    if (!_formKey.currentState!.validate()) return;
    if (_supplierId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите поставщика')));
      return;
    }
    if (_categoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы одну категорию')),
      );
      return;
    }
    setState(() => _loading = true);

    final repo = context.read<BouquetRepository>();

    final title = _titleController.text.trim();
    final sku = _skuController.text.trim().toUpperCase();
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0;
    final stem = int.tryParse(_stemController.text.trim()) ?? 0;
    final stockTotal = int.tryParse(_stockTotalController.text.trim()) ?? 0;
    final stockAvail = int.tryParse(_stockAvailableController.text.trim()) ?? 0;

    // Проверка уникальности артикула
    final all = await repo.find(const BouquetQuery(size: 10000));
    final duplicate = all.items.any(
      (b) =>
          b.sku.toLowerCase() == sku.toLowerCase() &&
          (!widget.isEditing || b.id != widget.id),
    );

    if (duplicate) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Артикул уже используется')));
      return;
    }

    if (widget.isEditing) {
      final existing = await repo.findById(widget.id!);
      if (existing == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }
      await repo.update(
        existing.copyWith(
          title: title,
          sku: sku,
          price: price,
          stemCount: stem,
          supplierId: _supplierId,
          categoryIds: _categoryIds,
          stockTotal: stockTotal,
          stockAvailable: stockAvail,
        ),
      );
    } else {
      await repo.create(
        Bouquet(
          id: 0,
          title: title,
          sku: sku,
          price: price,
          stemCount: stem,
          supplierId: _supplierId!,
          categoryIds: _categoryIds,
          stockTotal: stockTotal,
          stockAvailable: stockAvail,
        ),
      );
    }

    if (!mounted) return;
    context.go('/');
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
                          validator: (v) => Validators.lengthRange(
                            v,
                            min: 2,
                            max: 80,
                            label: 'Название',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _skuController,
                          decoration: const InputDecoration(
                            labelText: 'Артикул (FL-000)',
                            prefixIcon: Icon(Icons.qr_code),
                          ),
                          validator: Validators.sku,
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
                                validator: (v) => Validators.decimalRange(
                                  v,
                                  min: 50,
                                  max: 1000000,
                                  label: 'Цена',
                                ),
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
                                validator: (v) => Validators.positiveInt(
                                  v,
                                  label: 'Количество стеблей',
                                ),
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
                                validator: (v) => Validators.nonNegativeInt(
                                  v,
                                  label: 'Всего на складе',
                                ),
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
                                validator: (v) => Validators.nonNegativeInt(
                                  v,
                                  label: 'Доступно',
                                ),
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

                        // Многие-к-одному: поставщик
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
                          validator: (v) =>
                              v == null ? 'Выберите поставщика' : null,
                        ),
                        const SizedBox(height: 16),

                        // Многие-ко-многим: категории
                        FormField<List<int>>(
                          initialValue: _categoryIds,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Выберите хотя бы одну категорию'
                              : null,
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
                                child: Text(
                                  widget.isEditing ? 'Сохранить' : 'Создать',
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
