import 'package:flutter_test/flutter_test.dart';
import 'package:medievil_advisor/features/interaction/domain/entities/task_entity.dart';

void main() {
  group('TaskEntity', () {
    test('should create a TaskEntity with correct properties', () {
      // Arrange
      const id = 'test-id';
      const description = 'Test task description';
      final createdAt = DateTime.now();

      // Act
      final task = TaskEntity(
        id: id,
        description: description,
        createdAt: createdAt,
      );

      // Assert
      expect(task.id, equals(id));
      expect(task.description, equals(description));
      expect(task.createdAt, equals(createdAt));
    });

    test('should be equal when properties are the same', () {
      // Arrange
      final createdAt = DateTime.now();
      final task1 = TaskEntity(
        id: 'test-id',
        description: 'Test task',
        createdAt: createdAt,
      );
      final task2 = TaskEntity(
        id: 'test-id',
        description: 'Test task',
        createdAt: createdAt,
      );

      // Act & Assert
      expect(task1, equals(task2));
      expect(task1.hashCode, equals(task2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final createdAt = DateTime.now();
      final task1 = TaskEntity(
        id: 'test-id-1',
        description: 'Test task 1',
        createdAt: createdAt,
      );
      final task2 = TaskEntity(
        id: 'test-id-2',
        description: 'Test task 2',
        createdAt: createdAt,
      );

      // Act & Assert
      expect(task1, isNot(equals(task2)));
      expect(task1.hashCode, isNot(equals(task2.hashCode)));
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const id = 'test-id';
      const description = 'Test task description';
      final createdAt = DateTime.now();
      final task = TaskEntity(
        id: id,
        description: description,
        createdAt: createdAt,
      );

      // Act
      final props = task.props;

      // Assert
      expect(props, contains(id));
      expect(props, contains(description));
      expect(props, contains(createdAt));
    });
  });
} 