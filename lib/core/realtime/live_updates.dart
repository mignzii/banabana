import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:banabana_b2b/core/api/api_client.dart';
import 'package:banabana_b2b/core/storage/storage_service.dart';
import 'package:banabana_b2b/features/auth/providers/auth_provider.dart';
import 'package:banabana_b2b/features/producer/providers/analytics_providers.dart';
import 'package:banabana_b2b/features/producer/providers/category_providers.dart';
import 'package:banabana_b2b/features/producer/providers/inventory_providers.dart';
import 'package:banabana_b2b/features/producer/providers/order_providers.dart';
import 'package:banabana_b2b/features/producer/providers/product_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/catalog_providers.dart';
import 'package:banabana_b2b/features/wholesaler/providers/wholesaler_order_providers.dart';

/// Groupes de données rafraîchis ensemble.
enum LiveTopic { orders, products, catalog }

/// Mise à jour en direct des données affichées.
///
/// Trois niveaux, du plus rapide au filet de sécurité :
/// 1. Socket.IO : le serveur émet un événement `change` à chaque modification
///    ({ entity, action, id }) et seul le groupe concerné est rechargé.
/// 2. Retour au premier plan : tout ce qui est affiché est rechargé.
/// 3. Rafraîchissement périodique tant que l'app est ouverte (plus espacé
///    quand le temps réel est connecté).
///
/// Seules les données déjà chargées par un écran sont rechargées
/// ([Ref.exists]) : rien n'est récupéré pour un autre rôle, et les listes
/// gardent leur contenu pendant le rechargement (pas d'écran de chargement).
class LiveUpdates with WidgetsBindingObserver {
  LiveUpdates(this._ref);

  final Ref _ref;
  io.Socket? _socket;
  String? _socketToken;
  DateTime? _lastTokenRenewal;
  StreamSubscription<String>? _tokenSub;
  Timer? _ordersTimer;
  Timer? _dataTimer;
  bool _started = false;
  bool _foreground = true;

  static const _ordersInterval = Duration(seconds: 15);
  static const _dataInterval = Duration(seconds: 60);
  static const _connectedInterval = Duration(seconds: 90);

  bool get isConnected => _socket?.connected ?? false;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _tokenSub = _ref
        .read(storageServiceProvider)
        .accessTokenChanges
        .listen(_onTokenChanged);
    _connectSocket();
    _scheduleTimers();
  }

  void stop() {
    if (!_started) return;
    _started = false;
    WidgetsBinding.instance.removeObserver(this);
    _tokenSub?.cancel();
    _tokenSub = null;
    _socketToken = null;
    _ordersTimer?.cancel();
    _dataTimer?.cancel();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasForeground = _foreground;
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground && !wasForeground) {
      refresh(LiveTopic.values);
      if (!isConnected) _socket?.connect();
      _scheduleTimers();
    } else if (!_foreground) {
      _ordersTimer?.cancel();
      _dataTimer?.cancel();
    }
  }

  void _scheduleTimers() {
    _ordersTimer?.cancel();
    _dataTimer?.cancel();
    if (!_started || !_foreground) return;
    final connected = isConnected;
    _ordersTimer = Timer.periodic(
      connected ? _connectedInterval : _ordersInterval,
      (_) => refresh([LiveTopic.orders]),
    );
    _dataTimer = Timer.periodic(
      connected ? _connectedInterval : _dataInterval,
      (_) => refresh([LiveTopic.products, LiveTopic.catalog]),
    );
  }

  Future<void> _connectSocket() async {
    final token = await _ref.read(storageServiceProvider).getAccessToken();
    if (!_started || token == null || _socket != null) return;
    _socketToken = token;
    final socket = io.io(
      '$apiOrigin/realtime',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(30000)
          .disableAutoConnect()
          .build(),
    );
    socket
      ..onConnect((_) {
        // Des changements ont pu être manqués pendant la déconnexion.
        refresh(LiveTopic.values);
        _scheduleTimers();
      })
      ..onDisconnect((_) => _scheduleTimers())
      ..onConnectError((error) async {
        final latest = await _ref.read(storageServiceProvider).getAccessToken();
        if (latest != null && latest != _socketToken) {
          // Jeton déjà rafraîchi entre-temps : nouvel essai avec celui-ci.
          _onTokenChanged(latest);
        } else if (_isUnauthorized(error)) {
          // Jeton expiré : le serveur refuse et ne relance pas la connexion.
          // On renouvelle le jeton (via l'API), ce qui déclenche la reconnexion.
          _renewToken();
        }
      })
      ..on('change', (data) => _onChange(data));
    _socket = socket;
    socket.connect();
  }

  bool _isUnauthorized(dynamic error) {
    final data = error is Map ? error['data'] : null;
    return '$error'.contains('UNAUTHORIZED') ||
        (data is Map && data['code'] == 'UNAUTHORIZED');
  }

  /// Un appel authentifié fait rafraîchir le jeton par l'intercepteur ; le
  /// nouveau jeton arrive ensuite dans [_onTokenChanged]. Au plus une fois
  /// toutes les 30 s pour ne pas boucler si la session est vraiment perdue.
  void _renewToken() {
    final now = DateTime.now();
    final last = _lastTokenRenewal;
    if (last != null && now.difference(last) < const Duration(seconds: 30)) return;
    _lastTokenRenewal = now;
    _ref.read(authProvider.notifier).refreshProfile();
  }

  /// Le serveur ne vérifie le jeton qu'à la connexion : après un
  /// rafraîchissement, on se reconnecte avec le nouveau jeton.
  void _onTokenChanged(String token) {
    if (!_started || token == _socketToken) return;
    _socketToken = token;
    final socket = _socket;
    if (socket == null) {
      _connectSocket();
      return;
    }
    socket.auth = {'token': token};
    if (socket.connected) socket.disconnect();
    socket.connect();
  }

  void _onChange(dynamic data) {
    final entity = data is Map ? '${data['entity']}' : '';
    final topics = switch (entity) {
      'order' || 'delivery' => [LiveTopic.orders],
      'product' || 'variant' || 'inventory' => [LiveTopic.products, LiveTopic.catalog],
      'category' => [LiveTopic.catalog],
      // Crédit livreur : ne concerne pas cette app.
      'driverCredit' => const <LiveTopic>[],
      _ => LiveTopic.values,
    };
    refresh(topics);
  }

  /// Recharge les données des groupes donnés qui sont affichées.
  void refresh(Iterable<LiveTopic> topics) {
    if (!_started) return;
    for (final topic in topics.toSet()) {
      switch (topic) {
        case LiveTopic.orders:
          if (_ref.exists(ordersNotifierProvider)) {
            _ref.read(ordersNotifierProvider.notifier).refresh();
          }
          if (_ref.exists(wholesalerOrdersProvider)) {
            _ref.read(wholesalerOrdersProvider.notifier).refresh();
          }
          _ref.invalidate(orderDetailProvider);
          _ref.invalidate(wholesalerOrderDetailProvider);
          _ref.invalidate(analyticsSummaryProvider);
        case LiveTopic.products:
          if (_ref.exists(productsNotifierProvider)) {
            _ref.read(productsNotifierProvider.notifier).refresh();
          }
          if (_ref.exists(inventoryNotifierProvider)) {
            _ref.read(inventoryNotifierProvider.notifier).refresh();
          }
          _ref.invalidate(productDetailProvider);
        case LiveTopic.catalog:
          _ref.invalidate(catalogResultProvider);
          _ref.invalidate(catalogProductDetailProvider);
          _ref.invalidate(shopCategoriesProvider);
          _ref.invalidate(allCategoriesProvider);
      }
    }
  }
}

/// Démarre les mises à jour en direct à la connexion, les arrête à la
/// déconnexion. À lire une fois depuis la racine de l'app.
final liveUpdatesProvider = Provider<LiveUpdates>((ref) {
  final live = LiveUpdates(ref);
  ref.listen<bool>(
    authProvider.select((s) => s.isAuthenticated),
    (_, isAuth) => isAuth ? live.start() : live.stop(),
    fireImmediately: true,
  );
  ref.onDispose(live.stop);
  return live;
});
