import 'package:equatable/equatable.dart';

/// Entity representing a user task or goal
class TaskEntity extends Equatable {
  final String id;
  final String description;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, description, createdAt];
} 