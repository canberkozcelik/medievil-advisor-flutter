import 'package:equatable/equatable.dart';

/// Entity representing an assistant response
class AssistantResponseEntity extends Equatable {
  final String id;
  final String text;
  final String audioSessionId;
  final String audioUrl;
  final DateTime createdAt;

  const AssistantResponseEntity({
    required this.id,
    required this.text,
    required this.audioSessionId,
    required this.audioUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, text, audioSessionId, audioUrl, createdAt];
} 