import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class SupplierFormScreen extends StatefulWidget {
  final int? id;
  const SupplierFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  Map<String, String> _serverErrors = {};
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _load();
    } else {
      _initialized = true;
    }
  }

  Future<void> _load() async {
    final repo = context.read<SupplierRepository>();
    final s = await repo.findById(widget.id!);
    if (!mounted) return;
    if (s != null) {
      _nameController.text = s.name;
      _phoneController.text = s.phone;
      _cityController.text = s.city;
    }
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverErrors = {});
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final repo = context.read<SupplierRepository>();
    final supplier = Supplier(
      id: widget.id ?? 0,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        await repo.update(supplier);
      } else {
        await repo.create(supplier);
      }
      if (!mounted) return;
      context.go('/suppliers');
    } on ValidationException catch (e) {
      if (!mounted) return;
      setState(() => _serverErrors = e.errors);
      _formKey.currentState!.validate();
    } on ConflictException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message);
    } on ApiException catch (e) {
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
        appBar: AppBar(title: const Text('Поставщик')),
        body: Center(child: CircularProgressIndicator(color: rose)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование поставщика' : 'Новый поставщик',
        ),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/suppliers'),
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Название',
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (v) {
                            final server = _serverErrors['name'];
                            if (server != null) return server;
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите название';
                            }
                            if (v.trim().length < 2) {
                              return 'Слишком короткое';
                            }
                            if (v.trim().length > 100) {
                              return 'Не более 100 символов';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Телефон',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (v) {
                            final server = _serverErrors['phone'];
                            if (server != null) return server;
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите телефон';
                            }
                            if (!RegExp(
                              r'^\+?[0-9\s\-()]{7,20}$',
                            ).hasMatch(v.trim())) {
                              return 'Неверный формат';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Город',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: (v) {
                            final server = _serverErrors['city'];
                            if (server != null) return server;
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите город';
                            }
                            if (v.trim().length > 50) {
                              return 'Не более 50 символов';
                            }
                            return null;
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
                              onPressed: () => context.go('/suppliers'),
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
