class MessageRoutes {
  // Clinical & Medical Routes
  static const String patientCheckedIn = 'patient.checked_in';
  static const String patientVitalsUpdated = 'patient.vitals_updated';
  static const String visitStarted = 'visit.started';
  static const String visitCompleted = 'visit.completed';
  static const String toothChartUpdated = 'tooth_chart.updated';

  // Sales & POS Routes
  static const String saleCompleted = 'sale.completed';
  static const String orderRefunded = 'order.refunded';
  static const String drawerShiftUpdated = 'shift.updated';

  // Bookings & Work Orders Routes
  static const String bookingCreated = 'booking.created';
  static const String bookingUpdated = 'booking.updated';
  static const String bookingCancelled = 'booking.cancelled';
  static const String workOrderCreated = 'work_order.created';
  static const String workOrderStageAdvanced = 'work_order.stage_advanced';

  // Network & Station Topology Routes
  static const String nodeJoined = 'system.node_joined';
  static const String nodeLeft = 'system.node_left';
  static const String ping = 'system.ping';
  static const String pong = 'system.pong';

  // State Reconciliation & Connection Recovery Routes
  static const String syncRequestActiveState = 'sync.request_active_state';
  static const String syncFullStateResponse = 'sync.full_state_response';
  static const String syncVisitUpdated = 'visit.updated';

  static const List<String> allRoutes = [
    patientCheckedIn,
    patientVitalsUpdated,
    visitStarted,
    visitCompleted,
    toothChartUpdated,
    saleCompleted,
    orderRefunded,
    drawerShiftUpdated,
    bookingCreated,
    bookingUpdated,
    bookingCancelled,
    workOrderCreated,
    workOrderStageAdvanced,
    nodeJoined,
    nodeLeft,
    ping,
    pong,
    syncRequestActiveState,
    syncFullStateResponse,
    syncVisitUpdated,
  ];

  static bool isValidRoute(String route) => allRoutes.contains(route);
}
