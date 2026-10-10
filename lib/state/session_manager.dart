import 'dart:async';

import 'package:flutter/material.dart';

import 'auth_notifier.dart';

/// Управляет таймерами сессии:
///   1) Неактивность — 3 минуты без действий.
///   2) Общий срок сессии — 30 минут.
///
/// Диалог предупреждения показывает виджет `InactivityWatcher`,
/// который слушает этот менеджер через Provider.
class SessionManager extends ChangeNotifier {
  static const inactivityTimeout = Duration(minutes: 3);
  static const warningDuration = Duration(seconds: 30);
  static const maxSessionDuration = Duration(minutes: 30);

  final AuthNotifier _auth;

  Timer? _inactivityTimer;
  Timer? _sessionTimer;

  bool _shouldWarn = false;
  bool get shouldWarn => _shouldWarn;

  SessionManager(this._auth);

  void start() {
    _resetInactivityTimer();
    _startSessionTimer();
  }

  void stop() {
    _inactivityTimer?.cancel();
    _sessionTimer?.cancel();
    _inactivityTimer = null;
    _sessionTimer = null;
    _shouldWarn = false;
  }

  /// Вызывается при любом действии пользователя.
  void onUserActivity() {
    if (!_auth.isAuthenticated) return;
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _shouldWarn = false;
    _inactivityTimer = Timer(inactivityTimeout, () {
      _shouldWarn = true;
      notifyListeners();
      // Даём 30 секунд на реакцию
      _inactivityTimer = Timer(warningDuration, () {
        forceLogoutFromInactivity();
      });
    });
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(maxSessionDuration, () {
      forceLogout();
    });
  }

  /// Пользователь продлил сессию в диалоге.
  void prolongFromWarning() {
    _shouldWarn = false;
    notifyListeners();
    _resetInactivityTimer();
  }

  /// Пользователь отказался или время вышло.
  Future<void> forceLogoutFromInactivity() async {
    _shouldWarn = false;
    notifyListeners();
    await forceLogout();
  }

  Future<void> forceLogout() async {
    stop();
    await _auth.logout();
  }
}
