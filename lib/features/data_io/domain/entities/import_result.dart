import 'package:equatable/equatable.dart';

class ImportResult extends Equatable {
  final int successCount;
  final int failCount;
  final List<String> errorMessages;

  const ImportResult({
    required this.successCount,
    required this.failCount,
    required this.errorMessages,
  });

  int get totalProcessed => successCount + failCount;
  bool get isFullSuccess => failCount == 0 && successCount > 0;
  bool get hasErrors => failCount > 0;

  @override
  List<Object?> get props => [successCount, failCount, errorMessages];
}
