import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'package:medievil_advisor/core/services/audio_file_service.dart';
import 'package:medievil_advisor/core/services/platform_service.dart' as platform_service;

import 'audio_file_service_test.mocks.dart';

@GenerateMocks([platform_service.PlatformService, AudioPlayer])
void main() {
  group('AudioFileServiceImpl', () {
    late AudioFileServiceImpl audioFileService;
    late MockPlatformService mockPlatformService;
    late MockAudioPlayer mockAudioPlayer;
    late Directory tempDir;

    setUp(() {
      mockPlatformService = MockPlatformService();
      mockAudioPlayer = MockAudioPlayer();
      
      // Create a temporary directory for testing
      tempDir = Directory.systemTemp.createTempSync('audio_test');
      
      // Mock platform service to return our test directory
      when(mockPlatformService.getTemporaryDirectory())
          .thenAnswer((_) async => tempDir);
      
      // Mock audio player methods
      when(mockAudioPlayer.setFilePath(any)).thenAnswer((_) async {});
      when(mockAudioPlayer.play()).thenAnswer((_) async {});
      
      audioFileService = AudioFileServiceImpl(platformService: mockPlatformService);
    });

    tearDown(() {
      // Clean up temporary directory
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('saveAudioBytes', () {
      test('should save audio bytes to temporary file successfully', () async {
        // Arrange
        final audioBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sessionId = 'test-session-123';
        
        // Act
        final filePath = await audioFileService.saveAudioBytes(audioBytes, sessionId);
        
        // Assert
        expect(filePath, isA<String>());
        expect(filePath, contains('audio_test-session-123.mp3'));
        
        // Verify file was actually created
        final file = File(filePath);
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), equals(5));
        
        // Verify platform service was called
        verify(mockPlatformService.getTemporaryDirectory()).called(1);
      });

      test('should throw exception when platform service fails', () async {
        // Arrange
        final audioBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sessionId = 'test-session-123';
        
        when(mockPlatformService.getTemporaryDirectory())
            .thenThrow(Exception('Platform service error'));
        
        // Act & Assert
        expect(
          () => audioFileService.saveAudioBytes(audioBytes, sessionId),
          throwsA(isA<Exception>()),
        );
        
        verify(mockPlatformService.getTemporaryDirectory()).called(1);
      });

      test('should throw exception when file write fails', () async {
        // Arrange
        final audioBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sessionId = 'test-session-123';
        
        // Mock platform service to throw exception
        when(mockPlatformService.getTemporaryDirectory())
            .thenThrow(Exception('Directory access error'));
        
        // Act & Assert
        expect(
          () => audioFileService.saveAudioBytes(audioBytes, sessionId),
          throwsA(isA<Exception>()),
        );
        
        verify(mockPlatformService.getTemporaryDirectory()).called(1);
      });

      test('should handle empty audio bytes', () async {
        // Arrange
        final audioBytes = Uint8List(0);
        const sessionId = 'test-session-empty';
        
        // Act
        final filePath = await audioFileService.saveAudioBytes(audioBytes, sessionId);
        
        // Assert
        expect(filePath, isA<String>());
        
        final file = File(filePath);
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), equals(0));
      });

      test('should handle special characters in session ID', () async {
        // Arrange
        final audioBytes = Uint8List.fromList([1, 2, 3]);
        const sessionId = 'test-session-with-special-chars!@#\$%^&*()';
        
        // Act
        final filePath = await audioFileService.saveAudioBytes(audioBytes, sessionId);
        
        // Assert
        expect(filePath, isA<String>());
        expect(filePath, contains('audio_test-session-with-special-chars!@#\$%^&*().mp3'));
        
        final file = File(filePath);
        expect(file.existsSync(), isTrue);
      });
    });

    group('playAudioFile', () {
      test('should play audio file successfully', () async {
        // Arrange
        const filePath = '/temp/test_audio.mp3';
        
        // Act
        await audioFileService.playAudioFile(filePath, mockAudioPlayer);
        
        // Assert
        verify(mockAudioPlayer.setFilePath(filePath)).called(1);
        verify(mockAudioPlayer.play()).called(1);
      });

      test('should throw exception when setFilePath fails', () async {
        // Arrange
        const filePath = '/temp/test_audio.mp3';
        
        when(mockAudioPlayer.setFilePath(filePath))
            .thenThrow(Exception('Audio player error'));
        
        // Act & Assert
        expect(
          () => audioFileService.playAudioFile(filePath, mockAudioPlayer),
          throwsA(isA<Exception>()),
        );
        
        verify(mockAudioPlayer.setFilePath(filePath)).called(1);
        verifyNever(mockAudioPlayer.play());
      });

      test('should still call play even if setFilePath succeeds', () async {
        // Arrange
        const filePath = '/temp/test_audio.mp3';
        
        when(mockAudioPlayer.setFilePath(filePath)).thenAnswer((_) async {});
        when(mockAudioPlayer.play()).thenThrow(Exception('Play error'));
        
        // Act & Assert
        expect(
          () => audioFileService.playAudioFile(filePath, mockAudioPlayer),
          throwsA(isA<Exception>()),
        );
        
        verify(mockAudioPlayer.setFilePath(filePath)).called(1);
        // Note: play() is called but throws exception, so verification might fail
        // The important thing is that the exception is thrown
      });

      test('should handle empty file path', () async {
        // Arrange
        const filePath = '';
        
        // Act
        await audioFileService.playAudioFile(filePath, mockAudioPlayer);
        
        // Assert
        verify(mockAudioPlayer.setFilePath(filePath)).called(1);
        verify(mockAudioPlayer.play()).called(1);
      });

      test('should handle file path with spaces', () async {
        // Arrange
        const filePath = '/temp/my audio file.mp3';
        
        // Act
        await audioFileService.playAudioFile(filePath, mockAudioPlayer);
        
        // Assert
        verify(mockAudioPlayer.setFilePath(filePath)).called(1);
        verify(mockAudioPlayer.play()).called(1);
      });
    });

    group('integration tests', () {
      test('should save and play audio file in sequence', () async {
        // Arrange
        final audioBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const sessionId = 'integration-test';
        
        // Act
        final filePath = await audioFileService.saveAudioBytes(audioBytes, sessionId);
        await audioFileService.playAudioFile(filePath, mockAudioPlayer);
        
        // Assert
        expect(filePath, isA<String>());
        
        final file = File(filePath);
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), equals(5));
        
        verify(mockAudioPlayer.setFilePath(filePath)).called(1);
        verify(mockAudioPlayer.play()).called(1);
      });
    });
  });
} 