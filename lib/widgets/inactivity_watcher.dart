import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/session_manager.dart';
import 'inactivity_dialog.dart';

/// Оборачивает приложение. Слушает клавиатуру и мышь,
/// сбрасывает таймер неактивности при любом действии.
///
/// Когда `SessionManager.shouldWarn` становится true —
/// показывает диалог через свой BuildContext.
class InactivityWatcher extends StatefulWidget {
  final Widget child;
  const InactivityWatcher({super.key, required this.child});

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (mounted) {
      context.read<SessionManager>().onUserActivity();
    }
    return false;
  }

  void _onPointer() {
    if (mounted) {
      context.read<SessionManager>().onUserActivity();
    }
  }

  Future<void> _showWarningDialog(SessionManager manager) async {
    if (_dialogShowing) return;
    _dialogShowing = true;

    final result = await showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const InactivityDialog(secondsLeft: 30),
    );

    _dialogShowing = false;

    if (result == true) {
      manager.prolongFromWarning();
    } else {
      await manager.forceLogoutFromInactivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionManager>(
      builder: (context, manager, child) {
        if (manager.shouldWarn && !_dialogShowing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showWarningDialog(manager);
          });
        }
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _onPointer(),
          onPointerMove: (_) => _onPointer(),
          onPointerSignal: (_) => _onPointer(),
          child: widget.child,
        );
      },
    );
  }
}
