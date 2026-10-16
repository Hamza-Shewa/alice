import 'package:equatable/equatable.dart';

/// Definition of http error data holder.
// ignore: must_be_immutable
class NetLensHttpError with Equatable {
  dynamic error;
  StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];
}
