import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:just_audio/just_audio.dart';
import 'package:medievil_advisor/features/interaction/domain/usecases/send_task_usecase.dart';
import 'package:medievil_advisor/features/interaction/domain/usecases/get_audio_stream_usecase.dart';
import 'package:medievil_advisor/features/interaction/domain/entities/assistant_response_entity.dart';
import 'package:medievil_advisor/features/interaction/presentation/main_interaction_bloc.dart';
import 'package:medievil_advisor/features/interaction/presentation/main_interaction_event.dart';
import 'package:medievil_advisor/features/interaction/presentation/main_interaction_state.dart';
import 'package:medievil_advisor/core/services/platform_service.dart';
import 'package:medievil_advisor/core/services/audio_file_service.dart';

import 'main_interaction_bloc_test.mocks.dart';

@GenerateMocks([
  SendTaskUseCase,
  GetAudioStreamUseCase,
  stt.SpeechToText,
  AudioPlayer,
  AudioFileService,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MainInteractionBloc', () {
    late MainInteractionBloc bloc;
    late MockSendTaskUseCase mockSendTaskUseCase;
    late MockGetAudioStreamUseCase mockGetAudioStreamUseCase;
    late MockSpeechToText mockSpeech;
    late MockAudioPlayer mockAudioPlayer;
    late MockPlatformService mockPlatformService;
    late MockAudioFileService mockAudioFileService;

    setUp(() {
      mockSendTaskUseCase = MockSendTaskUseCase();
      mockGetAudioStreamUseCase = MockGetAudioStreamUseCase();
      mockSpeech = MockSpeechToText();
      mockAudioPlayer = MockAudioPlayer();
      mockPlatformService = MockPlatformService();
      mockAudioFileService = MockAudioFileService();

      // Mock ALL platform-dependent calls to avoid plugin issues
      when(mockSpeech.initialize()).thenAnswer((_) async => true);
      when(mockSpeech.listen(
        onResult: anyNamed('onResult'),
        listenMode: anyNamed('listenMode'),
        partialResults: anyNamed('partialResults'),
      )).thenAnswer((_) async {});
      when(mockSpeech.stop()).thenAnswer((_) async {});
      when(mockAudioPlayer.setFilePath(any)).thenAnswer((_) async {});
      when(mockAudioPlayer.play()).thenAnswer((_) async {});
      when(mockAudioPlayer.stop()).thenAnswer((_) async {});

      // Mock AudioFileService
      when(mockAudioFileService.saveAudioBytes(any, any)).thenAnswer((_) async => '/temp/audio_test.mp3');
      when(mockAudioFileService.playAudioFile(any, any)).thenAnswer((_) async {});

      // Configure mock platform service
      mockPlatformService.setMicrophonePermission(true);
      mockPlatformService.setTemporaryDirectory(Directory.systemTemp);

      // Create BLoC with mocked dependencies
      bloc = MainInteractionBloc(
        sendTaskUseCase: mockSendTaskUseCase,
        getAudioStreamUseCase: mockGetAudioStreamUseCase,
        speech: mockSpeech,
        audioPlayer: mockAudioPlayer,
        platformService: mockPlatformService,
        audioFileService: mockAudioFileService,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be idle', () {
      expect(bloc.state.status, equals(InteractionStatus.idle));
      expect(bloc.state.userTranscript, equals(''));
      expect(bloc.state.assistantResponse, equals(''));
      expect(bloc.state.error, isNull);
    });

    group('SummonPressed', () {
      blocTest<MainInteractionBloc, MainInteractionState>(
        'should emit readyToListen state',
        build: () => bloc,
        act: (bloc) => bloc.add(SummonPressed()),
        expect: () => [
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.readyToListen,
          ),
        ],
      );
    });

    group('StartListening', () {

      blocTest<MainInteractionBloc, MainInteractionState>(
        'should emit checkingPermission then isListening state when speech is available',
        build: () => bloc,
        act: (bloc) => bloc.add(const StartListening()),
        expect: () => [
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.checkingPermission,
          ),
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.isListening,
          ),
        ],
        verify: (_) {
          verify(mockSpeech.listen(
            onResult: anyNamed('onResult'),
            listenMode: anyNamed('listenMode'),
            partialResults: anyNamed('partialResults'),
          )).called(1);
        },
      );

      blocTest<MainInteractionBloc, MainInteractionState>(
        'should emit checkingPermission then error state when permission is denied',
        build: () {
          // Configure mock platform service to deny permission
          mockPlatformService.setMicrophonePermission(false);
          
          return MainInteractionBloc(
            sendTaskUseCase: mockSendTaskUseCase,
            getAudioStreamUseCase: mockGetAudioStreamUseCase,
            speech: mockSpeech,
            audioPlayer: mockAudioPlayer,
            platformService: mockPlatformService,
            audioFileService: mockAudioFileService,
          );
        },
        act: (bloc) => bloc.add(const StartListening()),
        expect: () => [
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.checkingPermission,
          ),
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.readyToListen,
          ).having(
            (state) => state.error,
            'error',
            'Microphone permission is required to use speech recognition. Please grant permission in Settings.',
          ),
        ],
      );
    });

    group('TranscriptChanged', () {
      blocTest<MainInteractionBloc, MainInteractionState>(
        'should emit state with updated transcript',
        build: () => bloc,
        act: (bloc) => bloc.add(TranscriptChanged('Hello world')),
        expect: () => [
          isA<MainInteractionState>().having(
            (state) => state.userTranscript,
            'userTranscript',
            'Hello world',
          ),
        ],
      );
    });

    group('StopListeningAndSend', () {

      blocTest<MainInteractionBloc, MainInteractionState>(
        'should emit isLoading then showingResponse on success',
        build: () {
          when(mockSendTaskUseCase.execute(any)).thenAnswer((_) async {
            return AssistantResponseEntity(
              id: 'response-id',
              text: 'Assistant response',
              audioSessionId: 'session-123',
              audioUrl: '/audio/session-123',
              createdAt: DateTime.now(),
            );
          });
          when(mockGetAudioStreamUseCase.execute(any))
              .thenAnswer((_) async => Uint8List.fromList([1, 2, 3, 4, 5]));
          when(mockAudioPlayer.setFilePath(any)).thenAnswer((_) async {});
          when(mockAudioPlayer.play()).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) async {
          bloc.add(TranscriptChanged('Test task'));
          bloc.add(StopListeningAndSend());
          // Wait for async operations to complete
          await Future.delayed(const Duration(milliseconds: 100));
        },
        expect: () => [
          isA<MainInteractionState>().having(
            (state) => state.userTranscript,
            'userTranscript',
            'Test task',
          ),
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.isLoading,
          ),
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.showingResponse,
          ).having(
            (state) => state.assistantResponse,
            'assistantResponse',
            'Assistant response',
          ),
        ],
        verify: (_) {
          verify(mockSpeech.stop()).called(1);
          verify(mockSendTaskUseCase.execute('Test task')).called(1);
          verify(mockGetAudioStreamUseCase.execute('session-123')).called(1);
          verify(mockAudioFileService.saveAudioBytes(any, any)).called(1);
          verify(mockAudioFileService.playAudioFile(any, any)).called(1);
        },
      );

      blocTest<MainInteractionBloc, MainInteractionState>(
        'should emit error state when API call fails',
        build: () {
          when(mockSendTaskUseCase.execute(any))
              .thenThrow(Exception('API Error'));
          return bloc;
        },
        act: (bloc) {
          bloc.add(TranscriptChanged('Test task'));
          bloc.add(StopListeningAndSend());
        },
        expect: () => [
          isA<MainInteractionState>().having(
            (state) => state.userTranscript,
            'userTranscript',
            'Test task',
          ),
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.isLoading,
          ),
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.readyToListen,
          ).having(
            (state) => state.error,
            'error',
            'Exception: API Error',
          ),
        ],
        verify: (_) {
          verify(mockSpeech.stop()).called(1);
          verify(mockSendTaskUseCase.execute('Test task')).called(1);
        },
      );
    });

    group('SummonAnotherPressed', () {
      blocTest<MainInteractionBloc, MainInteractionState>(
        'should emit idle state and stop audio',
        build: () => bloc,
        act: (bloc) => bloc.add(SummonAnotherPressed()),
        expect: () => [
          isA<MainInteractionState>().having(
            (state) => state.status,
            'status',
            InteractionStatus.idle,
          ),
        ],
        verify: (_) {
          verify(mockAudioPlayer.stop()).called(1);
        },
      );
    });
  });
} 