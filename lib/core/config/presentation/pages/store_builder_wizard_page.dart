import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../data/models/store_blueprint_model.dart';
import '../../domain/entities/industry_type.dart';
import '../../domain/entities/store_blueprint.dart';
import '../bloc/config_bloc.dart';
import '../bloc/config_event.dart';

class StoreBuilderWizardPage extends StatelessWidget {
  const StoreBuilderWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final storeNameController = TextEditingController(text: 'OmniTrack Enterprise Store');
    final branchNameController = TextEditingController(text: 'Main Flagship Branch');
    final currencyController = TextEditingController(text: 'EGP');
    final taxRateController = TextEditingController(text: '14.0');

    final selectedVerticalNotifier = ValueNotifier<IndustryVertical>(IndustryVertical.retail);
    final selectedSpecificIndustryNotifier = ValueNotifier<SpecificIndustry>(SpecificIndustry.grocerySupermarket);
    final selectedColorNotifier = ValueNotifier<String>('#6366F1');

    final brandColors = [
      {'name': 'Indigo Blue', 'hex': '#6366F1', 'color': const Color(0xFF6366F1)},
      {'name': 'Sky Cyan', 'hex': '#0284C7', 'color': const Color(0xFF0284C7)},
      {'name': 'Emerald Green', 'hex': '#10B981', 'color': const Color(0xFF10B981)},
      {'name': 'Crimson Red', 'hex': '#EF4444', 'color': const Color(0xFFEF4444)},
      {'name': 'Amber Gold', 'hex': '#F59E0B', 'color': const Color(0xFFF59E0B)},
      {'name': 'Teal Ocean', 'hex': '#0F766E', 'color': const Color(0xFF0F766E)},
      {'name': 'Purple Royal', 'hex': '#8B5CF6', 'color': const Color(0xFF8B5CF6)},
      {'name': 'Rose Pink', 'hex': '#EC4899', 'color': const Color(0xFFEC4899)},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 920),
            padding: const EdgeInsets.all(AppDimensions.space32),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: AppColors.borderDark, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ───────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(LucideIcons.sparkles, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Builder & Blueprint Setup Wizard',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimaryDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Select from 11 industry verticals & 41 tailored business templates with pre-configured toggles.',
                            style: TextStyle(fontSize: 13, color: AppColors.textMutedDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.borderDark, height: 40),

                // ── SECTION 1: STORE METADATA ────────────────────────────────
                const Row(
                  children: [
                    Icon(LucideIcons.store, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '1. Enterprise Profile & Regional Settings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _textField(
                        label: 'Store Business Name',
                        controller: storeNameController,
                        hint: 'e.g. Metro Supermarket',
                        icon: LucideIcons.building,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: _textField(
                        label: 'Branch / Facility Location',
                        controller: branchNameController,
                        hint: 'e.g. Heliopolis Branch',
                        icon: LucideIcons.mapPin,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        label: 'Currency Code',
                        controller: currencyController,
                        hint: 'e.g. EGP, USD, SAR',
                        icon: LucideIcons.banknote,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _textField(
                        label: 'Default VAT / Tax Rate (%)',
                        controller: taxRateController,
                        hint: '14.0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        icon: LucideIcons.percent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── SECTION 2: INDUSTRY VERTICALS (11 Categories) ────────────
                const Row(
                  children: [
                    Icon(LucideIcons.layoutGrid, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '2. Choose Industry Vertical (11 Categories)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ValueListenableBuilder<IndustryVertical>(
                  valueListenable: selectedVerticalNotifier,
                  builder: (context, selectedVertical, _) {
                    return GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: IndustryVertical.values.map((v) {
                        final isSelected = v == selectedVertical;
                        return _verticalCard(
                          vertical: v,
                          selected: isSelected,
                          onTap: () {
                            selectedVerticalNotifier.value = v;
                            // Automatically select first specific industry under this vertical
                            final firstSpecific = SpecificIndustry.values.firstWhere(
                              (s) => s.vertical == v,
                              orElse: () => SpecificIndustry.cashierPos,
                            );
                            selectedSpecificIndustryNotifier.value = firstSpecific;
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── SECTION 2B: SPECIFIC INDUSTRY TEMPLATES (41 Blueprints) ──
                ValueListenableBuilder<IndustryVertical>(
                  valueListenable: selectedVerticalNotifier,
                  builder: (context, selectedVertical, _) {
                    final specificList = SpecificIndustry.values
                        .where((s) => s.vertical == selectedVertical)
                        .toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.layers, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Specialized Blueprint Template (${specificList.length} Options)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder<SpecificIndustry>(
                          valueListenable: selectedSpecificIndustryNotifier,
                          builder: (context, selectedSpecific, _) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: specificList.map((spec) {
                                final isSelected = spec == selectedSpecific;
                                return ChoiceChip(
                                  label: Text(spec.label),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) {
                                      selectedSpecificIndustryNotifier.value = spec;
                                      // Suggest appropriate theme color
                                      if (spec.vertical == IndustryVertical.medical) {
                                        selectedColorNotifier.value = '#0284C7';
                                      } else if (spec.vertical == IndustryVertical.foodBeverage) {
                                        selectedColorNotifier.value = '#F59E0B';
                                      } else if (spec.vertical == IndustryVertical.beautyPersonalCare) {
                                        selectedColorNotifier.value = '#EC4899';
                                      } else if (spec.vertical == IndustryVertical.automotive) {
                                        selectedColorNotifier.value = '#EF4444';
                                      } else if (spec.vertical == IndustryVertical.eventsHospitality) {
                                        selectedColorNotifier.value = '#8B5CF6';
                                      }
                                    }
                                  },
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  backgroundColor: AppColors.surfaceDark,
                                  side: BorderSide(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.borderDark,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // ── SECTION 3: BRAND THEME COLOR ─────────────────────────────
                const Row(
                  children: [
                    Icon(LucideIcons.palette, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '3. Brand Accent Color & Dynamic Theme',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ValueListenableBuilder<String>(
                  valueListenable: selectedColorNotifier,
                  builder: (context, selectedHex, _) {
                    return Row(
                      children: brandColors.map((item) {
                        final hex = item['hex'] as String;
                        final color = item['color'] as Color;
                        final isSelected = hex == selectedHex;

                        return Expanded(
                          child: InkWell(
                            onTap: () => selectedColorNotifier.value = hex,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                border: Border.all(
                                  color: isSelected ? color : AppColors.borderDark,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // ── SECTION 4: LAUNCH BUTTON ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final name = storeNameController.text.trim();
                      if (name.isEmpty) return;

                      final branch = branchNameController.text.trim().isNotEmpty
                          ? branchNameController.text.trim()
                          : 'Main Branch';
                      final currency = currencyController.text.trim().isNotEmpty
                          ? currencyController.text.trim()
                          : 'EGP';
                      final taxRate = double.tryParse(taxRateController.text.trim()) ?? 14.0;
                      final vertical = selectedVerticalNotifier.value;
                      final specific = selectedSpecificIndustryNotifier.value;
                      final themeHex = selectedColorNotifier.value;

                      // Load base preset toggles
                      StoreBlueprint basePreset;
                      switch (specific) {
                        case SpecificIndustry.dentalClinic:
                          basePreset = StoreBlueprintModel.defaultDentalBlueprint();
                          break;
                        case SpecificIndustry.clinic:
                          basePreset = StoreBlueprintModel.defaultClinicBlueprint();
                          break;
                        case SpecificIndustry.restaurantDinein:
                        case SpecificIndustry.cafeCoffeeshop:
                        case SpecificIndustry.bakeryPatisserie:
                          basePreset = StoreBlueprintModel.defaultRestaurantBlueprint();
                          break;
                        case SpecificIndustry.hotelGuesthouse:
                          basePreset = StoreBlueprintModel.defaultHotelBlueprint();
                          break;
                        case SpecificIndustry.autoRepairGarage:
                          basePreset = StoreBlueprintModel.defaultAutoRepairBlueprint();
                          break;
                        case SpecificIndustry.realEstateAgency:
                          basePreset = StoreBlueprintModel.defaultRealEstateBlueprint();
                          break;
                        case SpecificIndustry.hairSalonBarbershop:
                        case SpecificIndustry.spaWellnessCenter:
                          basePreset = StoreBlueprintModel.defaultSalonBlueprint();
                          break;
                        case SpecificIndustry.gymFitnessCenter:
                          basePreset = StoreBlueprintModel.defaultGymBlueprint();
                          break;
                        case SpecificIndustry.pharmacy:
                          basePreset = StoreBlueprintModel.defaultPharmacyBlueprint();
                          break;
                        case SpecificIndustry.grocerySupermarket:
                          basePreset = StoreBlueprintModel.defaultSupermarketBlueprint();
                          break;
                        default:
                          basePreset = StoreBlueprintModel.defaultRetailBlueprint();
                      }

                      final blueprint = basePreset.copyWith(
                        storeName: name,
                        storeBranch: branch,
                        vertical: vertical,
                        specificIndustry: specific,
                        industryType: IndustryType.fromString(specific.id),
                        currency: currency,
                        taxRate: taxRate,
                        themeColorHex: themeHex,
                      );

                      context.read<ConfigBloc>().add(SaveStoreBlueprintEvent(blueprint));
                    },
                    icon: const Icon(LucideIcons.rocket, color: Colors.white, size: 20),
                    label: Text(
                      'Save Blueprint & Launch POS Workspace',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _verticalCard({
    required IndustryVertical vertical,
    required bool selected,
    required VoidCallback onTap,
  }) {
    IconData icon;
    switch (vertical) {
      case IndustryVertical.retail:
        icon = LucideIcons.shoppingBag;
        break;
      case IndustryVertical.medical:
        icon = LucideIcons.stethoscope;
        break;
      case IndustryVertical.foodBeverage:
        icon = LucideIcons.utensils;
        break;
      case IndustryVertical.beautyPersonalCare:
        icon = LucideIcons.sparkles;
        break;
      case IndustryVertical.automotive:
        icon = LucideIcons.car;
        break;
      case IndustryVertical.eventsHospitality:
        icon = LucideIcons.hotel;
        break;
      case IndustryVertical.fitnessSports:
        icon = LucideIcons.dumbbell;
        break;
      case IndustryVertical.professionalServices:
        icon = LucideIcons.briefcase;
        break;
      case IndustryVertical.educationTutoring:
        icon = LucideIcons.graduationCap;
        break;
      case IndustryVertical.homeTradeServices:
        icon = LucideIcons.wrench;
        break;
      case IndustryVertical.generalServices:
        icon = LucideIcons.calendarCheck;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderDark,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.textSecondaryDark),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vertical.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.white : AppColors.textPrimaryDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryDark),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
            prefixIcon: Icon(icon, size: 16, color: AppColors.textMutedDark),
            filled: true,
            fillColor: AppColors.surfaceDark,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
