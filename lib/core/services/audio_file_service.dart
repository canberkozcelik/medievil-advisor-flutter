import 'dart:io';
import 'dart:typed_data';
import 'package:just_audio/just_audio.dart';
import 'platform_service.dart';

abstract class AudioFileService {
  Future<String> saveAudioBytes(Uint8List audioBytes, String sessionId);
  Future<void> playAudioFile(String filePath, AudioPlayer audioPlayer);
}

class AudioFileServiceImpl implements AudioFileService {
  final PlatformService platformService;

  AudioFileServiceImpl({required this.platformService});

  @override
  Future<String> saveAudioBytes(Uint8List audioBytes, String sessionId) async {
    try {
      final tempDir = await platformService.getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/audio_$sessionId.mp3');
      await tempFile.writeAsBytes(audioBytes);
      
      print('Audio saved to temporary file: ${tempFile.path}');
      return tempFile.path;
    } catch (e) {
      print('Error saving audio file: $e');
      rethrow;
    }
  }

  @override
  Future<void> playAudioFile(String filePath, AudioPlayer audioPlayer) async {
    try {
      await audioPlayer.setFilePath(filePath);
      audioPlayer.play(); // Do not await, start playback immediately
      print('Audio playback started for file: $filePath');
    } catch (e) {
      print('Error playing audio file: $e');
      rethrow;
    }
  }
} 