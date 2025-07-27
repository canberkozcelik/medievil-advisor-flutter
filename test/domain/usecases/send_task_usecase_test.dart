import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:uuid/uuid.dart';
import 'package:medievil_advisor/features/interaction/domain/entities/task_entity.dart';
import 'package:medievil_advisor/features/interaction/domain/entities/assistant_response_entity.dart';
import 'package:medievil_advisor/features/interaction/domain/repositories/assistant_repository.dart';
import 'package:medievil_advisor/features/interaction/domain/usecases/send_task_usecase.dart';

import 'send_task_usecase_test.mocks.dart';

@GenerateMocks([AssistantRepository, Uuid])
void main() {
  group('SendTaskUseCase', () {
    late SendTaskUseCase useCase;
    late MockAssistantRepository mockRepository;
    late MockUuid mockUuid;

    setUp(() {
      mockRepository = MockAssistantRepository();
      mockUuid = MockUuid();
      useCase = SendTaskUseCase(
        repository: mockRepository,
        uuid: mockUuid,
      );
    });

    test('should send task and return assistant response', () async {
      // Arrange
      const taskDescription = 'Test task description';
      const taskId = 'task-id-123';
      const responseId = 'response-id-456';
      const responseText = 'Assistant response';
      const audioSessionId = 'session-789';
      const audioUrl = '/audio/session-789';
      final createdAt = DateTime.now();

      when(mockUuid.v4()).thenReturn(taskId);
      when(mockRepository.sendTask(any)).thenAnswer((_) async {
        return AssistantResponseEntity(
          id: responseId,
          text: responseText,
          audioSessionId: audioSessionId,
          audioUrl: audioUrl,
          createdAt: createdAt,
        );
      });

      // Act
      final result = await useCase.execute(taskDescription);

      // Assert
      expect(result, isA<AssistantResponseEntity>());
      expect(result.id, equals(responseId));
      expect(result.text, equals(responseText));
      expect(result.audioSessionId, equals(audioSessionId));
      expect(result.audioUrl, equals(audioUrl));
      expect(result.createdAt, equals(createdAt));

      verify(mockUuid.v4()).called(1);
      verify(mockRepository.sendTask(any)).called(1);
    });

    test('should propagate repository errors', () async {
      // Arrange
      const taskDescription = 'Test task description';
      const taskId = 'task-id-123';
      const errorMessage = 'Repository error';

      when(mockUuid.v4()).thenReturn(taskId);
      when(mockRepository.sendTask(any)).thenThrow(Exception(errorMessage));

      // Act & Assert
      expect(
        () => useCase.execute(taskDescription),
        throwsA(isA<Exception>()),
      );

      verify(mockUuid.v4()).called(1);
      verify(mockRepository.sendTask(any)).called(1);
    });

    test('should create task entity with correct properties', () async {
      // Arrange
      const taskDescription = 'Test task description';
      const taskId = 'task-id-123';
      final createdAt = DateTime.now();

      when(mockUuid.v4()).thenReturn(taskId);
      when(mockRepository.sendTask(any)).thenAnswer((_) async {
        return AssistantResponseEntity(
          id: 'response-id',
          text: 'Response',
          audioSessionId: 'session-id',
          audioUrl: '/audio/session-id',
          createdAt: createdAt,
        );
      });

      // Act
      await useCase.execute(taskDescription);

      // Assert
      verify(mockRepository.sendTask(argThat(
        isA<TaskEntity>()
          .having((task) => task.id, 'id', taskId)
          .having((task) => task.description, 'description', taskDescription)
          .having((task) => task.createdAt, 'createdAt', isA<DateTime>()),
      ))).called(1);
    });
  });
} 