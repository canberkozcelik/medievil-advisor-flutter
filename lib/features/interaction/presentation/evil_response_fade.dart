import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EvilResponseFade extends StatefulWidget {
  final String response;
  final String memeAssetPath;
  final Duration fadeDuration;
  final VoidCallback onOkay;
  final VoidCallback onFadeInComplete;
  final bool showOkay;

  const EvilResponseFade({
    Key? key,
    required this.response,
    required this.memeAssetPath,
    required this.fadeDuration,
    required this.onOkay,
    required this.onFadeInComplete,
    required this.showOkay,
  }) : super(key: key);

  @override
  State<EvilResponseFade> createState() => _EvilResponseFadeState();
}

class _EvilResponseFadeState extends State<EvilResponseFade> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFadeInComplete();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final topMargin = screenHeight * 0.25;
    return Stack(
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: SizedBox.expand(
            child: Image.asset(
              widget.memeAssetPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 0, right: 0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: mediaQuery.size.width * 0.5,
                    // Remove maxHeight constraint to allow full growth
                    margin: EdgeInsets.only(top: topMargin, right: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AutoSizeText(
                      widget.response,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      minFontSize: 12,
                      maxLines: 100,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showOkay)
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: widget.onOkay,
                child: const Text('Ooh-kaay?'),
              ),
            ),
          ),
      ],
    );
  }
} 