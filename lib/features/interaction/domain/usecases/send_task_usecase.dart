import 'package:uuid/uuid.dart';
import '../entities/task_entity.dart';
import '../entities/assistant_response_entity.dart';
import '../repositories/assistant_repository.dart';

/// Use case for sending a task to the assistant
class SendTaskUseCase {
  final AssistantRepository repository;
  final Uuid uuid;

  SendTaskUseCase({
    required this.repository,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  /// Execute the use case
  Future<AssistantResponseEntity> execute(String taskDescription) async {
    // Create task entity
    final task = TaskEntity(
      id: uuid.v4(),
      description: taskDescription,
      createdAt: DateTime.now(),
    );

    // Send task to repository
    return await repository.sendTask(task);
  }
} 