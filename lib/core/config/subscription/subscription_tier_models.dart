import 'package:equatable/equatable.dart';
import '../domain/entities/industry_type.dart';

/// Available subscription plan tiers for universal EMPOS tenant accounts.
enum SubscriptionPlanTier {
  free(
    'Free Tier',
    'Minimal entry-level operations: single terminal, offline sync, basic checkout & booking',
  ),
  basic(
    'Basic Operational Tier',
    'Core business operations: LAN multi-device sync, basic inventory, conflict guard & split payments',
  ),
  pro(
    'Professional Tier',
    'Full specialty capabilities: 3D clinical tools, FEFO tracking, multi-party splits, KDS & work orders',
  ),
  enterprise(
    'Enterprise Tier',
    'Unrestricted ecosystem access: auto-unlocks all existing and future capabilities by default',
  ),
  custom(
    'Custom Operator Tier',
    'Individually tailored capability set with custom super-admin overrides',
  );

  final String label;
  final String description;
  const SubscriptionPlanTier(this.label, this.description);

  int get rank {
    switch (this) {
      case SubscriptionPlanTier.free:
        return 0;
      case SubscriptionPlanTier.basic:
        return 1;
      case SubscriptionPlanTier.pro:
        return 2;
      case SubscriptionPlanTier.enterprise:
        return 3;
      case SubscriptionPlanTier.custom:
        return 4;
    }
  }

  bool isAtLeast(SubscriptionPlanTier other) {
    if (this == SubscriptionPlanTier.enterprise) return true;
    return rank >= other.rank;
  }
}

/// Granular functional categories cataloging gateable capabilities.
enum CapabilityCategory {
  dental3D(
    '3D Odontogram & Dental Clinical',
    'Interactive 3D vector canvases, 5-surface MODBL selectors, staged treatments & tooth charts',
  ),
  specialtyClinical(
    'Specialty Clinical & Medical Actions',
    'Cardiology calipers, ophthalmology dials, orthopedics ROM goniometers, burn calculators & vitals',
  ),
  diagnosticImaging(
    'Diagnostic Radiology & Lightbox',
    'DICOM/X-Ray image analyzers, contrast tools, caliper measurements & split views',
  ),
  laboratory(
    'Laboratory & Pathology Panels',
    'Bloodwork panels, specimen barcode tracking, critical range alerts & HL7 integration',
  ),
  scheduling(
    'Appointment Scheduling & Conflict Guard',
    'Calendar booking, provider timetables, [start, end) interval conflict prevention & queue kiosks',
  ),
  inventory(
    'Physical Inventory & FEFO Tracking',
    'Barcode stock, safety reorder alerts, drug batch FEFO expiry tracking & auto-depletions',
  ),
  finance(
    'Financial Ledger, POS & Commission Splits',
    'Multi-item checkout, customer debt ledgers, provider splits, shift drawer Z-reports & advance deductions',
  ),
  sync(
    'Real-Time LAN & Fleet Synchronization',
    'Local WebSocket sync daemon, offline queues, cloud tunnels, live telemetry & OTA pushes',
  ),
  hospitalityTableKds(
    'Hospitality, Floor Maps & KDS',
    'Visual table floor plans, kitchen display rails, course pacing, seat splitting & hotel folios',
  ),
  automotiveWorkOrder(
    'Automotive & Garage Services',
    'VIN barcode scanning, digital estimate approvals, labor time clocks & DVI inspections',
  ),
  beautyWellness(
    'Beauty, Salon & Wellness',
    'Stylist visual portfolios, hair color formulation cards, prepaid treatment series & deposits',
  ),
  fitnessMemberships(
    'Fitness, Gym & Sports',
    'Turnstile QR/NFC validation, membership renewal push alerts, PT punch-cards & waitlists',
  ),
  educationTutoring(
    'Education & Learning Academy',
    'Student attendance QR, prepaid lesson credit depletion & syllabus milestone tracking',
  ),
  fieldTradeServices(
    'Field Trades & Home Services',
    'GPS van dispatch, on-site mobile signatures, van truck inventory & job signoffs',
  ),
  professionalServices(
    'Professional Services & Legal',
    'Billable minute stopwatch, client trust retainers, escrow ledgers & matter document vaults',
  ),
  retailPos(
    'Retail & Supermarket Automation',
    'Barcode scale integration, customer loyalty point vouchers, shelf label printing & suspended carts',
  );

  final String label;
  final String description;
  const CapabilityCategory(this.label, this.description);
}

/// A discrete, gateable functional capability unit.
class CapabilityItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final CapabilityCategory category;
  final IndustryVertical? vertical;
  final String? blueprintId;
  final SubscriptionPlanTier minTier;
  final bool isRequiredCompliance;
  final List<String> tags;

  const CapabilityItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.vertical,
    this.blueprintId,
    this.minTier = SubscriptionPlanTier.basic,
    this.isRequiredCompliance = false,
    this.tags = const [],
  });

  /// Rule B: Case-insensitive search across name, id, category, vertical, and tags.
  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    final term = query.toLowerCase().trim();
    if (id.toLowerCase().contains(term)) return true;
    if (name.toLowerCase().contains(term)) return true;
    if (description.toLowerCase().contains(term)) return true;
    if (category.label.toLowerCase().contains(term)) return true;
    if (category.name.toLowerCase().contains(term)) return true;
    if (vertical?.label.toLowerCase().contains(term) == true) return true;
    if (vertical?.id.toLowerCase().contains(term) == true) return true;
    if (blueprintId?.toLowerCase().contains(term) == true) return true;
    for (final tag in tags) {
      if (tag.toLowerCase().contains(term)) return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category.name,
        'vertical': vertical?.id,
        'blueprintId': blueprintId,
        'minTier': minTier.name,
        'isRequiredCompliance': isRequiredCompliance,
        'tags': tags,
      };

  factory CapabilityItem.fromJson(Map<String, dynamic> json) {
    return CapabilityItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: CapabilityCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => CapabilityCategory.retailPos,
      ),
      vertical: json['vertical'] != null
          ? IndustryVertical.fromString(json['vertical'] as String)
          : null,
      blueprintId: json['blueprintId'] as String?,
      minTier: SubscriptionPlanTier.values.firstWhere(
        (t) => t.name == json['minTier'],
        orElse: () => SubscriptionPlanTier.basic,
      ),
      isRequiredCompliance: json['isRequiredCompliance'] as bool? ?? false,
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        vertical,
        blueprintId,
        minTier,
        isRequiredCompliance,
        tags,
      ];
}

/// Named subscription tier preset bundling default capabilities together.
class SubscriptionTierPreset extends Equatable {
  final SubscriptionPlanTier tier;
  final String name;
  final String description;
  final Set<String> includedCapabilityIds;
  final bool includesAllByDefault;
  final int maxTerminals;
  final int maxStaffAccounts;

  const SubscriptionTierPreset({
    required this.tier,
    required this.name,
    required this.description,
    required this.includedCapabilityIds,
    this.includesAllByDefault = false,
    this.maxTerminals = 1,
    this.maxStaffAccounts = 3,
  });

  /// Resolves whether a capability is included in this preset.
  /// For Enterprise, everything is unlocked by default unless explicitly omitted.
  bool isCapabilityIncluded(String capabilityId) {
    if (includesAllByDefault) return true;
    return includedCapabilityIds.contains(capabilityId);
  }

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'name': name,
        'description': description,
        'includedCapabilityIds': includedCapabilityIds.toList(),
        'includesAllByDefault': includesAllByDefault,
        'maxTerminals': maxTerminals,
        'maxStaffAccounts': maxStaffAccounts,
      };

  factory SubscriptionTierPreset.fromJson(Map<String, dynamic> json) {
    return SubscriptionTierPreset(
      tier: SubscriptionPlanTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionPlanTier.basic,
      ),
      name: json['name'] as String,
      description: json['description'] as String,
      includedCapabilityIds:
          (json['includedCapabilityIds'] as List? ?? []).map((e) => e.toString()).toSet(),
      includesAllByDefault: json['includesAllByDefault'] as bool? ?? false,
      maxTerminals: json['maxTerminals'] as int? ?? 1,
      maxStaffAccounts: json['maxStaffAccounts'] as int? ?? 3,
    );
  }

  @override
  List<Object?> get props => [
        tier,
        name,
        description,
        includedCapabilityIds,
        includesAllByDefault,
        maxTerminals,
        maxStaffAccounts,
      ];
}

/// Per-account subscription state with assigned tier and individual overrides.
class AccountSubscriptionProfile extends Equatable {
  final String accountId;
  final String businessName;
  final IndustryVertical vertical;
  final SubscriptionPlanTier assignedTier;
  final Map<String, bool> individualOverrides;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const AccountSubscriptionProfile({
    required this.accountId,
    required this.businessName,
    this.vertical = IndustryVertical.retail,
    this.assignedTier = SubscriptionPlanTier.basic,
    this.individualOverrides = const {},
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  /// Evaluates whether a capability is currently unlocked for this account.
  /// Evaluation Order:
  /// 1. If account is deactivated, all non-compliance capabilities are false.
  /// 2. If an individual override exists, the override value takes absolute precedence.
  /// 3. Otherwise, evaluates against the assigned tier preset.
  bool isCapabilityEnabled(
    String capabilityId, {
    required SubscriptionTierPreset preset,
    bool isRequiredCompliance = false,
  }) {
    if (!isActive && !isRequiredCompliance) return false;

    // Layered individual override takes precedence
    if (individualOverrides.containsKey(capabilityId)) {
      return individualOverrides[capabilityId]!;
    }

    // Fall back to preset inclusion
    return preset.isCapabilityIncluded(capabilityId);
  }

  /// Returns true if this capability has an explicit individual override.
  bool hasOverride(String capabilityId) => individualOverrides.containsKey(capabilityId);

  AccountSubscriptionProfile copyWith({
    String? accountId,
    String? businessName,
    IndustryVertical? vertical,
    SubscriptionPlanTier? assignedTier,
    Map<String, bool>? individualOverrides,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AccountSubscriptionProfile(
      accountId: accountId ?? this.accountId,
      businessName: businessName ?? this.businessName,
      vertical: vertical ?? this.vertical,
      assignedTier: assignedTier ?? this.assignedTier,
      individualOverrides: individualOverrides ?? this.individualOverrides,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'businessName': businessName,
        'vertical': vertical.id,
        'assignedTier': assignedTier.name,
        'individualOverrides': individualOverrides,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'metadata': metadata,
      };

  factory AccountSubscriptionProfile.fromJson(Map<String, dynamic> json) {
    return AccountSubscriptionProfile(
      accountId: json['accountId'] as String,
      businessName: json['businessName'] as String,
      vertical: IndustryVertical.fromString(json['vertical'] as String?),
      assignedTier: SubscriptionPlanTier.values.firstWhere(
        (t) => t.name == json['assignedTier'],
        orElse: () => SubscriptionPlanTier.basic,
      ),
      individualOverrides: (json['individualOverrides'] as Map? ?? {})
          .map((k, v) => MapEntry(k.toString(), v == true)),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      metadata: (json['metadata'] as Map? ?? {}).cast<String, dynamic>(),
    );
  }

  @override
  List<Object?> get props => [
        accountId,
        businessName,
        vertical,
        assignedTier,
        individualOverrides,
        isActive,
        createdAt,
        updatedAt,
        metadata,
      ];
}
