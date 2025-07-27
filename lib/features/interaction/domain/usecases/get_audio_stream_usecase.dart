import 'dart:typed_data';
import '../repositories/assistant_repository.dart';

/// Use case for getting audio stream
class GetAudioStreamUseCase {
  final AssistantRepository repository;

  GetAudioStreamUseCase({required this.repository});

  /// Execute the use case
  Future<Uint8List> execute(String sessionId) async {
    return await repository.getAudioStream(sessionId);
  }
} 