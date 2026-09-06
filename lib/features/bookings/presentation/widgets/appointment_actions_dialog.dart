import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../clinic/presentation/bloc/clinic_bloc.dart';
import '../../../clinic/presentation/bloc/clinic_event.dart';
import '../../domain/entities/booking_item.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';

/// Interactive modal for inspecting and performing operations on an appointment slot.
/// Supports 1-click Check-in to Lobby Queue (ClinicBloc integration) and Appointment Cancellation.
/// 100% [StatelessWidget].
class AppointmentActionsDialog extends StatelessWidget {
  final BookingItem booking;
  final BookingBloc bookingBloc;
  final VoidCallback? onAppointmentUpdated;

  const AppointmentActionsDialog({
    super.key,
    required this.booking,
    required this.bookingBloc,
    this.onAppointmentUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.calendarCheck2,
                      color: _getStatusColor(booking.status),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل الموعد والخدمة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Appointment Details & Reception Actions',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(booking.status),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white54 : Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Patient & Service Info Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: LucideIcons.user,
                      label: 'المريض / Patient',
                      value: booking.customerName,
                      valueStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      icon: LucideIcons.phone,
                      label: 'رقم الهاتف / Phone',
                      value: booking.customerPhone?.isNotEmpty == true ? booking.customerPhone! : 'غير مسجل',
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      icon: LucideIcons.stethoscope,
                      label: 'الطبيب / Doctor',
                      value: booking.resourceName.isNotEmpty ? booking.resourceName : booking.resourceId,
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      icon: LucideIcons.clipboardList,
                      label: 'الخدمة / Procedure',
                      value: booking.serviceName,
                      valueColor: AppColors.primary,
                      isDark: isDark,
                    ),
                    const Divider(height: 16),
                    _buildInfoRow(
                      icon: LucideIcons.clock,
                      label: 'الموعد / Time Slot',
                      value:
                          '${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')} - ${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')} (${booking.startTime.year}-${booking.startTime.month.toString().padLeft(2, '0')}-${booking.startTime.day.toString().padLeft(2, '0')})',
                      isDark: isDark,
                    ),
                    if (booking.notes != null && booking.notes!.trim().isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildInfoRow(
                        icon: LucideIcons.fileText,
                        label: 'ملاحظات / Complaint',
                        value: booking.notes!,
                        isDark: isDark,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  // 1-Click Check In to Clinic Lobby
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                      ),
                      onPressed: () {
                        _checkInPatientToLobby(context);
                      },
                      icon: const Icon(LucideIcons.logIn, size: 18),
                      label: const Text(
                        'دخول صالة الانتظار (Check In)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Cancel / Delete Booking
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                      ),
                      onPressed: () {
                        _cancelBooking(context);
                      },
                      icon: const Icon(LucideIcons.calendarX2, size: 18),
                      label: const Text(
                        'إلغاء الحجز',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkInPatientToLobby(BuildContext context) {
    try {
      final clinicBloc = context.read<ClinicBloc>();

      clinicBloc.add(
        CheckInPatientEvent(
          patientId: booking.customerOrPatientId,
          patientName: booking.customerName,
          phone: booking.customerPhone ?? '',
          doctorName: booking.resourceName.isNotEmpty ? booking.resourceName : 'Dr. Sarah Connor',
          chiefComplaint: booking.serviceName + (booking.notes != null && booking.notes!.isNotEmpty ? ' - ${booking.notes}' : ''),
        ),
      );

      // Create new booking with checkedIn status
      final updatedBooking = BookingItem(
        id: booking.id,
        customerOrPatientId: booking.customerOrPatientId,
        customerName: booking.customerName,
        customerPhone: booking.customerPhone,
        resourceId: booking.resourceId,
        resourceName: booking.resourceName,
        serviceName: booking.serviceName,
        startTime: booking.startTime,
        endTime: booking.endTime,
        status: BookingStatus.checkedIn,
        notes: booking.notes,
        createdAt: booking.createdAt,
      );
      bookingBloc.add(CreateBookingEvent(updatedBooking));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('تم تحويل المريض "${booking.customerName}" إلى صالة الانتظار بنجاح!'),
            ],
          ),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
      onAppointmentUpdated?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء تسجيل الدخول: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _cancelBooking(BuildContext context) {
    bookingBloc.add(CancelBookingEvent(booking.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إلغاء موعد "${booking.customerName}"'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
    onAppointmentUpdated?.call();
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
    Color? valueColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : AppColors.textSecondaryLight),
        const SizedBox(width: 10),
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle ??
                TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? (isDark ? Colors.white : AppColors.textPrimaryLight),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final color = _getStatusColor(status);
    final text = _getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.amber;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return AppColors.emerald;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.redAccent;
    }
  }

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'قيد الانتظار (Pending)';
      case BookingStatus.confirmed:
        return 'مؤكد (Confirmed)';
      case BookingStatus.checkedIn:
        return 'بالانتظار (Checked In)';
      case BookingStatus.completed:
        return 'مكتمل (Completed)';
      case BookingStatus.cancelled:
        return 'ملغي (Cancelled)';
    }
  }
}
