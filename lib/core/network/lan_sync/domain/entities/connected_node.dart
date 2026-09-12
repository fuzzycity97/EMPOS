import 'package:equatable/equatable.dart';

class ConnectedNode extends Equatable {
  final String id;
  final String role;
  final String ipAddress;
  final DateTime connectedAt;
  final String appName;

  final String? profession;

  ConnectedNode({
    required this.id,
    required this.role,
    required this.ipAddress,
    DateTime? connectedAt,
    String? appName,
    this.profession,
  })  : connectedAt = connectedAt ?? DateTime.now(),
        appName = appName ?? _inferAppName(role, profession);

  static String _inferAppName(String role, [String? profession]) {
    final r = role.toLowerCase();
    final p = (profession ?? '').toLowerCase();

    if (p.contains('ophthalm') || p.contains('eye') || r.contains('ophthalm') || r.contains('eye')) {
      return 'EMPOS Ophthalmology & Eye Care Suite';
    }
    if (p.contains('ortho') || p.contains('bone') || r.contains('ortho') || r.contains('bone')) {
      return 'EMPOS Orthopedic & Spine Center';
    }
    if (p.contains('cardio') || p.contains('heart') || r.contains('cardio') || r.contains('heart')) {
      return 'EMPOS Cardiology & Heart Suite';
    }
    if (p.contains('derma') || p.contains('skin') || r.contains('derma') || r.contains('skin')) {
      return 'EMPOS Dermatology & Skin Suite';
    }
    if (p.contains('physio') || p.contains('rehab') || r.contains('physio') || r.contains('rehab')) {
      return 'EMPOS Physiotherapy & Rehab Suite';
    }
    if (p.contains('gastro') || p.contains('digest') || r.contains('gastro') || r.contains('digest')) {
      return 'EMPOS Gastroenterology & Endoscopy Suite';
    }
    if (p.contains('dental') || p.contains('tooth') || r.contains('dental') || r.contains('tooth')) {
      return 'EMPOS Dental & Orthodontic Suite';
    }
    if (p.contains('ent') || p.contains('rhino') || r.contains('ent') || r.contains('rhino')) {
      return 'EMPOS ENT & Sinus Suite';
    }
    if (p.contains('neuro') || r.contains('neuro')) {
      return 'EMPOS Neurology & Neurosurgery Suite';
    }
    if (p.contains('pulmon') || p.contains('lung') || r.contains('pulmon') || r.contains('lung')) {
      return 'EMPOS Pulmonology & Respiratory Suite';
    }
    if (p.contains('uro') || r.contains('uro')) {
      return 'EMPOS Urology & Men\'s Health Suite';
    }
    if (p.contains('obgyn') || p.contains('gyne') || r.contains('obgyn') || r.contains('gyne')) {
      return 'EMPOS OB/GYN & Women\'s Health Suite';
    }

    if (r.contains('doctor') || r.contains('clinic')) return 'EMPOS Clinical / Dental Suite';
    if (r.contains('pos') || r.contains('cashier')) return 'EMPOS Retail POS Register';
    if (r.contains('recept')) return 'EMPOS Reception & Queue Desk';
    if (r.contains('host') || r.contains('server') || r.contains('hub')) return 'EMPOS Central Store Server';
    if (r.contains('god') || r.contains('admin') || r.contains('tech')) {
      return 'EMPOS Technician Provisioning Tool';
    }
    return 'EMPOS Universal Station';
  }

  factory ConnectedNode.fromJson(Map<String, dynamic> json) {
    final role = json['role']?.toString() ?? 'station';
    final profession = json['profession']?.toString() ?? json['specificIndustry']?.toString();
    return ConnectedNode(
      id: json['id']?.toString() ?? '',
      role: role,
      ipAddress: json['ipAddress']?.toString() ?? json['ip']?.toString() ?? '127.0.0.1',
      connectedAt: DateTime.tryParse(json['connectedAt']?.toString() ?? '') ?? DateTime.now(),
      appName: json['appName']?.toString() ?? _inferAppName(role, profession),
      profession: profession,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'ipAddress': ipAddress,
      'connectedAt': connectedAt.toIso8601String(),
      'appName': appName,
      if (profession != null) 'profession': profession,
    };
  }

  ConnectedNode copyWith({
    String? id,
    String? role,
    String? ipAddress,
    DateTime? connectedAt,
    String? appName,
    String? profession,
  }) {
    return ConnectedNode(
      id: id ?? this.id,
      role: role ?? this.role,
      ipAddress: ipAddress ?? this.ipAddress,
      connectedAt: connectedAt ?? this.connectedAt,
      appName: appName ?? this.appName,
      profession: profession ?? this.profession,
    );
  }

  @override
  List<Object?> get props => [id, role, ipAddress, connectedAt, appName, profession];
}
