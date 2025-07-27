import 'package:equatable/equatable.dart';

abstract class MainInteractionEvent extends Equatable {
  const MainInteractionEvent();

  @override
  List<Object?> get props => [];
}

class SummonPressed extends MainInteractionEvent {
  const SummonPressed();
}

class StartListening extends MainInteractionEvent {
  const StartListening();
}

class TranscriptChanged extends MainInteractionEvent {
  final String transcript;

  const TranscriptChanged(this.transcript);

  @override
  List<Object?> get props => [transcript];
}

class StopListeningAndSend extends MainInteractionEvent {
  const StopListeningAndSend();
}

class ApiResponseReceived extends MainInteractionEvent {
  final Map<String, dynamic> response;

  const ApiResponseReceived(this.response);

  @override
  List<Object?> get props => [response];
}

class ApiErrorOccurred extends MainInteractionEvent {
  final String error;

  const ApiErrorOccurred(this.error);

  @override
  List<Object?> get props => [error];
}

class SummonAnotherPressed extends MainInteractionEvent {
  const SummonAnotherPressed();
}

class ClearError extends MainInteractionEvent {
  const ClearError();
} 