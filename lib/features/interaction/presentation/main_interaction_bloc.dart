import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:just_audio/just_audio.dart';
import '../../../../core/services/platform_service.dart';
import '../../../../core/services/audio_file_service.dart';
import '../domain/usecases/send_task_usecase.dart';
import '../domain/usecases/get_audio_stream_usecase.dart';
import 'main_interaction_event.dart';
import 'main_interaction_state.dart';

class MainInteractionBloc extends Bloc<MainInteractionEvent, MainInteractionState> {
  final SendTaskUseCase sendTaskUseCase;
  final GetAudioStreamUseCase getAudioStreamUseCase;
  final stt.SpeechToText speech;
  final AudioPlayer audioPlayer;
  final PlatformService platformService;
  final AudioFileService audioFileService;
  bool speechAvailable = false;

  MainInteractionBloc({
    required this.sendTaskUseCase,
    required this.getAudioStreamUseCase,
    required this.speech,
    required this.audioPlayer,
    required this.platformService,
    required this.audioFileService,
  }) : super(const MainInteractionState(status: InteractionStatus.idle)) {
    on<SummonPressed>(_onSummonPressed);
    on<StartListening>(_onStartListening);
    on<TranscriptChanged>(_onTranscriptChanged);
    on<StopListeningAndSend>(_onStopListeningAndSend);
    on<ApiResponseReceived>(_onApiResponseReceived);
    on<ApiErrorOccurred>(_onApiErrorOccurred);
    on<SummonAnotherPressed>(_onSummonAnotherPressed);
    on<ClearError>(_onClearError);
    _initPermissionsAndServices();
  }

  Future<void> _initPermissionsAndServices() async {
    try {
      print('Initializing permissions and services...');
      
      // Request permission early (iOS Simulator is more permissive at startup)
      final permissionGranted = await platformService.requestMicrophonePermission();
      
      if (permissionGranted) {
        print('Permission granted during initialization - initializing speech recognition...');
        // Actually initialize the speech recognition service
        speechAvailable = await speech.initialize();
        if (speechAvailable) {
          print('Speech recognition initialized successfully during startup');
        } else {
          print('Speech recognition initialization failed during startup');
        }
      } else {
        print('Permission not granted during initialization - will request on user interaction');
        speechAvailable = false;
      }
    } catch (e) {
      print('Error initializing services: $e');
      speechAvailable = false;
    }
  }

  void _onSummonPressed(SummonPressed event, Emitter<MainInteractionState> emit) {
    emit(state.copyWith(status: InteractionStatus.readyToListen, userTranscript: '', assistantResponse: '', error: null));
  }

  Future<void> _onStartListening(StartListening event, Emitter<MainInteractionState> emit) async {
    print('User clicked record button - checking microphone permission...');
    
    // Show checking permission state
    emit(state.copyWith(status: InteractionStatus.checkingPermission, error: null));
    
    // Check if we already have permission from initialization
    if (speechAvailable) {
      print('Speech recognition already available - starting to listen...');
      emit(state.copyWith(status: InteractionStatus.isListening, userTranscript: '', error: null));
      await speech.listen(
        onResult: (result) {
          add(TranscriptChanged(result.recognizedWords));
        },
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
      );
      return;
    }
    
    // Request permission if not already granted
    final permissionGranted = await platformService.requestMicrophonePermission();
    
    if (permissionGranted) {
      print('Microphone permission granted - initializing speech recognition...');
      
      // Initialize speech recognition
      speechAvailable = await speech.initialize();
      
      if (speechAvailable) {
        print('Speech recognition initialized successfully - starting to listen...');
        // Continue to listening flow
        emit(state.copyWith(status: InteractionStatus.isListening, userTranscript: '', error: null));
        await speech.listen(
          onResult: (result) {
            add(TranscriptChanged(result.recognizedWords));
          },
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
        );
      } else {
        print('Speech recognition initialization failed');
        emit(state.copyWith(
          status: InteractionStatus.readyToListen,
          error: 'Speech recognition is not available on this device'
        ));
      }
    } else {
      print('Microphone permission denied by user');
      // Handle permission denied
      emit(state.copyWith(
        status: InteractionStatus.readyToListen,
        error: 'Microphone permission is required to use speech recognition. Please grant permission in Settings.'
      ));
    }
  }

  void _onTranscriptChanged(TranscriptChanged event, Emitter<MainInteractionState> emit) {
    emit(state.copyWith(userTranscript: event.transcript));
  }

  Future<void> _onStopListeningAndSend(StopListeningAndSend event, Emitter<MainInteractionState> emit) async {
    await speech.stop();
    emit(state.copyWith(status: InteractionStatus.isLoading));
    try {
      print('Sending task to backend: ${state.userTranscript}');
      final response = await sendTaskUseCase.execute(state.userTranscript);
      
      // Convert entity to map for backward compatibility
      final responseMap = {
        'result': response.text,
        'audioSessionId': response.audioSessionId,
        'audioUrl': response.audioUrl,
      };
      
      add(ApiResponseReceived(responseMap));
    } catch (e) {
      print('Backend API error: $e');
      add(ApiErrorOccurred(e.toString()));
    }
  }

  Future<void> _onApiResponseReceived(ApiResponseReceived event, Emitter<MainInteractionState> emit) async {
    final response = event.response;
    final text = response['result'] as String;
    final audioSessionId = response['audioSessionId'] as String;

    print('Received API response:');
    print('  Text: $text');
    print('  Audio Session ID: $audioSessionId');

    // Play the audio from Google Cloud TTS using session ID
    try {
      print('Attempting to fetch audio for session: $audioSessionId');
      final audioBytes = await getAudioStreamUseCase.execute(audioSessionId);
      
      print('Audio bytes received, size: ${audioBytes.length}');
      
      // Save audio bytes to temporary file using the service
      final filePath = await audioFileService.saveAudioBytes(audioBytes, audioSessionId);
      
      // Play the audio file using the service
      await audioFileService.playAudioFile(filePath, audioPlayer);
      
      emit(state.copyWith(
        status: InteractionStatus.showingResponse,
        assistantResponse: text,
        error: null,
        revealedResponse: '', // UI will handle reveal
      ));
      print('Audio playback started, now triggering fade');

      print('Playing Google Cloud TTS audio with session ID: $audioSessionId');
    } catch (e) {
      print('Audio playback error: $e');
      // Even if audio fails, still show the response
      emit(state.copyWith(
        status: InteractionStatus.showingResponse,
        assistantResponse: text,
        error: null,
        revealedResponse: '',
      ));
      print('Continuing with response display despite audio error');
    }
  }

  void _onApiErrorOccurred(ApiErrorOccurred event, Emitter<MainInteractionState> emit) {
    print('Handling API error: ${event.error}');
    emit(state.copyWith(
      status: InteractionStatus.readyToListen,
      error: event.error
    ));
  }

  void _onSummonAnotherPressed(SummonAnotherPressed event, Emitter<MainInteractionState> emit) {
    audioPlayer.stop();
    emit(const MainInteractionState(status: InteractionStatus.idle));
  }

  void _onClearError(ClearError event, Emitter<MainInteractionState> emit) {
    emit(state.copyWith(error: null));
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
} 