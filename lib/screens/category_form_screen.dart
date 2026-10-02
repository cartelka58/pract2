import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final repo = context.read<CategoryRepository>();
    if (widget.isEditing) {
      final existing = await repo.findById(widget.id!);
      if (existing == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }
      await repo.update(
        existing.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
      );
    } else {
      await repo.create(
        Category(
          id: 0,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
      );
    }

    if (!mounted) return;
    context.go('/categories');
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
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите название';
                            }
                            if (v.trim().length < 2) {
                              return 'Название слишком короткое';
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
                                child: Text(
                                  widget.isEditing ? 'Сохранить' : 'Создать',
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
