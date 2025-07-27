import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:typed_data';
import 'package:medievil_advisor/features/interaction/domain/repositories/assistant_repository.dart';
import 'package:medievil_advisor/features/interaction/domain/usecases/get_audio_stream_usecase.dart';

import 'get_audio_stream_usecase_test.mocks.dart';

@GenerateMocks([AssistantRepository])
void main() {
  group('GetAudioStreamUseCase', () {
    late GetAudioStreamUseCase useCase;
    late MockAssistantRepository mockRepository;

    setUp(() {
      mockRepository = MockAssistantRepository();
      useCase = GetAudioStreamUseCase(repository: mockRepository);
    });

    test('should get audio stream successfully', () async {
      // Arrange
      const sessionId = 'session-123';
      final audioBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      when(mockRepository.getAudioStream(sessionId))
          .thenAnswer((_) async => audioBytes);

      // Act
      final result = await useCase.execute(sessionId);

      // Assert
      expect(result, equals(audioBytes));
      verify(mockRepository.getAudioStream(sessionId)).called(1);
    });

    test('should propagate repository errors', () async {
      // Arrange
      const sessionId = 'session-123';
      const errorMessage = 'Audio stream error';

      when(mockRepository.getAudioStream(sessionId))
          .thenThrow(Exception(errorMessage));

      // Act & Assert
      expect(
        () => useCase.execute(sessionId),
        throwsA(isA<Exception>()),
      );

      verify(mockRepository.getAudioStream(sessionId)).called(1);
    });

    test('should handle empty audio stream', () async {
      // Arrange
      const sessionId = 'session-123';
      final emptyAudioBytes = Uint8List.fromList([]);

      when(mockRepository.getAudioStream(sessionId))
          .thenAnswer((_) async => emptyAudioBytes);

      // Act
      final result = await useCase.execute(sessionId);

      // Assert
      expect(result, equals(emptyAudioBytes));
      expect(result, isEmpty);
      verify(mockRepository.getAudioStream(sessionId)).called(1);
    });

    test('should handle large audio stream', () async {
      // Arrange
      const sessionId = 'session-123';
      final largeAudioBytes = Uint8List.fromList(List.generate(1000, (index) => index % 256));

      when(mockRepository.getAudioStream(sessionId))
          .thenAnswer((_) async => largeAudioBytes);

      // Act
      final result = await useCase.execute(sessionId);

      // Assert
      expect(result, equals(largeAudioBytes));
      expect(result.length, equals(1000));
      verify(mockRepository.getAudioStream(sessionId)).called(1);
    });
  });
} 