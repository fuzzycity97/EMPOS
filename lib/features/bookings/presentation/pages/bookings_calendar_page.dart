import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/industry_components/universal_calendar_grid_widget.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../clinic/data/datasources/clinic_local_data_source.dart';
import '../../../clinic/domain/entities/doctor_roster.dart';
import '../../../clinic/presentation/widgets/doctor_roster_manager_dialog.dart';
import '../../domain/entities/booking_item.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/appointment_actions_dialog.dart';
import '../widgets/clinical_booking_dialog.dart';

/// Professional Clinical Schedule & Booking Page.
/// Fully responsive across Mobile, Tablet, Desktop, and Web.
/// Integrates Doctor Rosters, Appointment Booking, and Check-In to Clinic Lobby.
/// 100% [StatelessWidget].
class BookingsCalendarPage extends StatelessWidget {
  final BookingBloc? bloc;

  const BookingsCalendarPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    final bookingBloc = bloc ?? context.read<BookingBloc>();
    final selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());
    final doctorFilterNotifier = ValueNotifier<String>('ALL');

    // Local rosters from ClinicLocalDataSource
    final clinicDataSource = sl<ClinicLocalDataSource>();
    final doctorRostersNotifier = ValueNotifier<List<DoctorRoster>>(
      List<DoctorRoster>.from(DoctorRoster.defaultRosters),
    );

    // Asynchronously load saved rosters from local storage
    clinicDataSource.getDoctorRosters().then((saved) {
      if (saved.isNotEmpty) {
        doctorRostersNotifier.value = List<DoctorRoster>.from(saved);
      }
    });

    return BlocBuilder<BookingBloc, BookingState>(
      bloc: bookingBloc,
      builder: (context, state) {
        if (state is BookingInitial || state is BookingLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BookingError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => bookingBloc.add(const LoadBookingsEvent()),
                    child: const Text('إعادة المحاولة / Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final loaded = state as BookingLoaded;

        return ValueListenableBuilder<DateTime>(
          valueListenable: selectedDateNotifier,
          builder: (context, selectedDate, _) {
            return ValueListenableBuilder<List<DoctorRoster>>(
              valueListenable: doctorRostersNotifier,
              builder: (context, rosters, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: doctorFilterNotifier,
                  builder: (context, selectedDoctorFilter, _) {
                    final filteredDoctors = selectedDoctorFilter == 'ALL'
                        ? rosters
                        : rosters.where((d) => d.id == selectedDoctorFilter).toList();

                    final isDark = Theme.of(context).brightness == Brightness.dark;

                    return Scaffold(
                      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Responsive Navigation Bar
                          _buildTopBar(
                            context: context,
                            bookingBloc: bookingBloc,
                            selectedDate: selectedDate,
                            selectedDateNotifier: selectedDateNotifier,
                            rosters: rosters,
                            doctorRostersNotifier: doctorRostersNotifier,
                            clinicDataSource: clinicDataSource,
                            scheduledCount: loaded.bookings.length,
                            isDark: isDark,
                          ),

                          // Calendar Grid View
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(AppDimensions.space16),
                              child: UniversalCalendarGridWidget(
                                bookings: loaded.bookings,
                                selectedDate: selectedDate,
                                doctors: filteredDoctors,
                                onDoctorSlotSelected: (doc, slotTime) {
                                  _openBookingModal(
                                    context: context,
                                    bookingBloc: bookingBloc,
                                    selectedDate: selectedDate,
                                    rosters: rosters,
                                    preselectedDoctor: doc,
                                    initialSlotTime: slotTime,
                                  );
                                },
                                onBookingTapped: (booking) {
                                  _openAppointmentDetails(
                                    context: context,
                                    booking: booking,
                                    bookingBloc: bookingBloc,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopBar({
    required BuildContext context,
    required BookingBloc bookingBloc,
    required DateTime selectedDate,
    required ValueNotifier<DateTime> selectedDateNotifier,
    required List<DoctorRoster> rosters,
    required ValueNotifier<List<DoctorRoster>> doctorRostersNotifier,
    required ClinicLocalDataSource clinicDataSource,
    required int scheduledCount,
    required bool isDark,
  }) {
    // Current user role check for RBAC
    final authState = context.watch<AuthBloc>().state;
    final userRole = authState is AuthAuthenticated ? authState.user.role : UserRole.admin;
    final isManagerOrAdmin = userRole == UserRole.admin || userRole == UserRole.manager;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 750;

          if (isNarrow) {
            // Mobile / Narrow split view
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'المواعيد والجدول ($scheduledCount)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    if (isManagerOrAdmin)
                      IconButton(
                        tooltip: 'تعديل جداول الأطباء (Manager)',
                        icon: const Icon(LucideIcons.userCog, color: Colors.blueAccent),
                        onPressed: () => _openRosterManager(
                          context: context,
                          doctorRostersNotifier: doctorRostersNotifier,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildDateSelector(context, bookingBloc, selectedDate, selectedDateNotifier, isDark),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _openBookingModal(
                        context: context,
                        bookingBloc: bookingBloc,
                        selectedDate: selectedDate,
                        rosters: rosters,
                      ),
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('حجز موعد', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            );
          }

          // Desktop / Tablet view - Zero RenderFlex Overflow
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title & Counter
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.calendarDays, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'جدول مواعيد العيادة وحجوزات المرضى',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'Clinic Roster & Patient Bookings ($scheduledCount موعد مسجل)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Date Navigator + Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDateSelector(context, bookingBloc, selectedDate, selectedDateNotifier, isDark),
                  const SizedBox(width: 12),

                  // Manager/Admin Doctor Roster Switchboard Button
                  if (isManagerOrAdmin) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                        side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _openRosterManager(
                        context: context,
                        doctorRostersNotifier: doctorRostersNotifier,
                      ),
                      icon: const Icon(LucideIcons.userCog, size: 16, color: Colors.blueAccent),
                      label: const Text(
                        'جداول وشفتات الأطباء',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Book Appointment Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _openBookingModal(
                      context: context,
                      bookingBloc: bookingBloc,
                      selectedDate: selectedDate,
                      rosters: rosters,
                    ),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text(
                      'حجز موعد مريض',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    BookingBloc bookingBloc,
    DateTime selectedDate,
    ValueNotifier<DateTime> selectedDateNotifier,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {
              final prev = selectedDate.subtract(const Duration(days: 1));
              selectedDateNotifier.value = prev;
              bookingBloc.add(LoadBookingsEvent(date: prev));
            },
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                selectedDateNotifier.value = picked;
                bookingBloc.add(LoadBookingsEvent(date: picked));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: () {
              final next = selectedDate.add(const Duration(days: 1));
              selectedDateNotifier.value = next;
              bookingBloc.add(LoadBookingsEvent(date: next));
            },
          ),
        ],
      ),
    );
  }

  void _openBookingModal({
    required BuildContext context,
    required BookingBloc bookingBloc,
    required DateTime selectedDate,
    required List<DoctorRoster> rosters,
    DoctorRoster? preselectedDoctor,
    DateTime? initialSlotTime,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => ClinicalBookingDialog(
        bloc: bookingBloc,
        selectedDate: selectedDate,
        availableDoctors: rosters,
        preselectedDoctor: preselectedDoctor,
        initialSlotTime: initialSlotTime,
      ),
    );
  }

  void _openAppointmentDetails({
    required BuildContext context,
    required BookingItem booking,
    required BookingBloc bookingBloc,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AppointmentActionsDialog(
        booking: booking,
        bookingBloc: bookingBloc,
        onAppointmentUpdated: () {
          bookingBloc.add(LoadBookingsEvent(date: booking.startTime));
        },
      ),
    );
  }

  void _openRosterManager({
    required BuildContext context,
    required ValueNotifier<List<DoctorRoster>> doctorRostersNotifier,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => DoctorRosterManagerDialog(
        initialRosters: doctorRostersNotifier.value,
        onRostersSaved: () {
          // Re-load saved rosters from local storage
          final clinicDataSource = sl<ClinicLocalDataSource>();
          clinicDataSource.getDoctorRosters().then((saved) {
            if (saved.isNotEmpty) {
              doctorRostersNotifier.value = List<DoctorRoster>.from(saved);
            }
          });
        },
      ),
    );
  }
}
