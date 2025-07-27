import 'dart:typed_data';
import '../entities/task_entity.dart';
import '../entities/assistant_response_entity.dart';

/// Abstract repository for assistant interactions
abstract class AssistantRepository {
  /// Send a task to the assistant and get a response
  Future<AssistantResponseEntity> sendTask(TaskEntity task);
  
  /// Get audio stream for a given session ID
  Future<Uint8List> getAudioStream(String sessionId);
} 