import 'package:equatable/equatable.dart';

enum InteractionStatus {
  idle,
  readyToListen,
  checkingPermission,
  isListening,
  isLoading,
  showingResponse,
}

class MainInteractionState extends Equatable {
  final InteractionStatus status;
  final String userTranscript;
  final String assistantResponse;
  final String? error;
  final String revealedResponse; // For subtitle/speech effect

  const MainInteractionState({
    required this.status,
    this.userTranscript = '',
    this.assistantResponse = '',
    this.error,
    this.revealedResponse = '',
  });

  MainInteractionState copyWith({
    InteractionStatus? status,
    String? userTranscript,
    String? assistantResponse,
    String? error,
    String? revealedResponse,
  }) {
    return MainInteractionState(
      status: status ?? this.status,
      userTranscript: userTranscript ?? this.userTranscript,
      assistantResponse: assistantResponse ?? this.assistantResponse,
      error: error,
      revealedResponse: revealedResponse ?? this.revealedResponse,
    );
  }

  @override
  List<Object?> get props => [status, userTranscript, assistantResponse, error, revealedResponse];
} 