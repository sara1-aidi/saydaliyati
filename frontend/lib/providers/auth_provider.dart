import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/app_user.dart';
import 'cart_provider.dart';
import 'ui_providers.dart';

/// null = nobody is signed in.
class AuthNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  ApiClient get _api => ref.read(apiClientProvider);

  Future<void> login(String email, String password) async {
    final data = await _api.post('/auth/login',
        auth: false, body: {'email': email, 'password': password});
    state = AppUser.fromJson(data as Map<String, dynamic>);
  }

  /// Creates a CLIENT account and signs the user in straight away.
  Future<void> register(String name, String email, String password) async {
    final data = await _api.post('/auth/register',
        auth: false, body: {'name': name, 'email': email, 'password': password});
    state = AppUser.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout'); // delete the session on the server
    } catch (_) {
      // even if the server is unreachable, sign out locally
    }
    _clearLocalState();
  }

  /// Called by ApiClient when the server says the token is no longer valid.
  void sessionExpired() => _clearLocalState();

  void _clearLocalState() {
    state = null;
    ref.invalidate(cartProvider);
    ref.invalidate(clientTabProvider);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    tokenReader: () => ref.read(authProvider)?.token,
    onUnauthorized: () => ref.read(authProvider.notifier).sessionExpired(),
  ),
);
