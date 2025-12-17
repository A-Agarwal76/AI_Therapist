import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chonoes/services/voice_service.dart';

class TalkingAvatar extends StatefulWidget {
  final VoiceService voiceService;
  final double size;
  final bool showInAppBar;

  const TalkingAvatar({
    super.key,
    required this.voiceService,
    this.size = 60.0,
    this.showInAppBar = false,
  });

  @override
  State<TalkingAvatar> createState() => _TalkingAvatarState();
}

class _TalkingAvatarState extends State<TalkingAvatar>
    with TickerProviderStateMixin {
  late AnimationController _mouthController;
  late AnimationController _blinkController;
  late AnimationController _pulseController;
  late Animation<double> _mouthAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _pulseAnimation;
  
  Timer? _blinkTimer;
  bool _isBlinking = false;
  bool _wasSpeaking = false;

  @override
  void initState() {
    super.initState();

    // Mouth animation for talking
    _mouthController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _mouthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mouthController, curve: Curves.easeInOut),
    );

    // Blink animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Pulse animation for speaking
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startBlinking();
    _checkSpeakingState();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isBlinking && !widget.voiceService.isSpeaking) {
        _isBlinking = true;
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _isBlinking = false;
          });
        });
      }
    });
  }

  void _checkSpeakingState() {
    // Listen to voice service changes
    widget.voiceService.addListener(_onVoiceStateChanged);
    
    // Also check periodically as backup
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        widget.voiceService.removeListener(_onVoiceStateChanged);
        return;
      }
      _updateSpeakingState();
    });
  }

  void _onVoiceStateChanged() {
    if (mounted) {
      _updateSpeakingState();
    }
  }

  void _updateSpeakingState() {
    final isSpeaking = widget.voiceService.isSpeaking;
    
    if (isSpeaking != _wasSpeaking) {
      setState(() {
        _wasSpeaking = isSpeaking;
      });

      if (isSpeaking) {
        // Start talking animations
        _mouthController.repeat(reverse: true);
        _pulseController.repeat(reverse: true);
      } else {
        // Stop talking animations
        _mouthController.stop();
        _mouthController.reset();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    widget.voiceService.removeListener(_onVoiceStateChanged);
    _mouthController.dispose();
    _blinkController.dispose();
    _pulseController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mouthAnimation,
        _blinkAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: widget.voiceService.isSpeaking
                  ? [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Face
                _buildFace(),
                // Mouth
                _buildMouth(),
                // Eyes
                _buildEyes(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFace() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  Widget _buildEyes() {
    return Positioned(
      top: widget.size * 0.3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left eye
          Container(
            width: widget.size * 0.12,
            height: widget.size * 0.12 * _blinkAnimation.value,
            margin: EdgeInsets.symmetric(horizontal: widget.size * 0.15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF667eea),
            ),
          ),
          // Right eye
          Container(
            width: widget.size * 0.12,
            height: widget.size * 0.12 * _blinkAnimation.value,
            margin: EdgeInsets.symmetric(horizontal: widget.size * 0.15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF667eea),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMouth() {
    final mouthHeight = widget.voiceService.isSpeaking
        ? widget.size * 0.15 * (0.3 + _mouthAnimation.value * 0.7)
        : widget.size * 0.08;

    return Positioned(
      bottom: widget.size * 0.25,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size * 0.3,
        height: mouthHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size * 0.15),
          color: const Color(0xFF667eea),
        ),
      ),
    );
  }
}

