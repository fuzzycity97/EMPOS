import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/work_order_ticket.dart';
import '../../domain/usecases/get_work_orders_usecase.dart';
import '../../domain/usecases/save_work_order_usecase.dart';
import '../../domain/usecases/transition_stage_usecase.dart';
import 'work_order_event.dart';
import 'work_order_state.dart';

class WorkOrderBloc extends Bloc<WorkOrderEvent, WorkOrderState> {
  final GetWorkOrdersUseCase getWorkOrdersUseCase;
  final SaveWorkOrderUseCase saveWorkOrderUseCase;
  final TransitionStageUseCase transitionStageUseCase;

  WorkOrderBloc({
    required this.getWorkOrdersUseCase,
    required this.saveWorkOrderUseCase,
    required this.transitionStageUseCase,
  }) : super(WorkOrderInitial()) {
    on<LoadWorkOrdersEvent>(_onLoadWorkOrders);
    on<CreateWorkOrderEvent>(_onCreateWorkOrder);
    on<AdvanceStageEvent>(_onAdvanceStage);
  }

  Map<WorkOrderStage, List<WorkOrderTicket>> _groupPipeline(List<WorkOrderTicket> tickets) {
    final Map<WorkOrderStage, List<WorkOrderTicket>> pipeline = {
      for (final stage in WorkOrderStage.values) stage: [],
    };
    for (final ticket in tickets) {
      pipeline[ticket.currentStage]?.add(ticket);
    }
    return pipeline;
  }

  Future<void> _onLoadWorkOrders(
    LoadWorkOrdersEvent event,
    Emitter<WorkOrderState> emit,
  ) async {
    emit(WorkOrderLoading());
    final result = await getWorkOrdersUseCase(
      stage: event.stage,
      customerId: event.customerId,
      assignedStaffId: event.assignedStaffId,
    );

    result.fold(
      (failure) => emit(WorkOrderError(failure.message)),
      (tickets) => emit(
        WorkOrderLoaded(
          tickets: tickets,
          pipeline: _groupPipeline(tickets),
        ),
      ),
    );
  }

  Future<void> _onCreateWorkOrder(
    CreateWorkOrderEvent event,
    Emitter<WorkOrderState> emit,
  ) async {
    emit(WorkOrderLoading());
    final result = await saveWorkOrderUseCase(event.ticket);

    await result.fold(
      (failure) async => emit(WorkOrderError(failure.message)),
      (_) async {
        final refresh = await getWorkOrdersUseCase();
        refresh.fold(
          (failure) => emit(WorkOrderError(failure.message)),
          (tickets) => emit(
            WorkOrderLoaded(
              tickets: tickets,
              pipeline: _groupPipeline(tickets),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onAdvanceStage(
    AdvanceStageEvent event,
    Emitter<WorkOrderState> emit,
  ) async {
    emit(WorkOrderLoading());
    final result = await transitionStageUseCase(
      event.ticketId,
      event.newStage,
      notes: event.note,
      updatedBy: event.updatedBy,
    );

    await result.fold(
      (failure) async => emit(WorkOrderError(failure.message)),
      (_) async {
        final refresh = await getWorkOrdersUseCase();
        refresh.fold(
          (failure) => emit(WorkOrderError(failure.message)),
          (tickets) => emit(
            WorkOrderLoaded(
              tickets: tickets,
              pipeline: _groupPipeline(tickets),
            ),
          ),
        );
      },
    );
  }
}
