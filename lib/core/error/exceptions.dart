class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'Network connection failed'});

  @override
  String toString() => 'NetworkException: $message';
}

class HardwareException implements Exception {
  final String message;

  const HardwareException({required this.message});

  @override
  String toString() => 'HardwareException: $message';
}
