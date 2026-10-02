import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../utils/validators.dart';

class FloristFormScreen extends StatefulWidget {
  final int? id;
  const FloristFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<FloristFormScreen> createState() => _FloristFormScreenState();
}

class _FloristFormScreenState extends State<FloristFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _experienceController = TextEditingController();

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
    final repo = context.read<FloristRepository>();
    final f = await repo.findById(widget.id!);
    if (!mounted) return;
    if (f != null) {
      _firstNameController.text = f.firstName;
      _lastNameController.text = f.lastName;
      _cityController.text = f.city;
      _experienceController.text = '${f.experienceYear ?? ''}';
    }
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final repo = context.read<FloristRepository>();
    final expStr = _experienceController.text.trim();
    final exp = expStr.isEmpty ? null : int.tryParse(expStr);

    if (widget.isEditing) {
      final existing = await repo.findById(widget.id!);
      if (existing == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }
      await repo.update(existing.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        city: _cityController.text.trim(),
        experienceYear: exp,
      ));
    } else {
      await repo.create(Florist(
        id: 0,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        city: _cityController.text.trim(),
        experienceYear: exp,
      ));
    }

    if (!mounted) return;
    context.go('/florists');
  }

  @override
  Widget build(BuildContext context) {
    final rose = Theme.of(context).colorScheme.primary;
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Флорист')),
        body: Center(child: CircularProgressIndicator(color: rose)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing
            ? 'Редактирование флориста'
            : 'Новый флорист'),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/florists'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFFCE4EC),
              Color(0xFFEDE7F6),
            ],
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
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) => Validators.lengthRange(v,
                              min: 2, max: 40, label: 'Имя'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Фамилия',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => Validators.lengthRange(v,
                              min: 2, max: 40, label: 'Фамилия'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Город',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: (v) => Validators.lengthRange(v,
                              min: 2, max: 50, label: 'Город'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'В профессии с (год, необязательно)',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.isEmpty) return null;
                            final n = int.tryParse(s);
                            if (n == null) return 'Год должен быть числом';
                            if (n < 1950 || n > 2100) {
                              return 'Год от 1950 до 2100';
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
                                child: Text(widget.isEditing
                                    ? 'Сохранить'
                                    : 'Создать'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () => context.go('/florists'),
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