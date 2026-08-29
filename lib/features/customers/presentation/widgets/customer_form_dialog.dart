import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';

class CustomerFormDialog extends StatelessWidget {
  final Customer? customer;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController notesController;

  const CustomerFormDialog._({
    super.key,
    this.customer,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.notesController,
  });

  factory CustomerFormDialog({
    Key? key,
    Customer? customer,
    String? initialPhone,
    String? initialName,
  }) {
    return CustomerFormDialog._(
      key: key,
      customer: customer,
      nameController: TextEditingController(text: customer?.name ?? initialName ?? ''),
      phoneController: TextEditingController(text: customer?.phone ?? initialPhone ?? ''),
      addressController: TextEditingController(text: customer?.address ?? ''),
      notesController: TextEditingController(text: customer?.notes ?? ''),
    );
  }

  void _submit(BuildContext context) {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final notes = notesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the customer name.')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    final newCustomer = Customer(
      id: customer?.id ?? 'CUST-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone,
      address: address.isNotEmpty ? address : null,
      notes: notes.isNotEmpty ? notes : null,
      totalDebt: customer?.totalDebt ?? 0.0,
      loyaltyPoints: customer?.loyaltyPoints ?? 0,
      createdAt: customer?.createdAt ?? DateTime.now(),
    );

    context.read<CustomerBloc>().add(SaveCustomerEvent(newCustomer));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = customer != null;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    isEditing ? LucideIcons.userPen : LucideIcons.userPlus,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Text(
                  isEditing ? 'Edit Customer Profile' : 'Add New Customer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),

            // Name Field
            _buildTextField(
              label: 'Full Name *',
              controller: nameController,
              icon: LucideIcons.user,
              hint: 'e.g. Mohamed Ahmed',
            ),
            const SizedBox(height: AppDimensions.space12),

            // Phone Field
            _buildTextField(
              label: 'Phone Number *',
              controller: phoneController,
              icon: LucideIcons.phone,
              hint: 'e.g. 01012345678',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppDimensions.space12),

            // Address Field
            _buildTextField(
              label: 'Address (Optional)',
              controller: addressController,
              icon: LucideIcons.mapPin,
              hint: 'e.g. Building 12, Main Street, Cairo',
            ),
            const SizedBox(height: AppDimensions.space12),

            // Notes Field
            _buildTextField(
              label: 'Notes / Account Details (Optional)',
              controller: notesController,
              icon: LucideIcons.fileText,
              hint: 'e.g. VIP client, allows credit up to 2000 EGP',
              maxLines: 2,
            ),
            const SizedBox(height: AppDimensions.space24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.borderDark),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => _submit(context),
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: Text(
                      isEditing ? 'UPDATE CUSTOMER' : 'SAVE CUSTOMER',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedDark,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryDark),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 16, color: AppColors.textMutedDark),
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}
