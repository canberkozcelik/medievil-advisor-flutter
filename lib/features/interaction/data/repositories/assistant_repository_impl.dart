import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/assistant_response_entity.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../datasources/assistant_remote_data_source.dart';

/// Implementation of AssistantRepository
class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantRemoteDataSource remoteDataSource;
  final Uuid uuid;

  AssistantRepositoryImpl({
    required this.remoteDataSource,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<AssistantResponseEntity> sendTask(TaskEntity task) async {
    try {
      final response = await remoteDataSource.sendTask(task.description);
      
      return AssistantResponseEntity(
        id: uuid.v4(),
        text: response['result'] as String,
        audioSessionId: response['audioSessionId'] as String,
        audioUrl: response['audioUrl'] as String,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to send task: $e');
    }
  }

  @override
  Future<Uint8List> getAudioStream(String sessionId) async {
    try {
      return await remoteDataSource.getAudioStream(sessionId);
    } catch (e) {
      throw Exception('Failed to get audio stream: $e');
    }
  }
} 