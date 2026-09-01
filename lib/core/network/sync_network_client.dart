import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerHealthResult {
  final bool isOnline;
  final int latencyMs;
  final String? version;
  final int connectedClients;
  final String? errorMessage;

  const ServerHealthResult({
    required this.isOnline,
    required this.latencyMs,
    this.version,
    this.connectedClients = 0,
    this.errorMessage,
  });
}

class SyncNetworkClient {
  final http.Client _client;

  SyncNetworkClient({http.Client? client}) : _client = client ?? http.Client();

  /// Performs a live health ping to the specified server URL
  Future<ServerHealthResult> checkServerHealth(String baseUrl, {String? apiKey}) async {
    final cleanUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$cleanUrl/health');
    final stopwatch = Stopwatch()..start();

    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (apiKey != null && apiKey.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${apiKey.trim()}';
      }

      final response = await _client.get(uri, headers: headers).timeout(
            const Duration(seconds: 4),
          );
      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return ServerHealthResult(
            isOnline: true,
            latencyMs: stopwatch.elapsedMilliseconds,
            version: data['version']?.toString() ?? '1.0.0',
            connectedClients: (data['connectedTerminals'] as num?)?.toInt() ?? 0,
          );
        } catch (_) {
          return ServerHealthResult(
            isOnline: true,
            latencyMs: stopwatch.elapsedMilliseconds,
            version: '1.0.0',
          );
        }
      } else {
        return ServerHealthResult(
          isOnline: false,
          latencyMs: stopwatch.elapsedMilliseconds,
          errorMessage: 'Server returned HTTP ${response.statusCode}',
        );
      }
    } on TimeoutException {
      return const ServerHealthResult(
        isOnline: false,
        latencyMs: 0,
        errorMessage: 'Connection timed out (4000ms)',
      );
    } catch (e) {
      return ServerHealthResult(
        isOnline: false,
        latencyMs: 0,
        errorMessage: e.toString().replaceAll('SocketException: ', ''),
      );
    }
  }
}
