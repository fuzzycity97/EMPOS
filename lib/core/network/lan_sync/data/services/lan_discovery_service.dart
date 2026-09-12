import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DiscoveredHost {
  final String id;
  final String role;
  final String ip;
  final int port;
  final DateTime lastSeen;

  const DiscoveredHost({
    required this.id,
    required this.role,
    required this.ip,
    required this.port,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'ip': ip,
        'port': port,
        'lastSeen': lastSeen.toIso8601String(),
      };

  factory DiscoveredHost.fromJson(Map<String, dynamic> json) => DiscoveredHost(
        id: json['id'] as String? ?? 'host-server',
        role: json['role'] as String? ?? 'Hub Host',
        ip: json['ip'] as String? ?? '127.0.0.1',
        port: json['port'] as int? ?? 9090,
        lastSeen: DateTime.now(),
      );
}

/// UDP Broadcast Beacon & Discovery Scanner for Zero-Config EMPOS LAN Sync
class LanDiscoveryService {
  static const int discoveryPort = 9091;
  static const String _beaconPrefix = 'EMPOS_BEACON:';

  RawDatagramSocket? _broadcastSocket;
  RawDatagramSocket? _listenSocket;
  Timer? _beaconTimer;
  Timer? _pruneTimer;

  final Map<String, DiscoveredHost> _discoveredHosts = {};
  final StreamController<List<DiscoveredHost>> _hostsController =
      StreamController<List<DiscoveredHost>>.broadcast();

  Stream<List<DiscoveredHost>> get discoveredHostsStream => _hostsController.stream;
  List<DiscoveredHost> get discoveredHosts => _discoveredHosts.values.toList();

  /// Starts broadcasting periodic host presence beacons to the local subnet
  Future<void> startHostBeacon({
    required String hostId,
    required String hostRole,
    required String hostIp,
    int port = 9090,
  }) async {
    await stopHostBeacon();

    try {
      _broadcastSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _broadcastSocket!.broadcastEnabled = true;

      final payload = jsonEncode({
        'id': hostId,
        'role': hostRole,
        'ip': hostIp,
        'port': port,
      });
      final beaconData = utf8.encode('$_beaconPrefix$payload');

      void sendBeacon() {
        if (_broadcastSocket == null) return;
        try {
          _broadcastSocket!.send(
            beaconData,
            InternetAddress('255.255.255.255'),
            discoveryPort,
          );
        } catch (_) {}
      }

      // Send initial beacon immediately, then every 3 seconds
      sendBeacon();
      _beaconTimer = Timer.periodic(const Duration(seconds: 3), (_) => sendBeacon());
    } catch (e) {
      debugPrint('LanDiscoveryService: Unable to start UDP beacon: $e');
    }
  }

  /// Stops broadcasting host beacons
  Future<void> stopHostBeacon() async {
    _beaconTimer?.cancel();
    _beaconTimer = null;
    _broadcastSocket?.close();
    _broadcastSocket = null;
  }

  /// Starts listening for host presence beacons from other EMPOS stations on LAN
  Future<void> startListening() async {
    await stopListening();

    try {
      _listenSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: true,
      );

      _listenSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _listenSocket?.receive();
          if (datagram != null) {
            _handleIncomingDatagram(datagram);
          }
        }
      });

      // Periodically prune stale hosts not seen in 8 seconds
      _pruneTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        final now = DateTime.now();
        bool changed = false;
        _discoveredHosts.removeWhere((key, host) {
          if (now.difference(host.lastSeen).inSeconds > 8) {
            changed = true;
            return true;
          }
          return false;
        });
        if (changed && !_hostsController.isClosed) {
          _hostsController.add(discoveredHosts);
        }
      });
    } catch (e) {
      debugPrint('LanDiscoveryService: Unable to bind discovery listener: $e');
    }
  }

  void _handleIncomingDatagram(Datagram datagram) {
    try {
      final msg = utf8.decode(datagram.data).trim();
      if (msg.startsWith(_beaconPrefix)) {
        final jsonStr = msg.substring(_beaconPrefix.length);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final host = DiscoveredHost.fromJson(map);

        final key = '${host.ip}:${host.port}';
        _discoveredHosts[key] = host;

        if (!_hostsController.isClosed) {
          _hostsController.add(discoveredHosts);
        }
      }
    } catch (_) {}
  }

  /// Stops listening for beacons and clears discovered hosts
  Future<void> stopListening() async {
    _pruneTimer?.cancel();
    _pruneTimer = null;
    _listenSocket?.close();
    _listenSocket = null;
    _discoveredHosts.clear();
  }

  void dispose() {
    stopHostBeacon();
    stopListening();
    if (!_hostsController.isClosed) {
      _hostsController.close();
    }
  }
}
