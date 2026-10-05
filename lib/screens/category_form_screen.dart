import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class CategoryFormScreen extends StatefulWidget {
  final int? id;
  const CategoryFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

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
    final repo = context.read<CategoryRepository>();
    final c = await repo.findById(widget.id!);
    if (!mounted) return;
    if (c != null) {
      _nameController.text = c.name;
      _descriptionController.text = c.description;
    }
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _serverErrors = {});
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final repo = context.read<CategoryRepository>();
    final category = Category(
      id: widget.id ?? 0,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        await repo.update(category);
      } else {
        await repo.create(category);
      }
      if (!mounted) return;
      context.go('/categories');
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
        appBar: AppBar(title: const Text('Категория')),
        body: Center(child: CircularProgressIndicator(color: rose)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование категории' : 'Новая категория',
        ),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/categories'),
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
                            prefixIcon: Icon(Icons.category),
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
                            if (v.trim().length > 50) {
                              return 'Не более 50 символов';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Описание',
                            prefixIcon: Icon(Icons.description),
                          ),
                          validator: (v) {
                            final server = _serverErrors['description'];
                            if (server != null) return server;
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите описание';
                            }
                            if (v.trim().length > 200) {
                              return 'Не более 200 символов';
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
                              onPressed: () => context.go('/categories'),
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
