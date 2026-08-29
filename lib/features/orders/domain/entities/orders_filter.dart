import 'package:equatable/equatable.dart';
import '../../../pos/domain/entities/order.dart';

class OrdersFilter extends Equatable {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final OrderStatus? status;
  final String? searchQuery;
  final int? limit;
  final int? offset;

  const OrdersFilter({
    this.dateFrom,
    this.dateTo,
    this.status,
    this.searchQuery,
    this.limit,
    this.offset,
  });

  OrdersFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    OrderStatus? status,
    String? searchQuery,
    int? limit,
    int? offset,
  }) {
    return OrdersFilter(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [
        dateFrom,
        dateTo,
        status,
        searchQuery,
        limit,
        offset,
      ];
}
