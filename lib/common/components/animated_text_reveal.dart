import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vibration/vibration.dart';

class AnimatedTextReveal extends HookWidget {
  const AnimatedTextReveal({
    required this.text,
    required this.textStyle,
    this.delay = Duration.zero,
    this.characterDelay = const Duration(milliseconds: 100),
    this.enableHapticFeedback = true,
    this.curve = Curves.easeOut,
    super.key,
  });

  final String text;
  final TextStyle textStyle;
  final Duration delay;
  final Duration characterDelay;
  final bool enableHapticFeedback;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final visibleCharacters = useState(0);
    final isStarted = useState(false);

    Future<void> triggerCharacterFeedback() async {
      if (!enableHapticFeedback) return;

      try {
        // 軽い触感フィードバック
        await HapticFeedback.selectionClick();

        // 短い振動（Android）
        if (await Vibration.hasVibrator() == true) {
          await Vibration.vibrate(duration: 30, amplitude: 80);
        }
      } catch (e) {
        debugPrint('Haptic feedback error: $e');
      }
    }

    useEffect(() {
      final timer = Timer(delay, () async {
        isStarted.value = true;

        for (int i = 0; i <= text.length; i++) {
          if (i > 0) {
            await triggerCharacterFeedback();
          }
          visibleCharacters.value = i;

          if (i < text.length) {
            await Future<void>.delayed(characterDelay);
          }
        }
      });

      return () {
        timer.cancel();
      };
    }, []);

    if (!isStarted.value) {
      return SizedBox(
        height: textStyle.fontSize ?? 16,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < text.length; i++)
          AnimatedOpacity(
            opacity: i < visibleCharacters.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: curve,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: curve,
              transform: Matrix4.translationValues(
                0,
                i < visibleCharacters.value ? 0 : 10,
                0,
              ),
              child: Text(
                text[i],
                style: textStyle,
              ),
            ),
          ),
      ],
    );
  }
}

class PulsingIcon extends HookWidget {
  const PulsingIcon({
    required this.icon,
    this.size = 24,
    this.color,
    this.pulseColor,
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
    super.key,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final Color? pulseColor;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: duration,
    );
    final shouldStart = useState(false);
    final timer = useRef<Timer?>(null);

    useEffect(() {
      timer.value = Timer(delay, () {
        if (shouldStart.value == false) {
          shouldStart.value = true;
          animationController.repeat(reverse: true);
        }
      });

      return () {
        timer.value?.cancel();
      };
    }, []);

    if (!shouldStart.value) {
      return SizedBox(width: size, height: size);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background circle
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Container(
              width: size * (1.5 + animationController.value * 0.3),
              height: size * (1.5 + animationController.value * 0.3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (pulseColor ?? Theme.of(context).primaryColor)
                    .withValues(alpha: 0.3 * (1 - animationController.value)),
              ),
            );
          },
        ),
        // Icon
        Icon(
          icon,
          size: size,
          color: color ?? Theme.of(context).primaryColor,
        )
            .animate()
            .scale(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
            )
            .fadeIn(
              duration: const Duration(milliseconds: 400),
            ),
      ],
    );
  }
}

class BouncingDots extends HookWidget {
  const BouncingDots({
    this.dotCount = 3,
    this.size = 8,
    this.color,
    this.spacing = 4,
    this.animationDuration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    super.key,
  });

  final int dotCount;
  final double size;
  final Color? color;
  final double spacing;
  final Duration animationDuration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final shouldStart = useState(false);
    final timer = useRef<Timer?>(null);

    useEffect(() {
      timer.value = Timer(delay, () {
        if (shouldStart.value == false) {
          shouldStart.value = true;
        }
      });
      return () {
        timer.value?.cancel();
      };
    }, []);

    if (!shouldStart.value) {
      return SizedBox(
        width: (size * dotCount) + (spacing * (dotCount - 1)),
        height: size,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        dotCount,
        (index) => Container(
          margin: EdgeInsets.only(
            right: index < dotCount - 1 ? spacing : 0,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color ?? Theme.of(context).primaryColor,
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .moveY(
                begin: 0,
                end: -size,
                duration: animationDuration,
                curve: Curves.easeInOut,
                delay: Duration(milliseconds: index * 200),
              ),
        ),
      ),
    );
  }
}
