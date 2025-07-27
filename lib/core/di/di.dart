import 'package:get_it/get_it.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import '../services/platform_service.dart';
import '../services/audio_file_service.dart';
import '../../features/interaction/data/datasources/assistant_remote_data_source.dart';
import '../../features/interaction/data/repositories/assistant_repository_impl.dart';
import '../../features/interaction/domain/repositories/assistant_repository.dart';
import '../../features/interaction/domain/usecases/send_task_usecase.dart';
import '../../features/interaction/domain/usecases/get_audio_stream_usecase.dart';
import '../../features/interaction/presentation/main_interaction_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Register UUID
  getIt.registerLazySingleton<Uuid>(() => const Uuid());
  
  // Register data sources
  getIt.registerLazySingleton<AssistantRemoteDataSource>(
    () => AssistantRemoteDataSourceImpl(),
  );
  
  // Register repositories
  getIt.registerLazySingleton<AssistantRepository>(
    () => AssistantRepositoryImpl(
      remoteDataSource: getIt<AssistantRemoteDataSource>(),
      uuid: getIt<Uuid>(),
    ),
  );
  
  // Register use cases
  getIt.registerLazySingleton<SendTaskUseCase>(
    () => SendTaskUseCase(
      repository: getIt<AssistantRepository>(),
      uuid: getIt<Uuid>(),
    ),
  );
  
  getIt.registerLazySingleton<GetAudioStreamUseCase>(
    () => GetAudioStreamUseCase(
      repository: getIt<AssistantRepository>(),
    ),
  );
  
  // Register platform service
  getIt.registerLazySingleton<PlatformService>(() => PlatformServiceImpl());
  
  // Register audio file service
  getIt.registerLazySingleton<AudioFileService>(() => AudioFileServiceImpl(platformService: getIt<PlatformService>()));
  
  // Register speech recognition
  getIt.registerLazySingleton<stt.SpeechToText>(() => stt.SpeechToText());
  
  // Register audio player
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
  
  // Register BLoC factory
  getIt.registerFactory<MainInteractionBloc>(() => MainInteractionBloc(
    sendTaskUseCase: getIt<SendTaskUseCase>(),
    getAudioStreamUseCase: getIt<GetAudioStreamUseCase>(),
    speech: getIt<stt.SpeechToText>(),
    audioPlayer: getIt<AudioPlayer>(),
    platformService: getIt<PlatformService>(),
    audioFileService: getIt<AudioFileService>(),
  ));
}

/// Dispose all dependencies
Future<void> disposeDependencies() async {
  await getIt.reset();
} 