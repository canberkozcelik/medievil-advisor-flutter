import 'package:flutter_test/flutter_test.dart';
import 'package:medievil_advisor/features/interaction/domain/entities/assistant_response_entity.dart';

void main() {
  group('AssistantResponseEntity', () {
    test('should create an AssistantResponseEntity with correct properties', () {
      // Arrange
      const id = 'response-id';
      const text = 'Assistant response text';
      const audioSessionId = 'session-123';
      const audioUrl = '/audio/session-123';
      final createdAt = DateTime.now();

      // Act
      final response = AssistantResponseEntity(
        id: id,
        text: text,
        audioSessionId: audioSessionId,
        audioUrl: audioUrl,
        createdAt: createdAt,
      );

      // Assert
      expect(response.id, equals(id));
      expect(response.text, equals(text));
      expect(response.audioSessionId, equals(audioSessionId));
      expect(response.audioUrl, equals(audioUrl));
      expect(response.createdAt, equals(createdAt));
    });

    test('should be equal when properties are the same', () {
      // Arrange
      final createdAt = DateTime.now();
      final response1 = AssistantResponseEntity(
        id: 'response-id',
        text: 'Response text',
        audioSessionId: 'session-123',
        audioUrl: '/audio/session-123',
        createdAt: createdAt,
      );
      final response2 = AssistantResponseEntity(
        id: 'response-id',
        text: 'Response text',
        audioSessionId: 'session-123',
        audioUrl: '/audio/session-123',
        createdAt: createdAt,
      );

      // Act & Assert
      expect(response1, equals(response2));
      expect(response1.hashCode, equals(response2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final createdAt = DateTime.now();
      final response1 = AssistantResponseEntity(
        id: 'response-id-1',
        text: 'Response text 1',
        audioSessionId: 'session-123',
        audioUrl: '/audio/session-123',
        createdAt: createdAt,
      );
      final response2 = AssistantResponseEntity(
        id: 'response-id-2',
        text: 'Response text 2',
        audioSessionId: 'session-456',
        audioUrl: '/audio/session-456',
        createdAt: createdAt,
      );

      // Act & Assert
      expect(response1, isNot(equals(response2)));
      expect(response1.hashCode, isNot(equals(response2.hashCode)));
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const id = 'response-id';
      const text = 'Response text';
      const audioSessionId = 'session-123';
      const audioUrl = '/audio/session-123';
      final createdAt = DateTime.now();
      final response = AssistantResponseEntity(
        id: id,
        text: text,
        audioSessionId: audioSessionId,
        audioUrl: audioUrl,
        createdAt: createdAt,
      );

      // Act
      final props = response.props;

      // Assert
      expect(props, contains(id));
      expect(props, contains(text));
      expect(props, contains(audioSessionId));
      expect(props, contains(audioUrl));
      expect(props, contains(createdAt));
    });
  });
} 