import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/notifiers.dart';
import '../repositories/repositories.dart';

class CustomerFormScreen extends StatefulWidget {
  final int? id;
  const CustomerFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _hasCard = false;
  final _cardNumberController = TextEditingController();
  final _cardDiscountController = TextEditingController();

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
    final repo = context.read<CustomerRepository>();
    final c = await repo.findById(widget.id!);
    if (!mounted) return;
    if (c != null) {
      _firstNameController.text = c.firstName;
      _lastNameController.text = c.lastName;
      _emailController.text = c.email;
      _phoneController.text = c.phone;
      if (c.card != null) {
        _hasCard = true;
        _cardNumberController.text = c.card!.number;
        _cardDiscountController.text = '${c.card!.discountPercent}';
      }
    }
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardDiscountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final repo = context.read<CustomerRepository>();
    final notifier = context.read<CustomerListNotifier>();
    final email = _emailController.text.trim();

    final exists = await notifier.emailExists(
      email,
      exceptId: widget.isEditing ? widget.id : null,
    );
    if (exists) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Этот email уже используется')),
      );
      return;
    }

    final card = _hasCard
        ? LoyaltyCard(
            number: _cardNumberController.text.trim(),
            discountPercent: int.tryParse(_cardDiscountController.text) ?? 0,
            issuedAt: DateTime.now(),
          )
        : null;

    if (widget.isEditing) {
      final existing = await repo.findById(widget.id!);
      if (existing == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }
      await repo.update(
        existing.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
          phone: _phoneController.text.trim(),
          card: card,
          clearCard: !_hasCard,
        ),
      );
    } else {
      await repo.create(
        Customer(
          id: 0,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
          phone: _phoneController.text.trim(),
          card: card,
        ),
      );
    }

    if (!mounted) return;
    context.go('/customers');
  }

  @override
  Widget build(BuildContext context) {
    final rose = Theme.of(context).colorScheme.primary;
    final lavender = Theme.of(context).colorScheme.secondary;

    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Покупатель')),
        body: Center(child: CircularProgressIndicator(color: rose)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Редактирование покупателя' : 'Новый покупатель',
        ),
        actions: [
          IconButton(
            tooltip: 'К списку',
            icon: const Icon(Icons.list),
            onPressed: () => context.go('/customers'),
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
              constraints: const BoxConstraints(maxWidth: 620),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Личные данные',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: rose,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите имя';
                            }
                            if (v.trim().length < 2) {
                              return 'Слишком короткое';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Фамилия',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите фамилию';
                            }
                            if (v.trim().length < 2) {
                              return 'Слишком короткая';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Введите email';
                            }
                            final re = RegExp(
                              r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$',
                            );
                            if (!re.hasMatch(v.trim())) {
                              return 'Неверный формат email';
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
                        const SizedBox(height: 32),
                        Divider(color: lavender.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.card_membership, color: rose),
                            const SizedBox(width: 8),
                            Text(
                              'Карта лояльности',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: rose,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _hasCard ? 'Есть' : 'Нет',
                              style: TextStyle(color: lavender),
                            ),
                            Switch(
                              value: _hasCard,
                              onChanged: (v) {
                                setState(() => _hasCard = v);
                                if (!v) {
                                  _cardNumberController.clear();
                                  _cardDiscountController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                        if (_hasCard) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cardNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Номер карты',
                              prefixIcon: Icon(Icons.credit_card),
                              hintText: 'LC-0001',
                            ),
                            validator: (v) {
                              if (!_hasCard) return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Введите номер карты';
                              }
                              if (!RegExp(r'^LC-\d{4}$').hasMatch(v.trim())) {
                                return 'Формат: LC-0000';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cardDiscountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Скидка, %',
                              prefixIcon: Icon(Icons.percent),
                              hintText: '5',
                            ),
                            validator: (v) {
                              if (!_hasCard) return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Введите скидку';
                              }
                              final n = int.tryParse(v.trim());
                              if (n == null) return 'Должно быть число';
                              if (n < 0 || n > 50) return 'От 0 до 50';
                              return null;
                            },
                          ),
                        ],
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
                              onPressed: () => context.go('/customers'),
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
