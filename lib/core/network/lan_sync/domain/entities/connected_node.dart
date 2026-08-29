import 'package:equatable/equatable.dart';

class ConnectedNode extends Equatable {
  final String id;
  final String role;
  final String ipAddress;
  final DateTime connectedAt;

  ConnectedNode({
    required this.id,
    required this.role,
    required this.ipAddress,
    DateTime? connectedAt,
  }) : connectedAt = connectedAt ?? DateTime.now();

  factory ConnectedNode.fromJson(Map<String, dynamic> json) {
    return ConnectedNode(
      id: json['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'station',
      ipAddress: json['ipAddress']?.toString() ?? json['ip']?.toString() ?? '127.0.0.1',
      connectedAt: DateTime.tryParse(json['connectedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'ipAddress': ipAddress,
      'connectedAt': connectedAt.toIso8601String(),
    };
  }

  ConnectedNode copyWith({
    String? id,
    String? role,
    String? ipAddress,
    DateTime? connectedAt,
  }) {
    return ConnectedNode(
      id: id ?? this.id,
      role: role ?? this.role,
      ipAddress: ipAddress ?? this.ipAddress,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  @override
  List<Object?> get props => [id, role, ipAddress, connectedAt];
}
