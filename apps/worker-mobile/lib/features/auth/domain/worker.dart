import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker.freezed.dart';
part 'worker.g.dart';

@freezed
abstract class Worker with _$Worker {
  const factory Worker({
    required String id,
    required String fullName,
    required String employeeCode,
    required String phone,
    @Default('NEST') String companyName,
    @Default('hy') String locale,
    @Default(false) bool mustChangePassword,
  }) = _Worker;

  factory Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);
}
