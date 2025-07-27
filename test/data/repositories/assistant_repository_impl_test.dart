import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:medievil_advisor/features/interaction/data/datasources/assistant_remote_data_source.dart';
import 'package:medievil_advisor/features/interaction/data/repositories/assistant_repository_impl.dart';
import 'package:medievil_advisor/features/interaction/domain/entities/task_entity.dart';
import 'package:medievil_advisor/features/interaction/domain/entities/assistant_response_entity.dart';

import 'assistant_repository_impl_test.mocks.dart';

@GenerateMocks([AssistantRemoteDataSource, Uuid])
void main() {
  group('AssistantRepositoryImpl', () {
    late AssistantRepositoryImpl repository;
    late MockAssistantRemoteDataSource mockDataSource;
    late MockUuid mockUuid;

    setUp(() {
      mockDataSource = MockAssistantRemoteDataSource();
      mockUuid = MockUuid();
      repository = AssistantRepositoryImpl(
        remoteDataSource: mockDataSource,
        uuid: mockUuid,
      );
    });

    group('sendTask', () {
      test('should send task and return assistant response', () async {
        // Arrange
        const taskId = 'task-id-123';
        const responseId = 'response-id-456';
        const taskDescription = 'Test task';
        final task = TaskEntity(
          id: taskId,
          description: taskDescription,
          createdAt: DateTime.now(),
        );

        final apiResponse = {
          'result': 'Assistant response text',
          'audioSessionId': 'session-789',
          'audioUrl': '/audio/session-789',
        };

        when(mockUuid.v4()).thenReturn(responseId);
        when(mockDataSource.sendTask(taskDescription))
            .thenAnswer((_) async => apiResponse);

        // Act
        final result = await repository.sendTask(task);

        // Assert
        expect(result, isA<AssistantResponseEntity>());
        expect(result.id, equals(responseId));
        expect(result.text, equals('Assistant response text'));
        expect(result.audioSessionId, equals('session-789'));
        expect(result.audioUrl, equals('/audio/session-789'));
        expect(result.createdAt, isA<DateTime>());

        verify(mockDataSource.sendTask(taskDescription)).called(1);
        verify(mockUuid.v4()).called(1);
      });

      test('should propagate data source errors', () async {
        // Arrange
        const taskDescription = 'Test task';
        const errorMessage = 'Data source error';
        final task = TaskEntity(
          id: 'task-id',
          description: taskDescription,
          createdAt: DateTime.now(),
        );

        when(mockDataSource.sendTask(taskDescription))
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        expect(
          () => repository.sendTask(task),
          throwsA(isA<Exception>()),
        );

        verify(mockDataSource.sendTask(taskDescription)).called(1);
      });
    });

    group('getAudioStream', () {
      test('should get audio stream successfully', () async {
        // Arrange
        const sessionId = 'session-123';
        final audioBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

        when(mockDataSource.getAudioStream(sessionId))
            .thenAnswer((_) async => audioBytes);

        // Act
        final result = await repository.getAudioStream(sessionId);

        // Assert
        expect(result, equals(audioBytes));
        verify(mockDataSource.getAudioStream(sessionId)).called(1);
      });

      test('should propagate data source errors', () async {
        // Arrange
        const sessionId = 'session-123';
        const errorMessage = 'Audio stream error';

        when(mockDataSource.getAudioStream(sessionId))
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        expect(
          () => repository.getAudioStream(sessionId),
          throwsA(isA<Exception>()),
        );

        verify(mockDataSource.getAudioStream(sessionId)).called(1);
      });
    });
  });
} 