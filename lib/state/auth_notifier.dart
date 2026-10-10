import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_exceptions.dart';
import '../core/auth_api.dart';
import '../models/models.dart';

class AuthNotifier extends ChangeNotifier {
  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';

  final SharedPreferences _prefs;
  final AuthApi _api;

  AuthNotifier(this._prefs, this._api);

  AppUser? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _restored = false;

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null;
  bool get isRestored => _restored;

  bool has(Role role) => _user != null && _user!.role.level >= role.level;

  Future<void> restore() async {
    final access = _prefs.getString(_kAccess);
    final refresh = _prefs.getString(_kRefresh);
    _accessToken = access;
    _refreshToken = refresh;

    if (access == null) {
      _restored = true;
      notifyListeners();
      return;
    }

    try {
      _user = await _api.me();
    } on UnauthorizedException {
      if (refresh != null) {
        try {
          await refreshTokens();
        } catch (_) {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (_) {
      // Сервер недоступен: сессию не сбрасываем
    }

    _restored = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username, password);
    await _applyAuthResult(result);
  }

  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String fullName,
  }) async {
    final result = await _api.register(
      username: username,
      password: password,
      email: email,
      fullName: fullName,
    );
    await _applyAuthResult(result);
  }

  Future<void> _applyAuthResult(AuthResult r) async {
    _user = r.user;
    _accessToken = r.accessToken;
    _refreshToken = r.refreshToken;
    await _prefs.setString(_kAccess, r.accessToken);
    await _prefs.setString(_kRefresh, r.refreshToken);
    notifyListeners();
  }

  Future<void> refreshTokens() async {
    final rt = _refreshToken;
    if (rt == null) throw const UnauthorizedException();
    final result = await _api.refresh(rt);
    await _applyAuthResult(result);
  }

  Future<void> logout() async {
    final rt = _refreshToken;
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    notifyListeners();
    if (rt != null) {
      try {
        await _api.logout(rt);
      } catch (_) {}
    }
  }
}
