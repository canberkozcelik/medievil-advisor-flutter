import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/di.dart';
import 'main_interaction_bloc.dart';
import 'main_interaction_event.dart';
import 'main_interaction_state.dart';
import 'evil_response_fade.dart';

class MainInteractionScreen extends StatelessWidget {
  const MainInteractionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MainInteractionBloc>(),
      child: const _MainInteractionView(),
    );
  }
}

class _MainInteractionView extends StatelessWidget {
  const _MainInteractionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainInteractionBloc, MainInteractionState>(
      listenWhen: (prev, curr) => curr.error != null && curr.error != prev.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                                  onPressed: () {
                    // Clear error and try again
                    context.read<MainInteractionBloc>().add(const ClearError());
                    context.read<MainInteractionBloc>().add(const StartListening());
                  },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case InteractionStatus.idle:
            return const _IdleState();
          case InteractionStatus.readyToListen:
            return const _ReadyToListenState();
          case InteractionStatus.checkingPermission:
            return const _CheckingPermissionState();
          case InteractionStatus.isListening:
            return _ListeningState(transcript: state.userTranscript);
          case InteractionStatus.isLoading:
            return const _LoadingState();
          case InteractionStatus.showingResponse:
            return _ResponseStateWidget(response: state.assistantResponse);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _IdleState extends StatelessWidget {
  const _IdleState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 48),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "What's your responsibility or goal today? I'm here to help you.",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: FloatingActionButton(
                  onPressed: () {
                    context.read<MainInteractionBloc>().add(const StartListening());
                  },
                  backgroundColor: Colors.black,
                  child: const Text('Record', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyToListenState extends StatelessWidget {
  const _ReadyToListenState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 48),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "What's your responsibility or goal today? I'm here to help you.",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: FloatingActionButton(
                  onPressed: () {
                    context.read<MainInteractionBloc>().add(const StartListening());
                  },
                  backgroundColor: Colors.black,
                  child: const Text('Record', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckingPermissionState extends StatelessWidget {
  const _CheckingPermissionState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Checking microphone permission...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.1),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.grey,
                  child: const Text('Record', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningState extends StatelessWidget {
  final String transcript;
  const _ListeningState({required this.transcript});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  transcript.isEmpty ? 'Listening...' : transcript,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: FloatingActionButton(
                  onPressed: () {
                    context.read<MainInteractionBloc>().add(StopListeningAndSend());
                  },
                  backgroundColor: Colors.redAccent,
                  child: const Text('Stop', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Incoming advice...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  CircularProgressIndicator(),
                ],
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.1),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Colors.grey,
                  child: const Text('Record', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseStateWidget extends StatefulWidget {
  final String response;
  const _ResponseStateWidget({required this.response});

  @override
  State<_ResponseStateWidget> createState() => _ResponseStateWidgetState();
}

class _ResponseStateWidgetState extends State<_ResponseStateWidget> {
  bool _showOkay = false;
  late final Duration _fadeDuration;
  late final MainInteractionBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<MainInteractionBloc>();
    final wordCount = widget.response.trim().isEmpty
        ? 1
        : widget.response.trim().split(RegExp(r'\s+')).length;
    _fadeDuration = Duration(milliseconds: wordCount * 200);
  }

  void _onFadeInComplete() {
    setState(() => _showOkay = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EvilResponseFade(
          response: widget.response,
          memeAssetPath: 'assets/images/the_meme.png',
          fadeDuration: _fadeDuration,
          onOkay: () {
            bloc.add(SummonAnotherPressed());
          },
          onFadeInComplete: _onFadeInComplete,
          showOkay: _showOkay,
        ),
      ),
    );
  }
} 