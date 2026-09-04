import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/anatomical_annotation_models.dart';

/// Interactive Specialty Clinical Action & 3D Cut-Plane Annotation Sheet.
/// 100% [StatelessWidget] architecture.
class SpecialtyClinicalActionSheet extends StatelessWidget {
  final SpecialtyPracticeVertical vertical;
  final String organOrBoneName;
  final ValueNotifier<AnatomicalPathologyType> selectedPathologyNotifier;
  final ValueNotifier<CutPlaneAnnotation?> cutPlaneNotifier;
  final ValueNotifier<double> severityNotifier;
  final ValueNotifier<Set<String>> selectedToothSurfacesNotifier;
  final ValueNotifier<double> jointGoniometerAngleNotifier;
  final ValueNotifier<List<String>> autoAttachedConsumablesNotifier;
  final void Function(AnatomicalConditionPayload payload)? onApplyCondition;

  SpecialtyClinicalActionSheet({
    super.key,
    required this.vertical,
    required this.organOrBoneName,
    ValueNotifier<AnatomicalPathologyType>? selectedPathologyNotifier,
    ValueNotifier<CutPlaneAnnotation?>? cutPlaneNotifier,
    ValueNotifier<double>? severityNotifier,
    ValueNotifier<Set<String>>? selectedToothSurfacesNotifier,
    ValueNotifier<double>? jointGoniometerAngleNotifier,
    ValueNotifier<List<String>>? autoAttachedConsumablesNotifier,
    this.onApplyCondition,
  })  : selectedPathologyNotifier = selectedPathologyNotifier ??
            ValueNotifier<AnatomicalPathologyType>(_defaultPathologyForVertical(vertical)),
        cutPlaneNotifier = cutPlaneNotifier ?? ValueNotifier<CutPlaneAnnotation?>(null),
        severityNotifier = severityNotifier ?? ValueNotifier<double>(0.75),
        selectedToothSurfacesNotifier = selectedToothSurfacesNotifier ?? ValueNotifier<Set<String>>({'O'}),
        jointGoniometerAngleNotifier = jointGoniometerAngleNotifier ?? ValueNotifier<double>(45.0),
        autoAttachedConsumablesNotifier = autoAttachedConsumablesNotifier ?? ValueNotifier<List<String>>([]);

  static AnatomicalPathologyType _defaultPathologyForVertical(SpecialtyPracticeVertical v) {
    switch (v) {
      case SpecialtyPracticeVertical.physiotherapyRehab:
        return AnatomicalPathologyType.amputationTruncation;
      case SpecialtyPracticeVertical.dentalClinic:
        return AnatomicalPathologyType.cariesCavity;
      case SpecialtyPracticeVertical.optometryClinic:
        return AnatomicalPathologyType.cornealAbrasion;
      case SpecialtyPracticeVertical.veterinaryClinic:
        return AnatomicalPathologyType.amputationTruncation;
      case SpecialtyPracticeVertical.clinic:
        return AnatomicalPathologyType.incisionalWound;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D16) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Sheet Header ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.scissors, size: 20, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$organOrBoneName • Clinical Annotation',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Vertical: ${vertical.name.toUpperCase()} (Cut-Planes & Specialty Procedures)',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 20),

          // ── Interactive Specialty Section ─────────────────────────
          _buildSpecialtyEditor(context, isDark),

          const SizedBox(height: 16),

          // ── Consumable Auto-Attachment Suggestion ───────────────────
          ValueListenableBuilder<List<String>>(
            valueListenable: autoAttachedConsumablesNotifier,
            builder: (context, consumables, _) {
              if (consumables.isEmpty) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shoppingCart, size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Auto-attached Consumables: ${consumables.join(", ")}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Action Buttons ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(LucideIcons.slice, size: 16),
                  label: const Text('Add Cut-Plane (50% Truncation)'),
                  onPressed: () {
                    cutPlaneNotifier.value = const CutPlaneAnnotation(
                      startNormalized: Offset(0.2, 0.5),
                      endNormalized: Offset(0.8, 0.5),
                      angleRadians: pi / 4,
                      label: 'Osteotomy / Amputation Line',
                    );
                    autoAttachedConsumablesNotifier.value = [
                      'Surgical Drape Pack (sterile)',
                      'Oscillating Saw Blade (fine)',
                      'Monofilament Suture Kit',
                    ];
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(LucideIcons.checkCheck, size: 16),
                label: const Text('Apply Annotation & Kit'),
                onPressed: () {
                  final payload = AnatomicalConditionPayload(
                    pathology: selectedPathologyNotifier.value,
                    severityScore: severityNotifier.value,
                    cutPlane: cutPlaneNotifier.value,
                    tiedProcedureCodes: autoAttachedConsumablesNotifier.value,
                    notes: 'Annotated via 3D Spatial Canvas for $organOrBoneName',
                  );
                  onApplyCondition?.call(payload);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyEditor(BuildContext context, bool isDark) {
    switch (vertical) {
      case SpecialtyPracticeVertical.physiotherapyRehab:
      case SpecialtyPracticeVertical.veterinaryClinic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Joint Goniometer & Truncation Cut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            ValueListenableBuilder<double>(
              valueListenable: jointGoniometerAngleNotifier,
              builder: (context, angle, _) {
                return Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: angle,
                        min: 0,
                        max: 180,
                        divisions: 36,
                        label: '${angle.toStringAsFixed(0)}° ROM',
                        onChanged: (val) => jointGoniometerAngleNotifier.value = val,
                      ),
                    ),
                    Text(
                      '${angle.toStringAsFixed(0)}° Flexion',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                );
              },
            ),
          ],
        );

      case SpecialtyPracticeVertical.dentalClinic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multi-Surface Tooth Polygon Selector (MODBL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            ValueListenableBuilder<Set<String>>(
              valueListenable: selectedToothSurfacesNotifier,
              builder: (context, surfaces, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['M', 'O', 'D', 'B', 'L'].map((s) {
                    final selected = surfaces.contains(s);
                    return FilterChip(
                      label: Text(s),
                      selected: selected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      onSelected: (val) {
                        final current = Set<String>.from(surfaces);
                        if (val) {
                          current.add(s);
                        } else {
                          current.remove(s);
                        }
                        selectedToothSurfacesNotifier.value = current;
                        if (current.length >= 3) {
                          autoAttachedConsumablesNotifier.value = [
                            '3-Surface Dental Composite Resin (A2)',
                            'Etch & Prime Bonding Agent',
                            'Polishing Diamond Bur',
                          ];
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );

      case SpecialtyPracticeVertical.optometryClinic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ophthalmic Caliper & Retinal Detachment Zone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            ValueListenableBuilder<double>(
              valueListenable: severityNotifier,
              builder: (context, severity, _) {
                return Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: severity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label: 'Cup/Disc: ${(severity).toStringAsFixed(1)}',
                        onChanged: (val) {
                          severityNotifier.value = val;
                          if (val > 0.6) {
                            autoAttachedConsumablesNotifier.value = [
                              'Visual Field (Humphrey) Diagnostic Fee',
                              'OCT Retinal Nerve Fiber Layer Scan',
                            ];
                          }
                        },
                      ),
                    ),
                    Text(
                      'C:D ${(severity).toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                );
              },
            ),
          ],
        );

      case SpecialtyPracticeVertical.clinic:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Surgical Caliper, Stenosis % & Incision Profiler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            ValueListenableBuilder<double>(
              valueListenable: severityNotifier,
              builder: (context, severity, _) {
                return Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: severity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label: '${(severity * 100).toStringAsFixed(0)}%',
                        onChanged: (val) {
                          severityNotifier.value = val;
                          if (val >= 0.7) {
                            autoAttachedConsumablesNotifier.value = [
                              'Vascular Balloon Angioplasty Catheter',
                              'Drug-Eluting Coronary Stent (3.0x18mm)',
                              'Sterile Angiography Pack',
                            ];
                          }
                        },
                      ),
                    ),
                    Text(
                      '${(severity * 100).toStringAsFixed(0)}% Occlusion',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                );
              },
            ),
          ],
        );
    }
  }
}
