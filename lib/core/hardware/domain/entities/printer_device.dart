import 'package:equatable/equatable.dart';

class PrinterDevice extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final bool isConnected;

  const PrinterDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.port = 9100,
    this.isConnected = false,
  });

  PrinterDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    int? port,
    bool? isConnected,
  }) {
    return PrinterDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [id, name, ipAddress, port, isConnected];
}
