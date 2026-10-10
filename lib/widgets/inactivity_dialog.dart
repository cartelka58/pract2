import 'dart:async';
import 'package:flutter/material.dart';

/// Диалог «Вы ещё здесь?».
/// Показывается за N секунд до автоматического выхода.
/// Возвращает true — пользователь продлил сессию.
/// Возвращает false — пользователь согласился выйти.
/// Возвращает null — время вышло, выходим принудительно.
class InactivityDialog extends StatefulWidget {
  final int secondsLeft;
  const InactivityDialog({super.key, required this.secondsLeft});

  @override
  State<InactivityDialog> createState() => _InactivityDialogState();
}

class _InactivityDialogState extends State<InactivityDialog> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.secondsLeft;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        _timer?.cancel();
        Navigator.of(context).pop(null);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rose = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.timer, color: rose),
            const SizedBox(width: 8),
            const Text('Вы ещё здесь?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сессия завершится автоматически из-за неактивности.',
            ),
            const SizedBox(height: 12),
            Text(
              'Осталось: $_secondsLeft сек.',
              style: TextStyle(
                color: rose,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Выйти'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Продолжить'),
          ),
        ],
      ),
    );
  }
}