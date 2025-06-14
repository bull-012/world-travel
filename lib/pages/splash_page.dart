import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:world_travel/common/components/animated_text_reveal.dart';

class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showBackgroundGradient = useState(false);
    final showLogo = useState(false);
    final showTitle = useState(false);
    final showSubtitle = useState(false);
    final showProgress = useState(false);
    final showFloatingParticles = useState(false);
    final showSkipButton = useState(false);
    final isSkipped = useState(false);

    // Timer references for cleanup on skip
    final timers = useState(<Timer>[]);

    // カスタムな触感フィードバック関数
    Future<void> triggerHapticFeedback({
      HapticFeedbackType type = HapticFeedbackType.lightImpact,
    }) async {
      try {
        // iOS/Android の触感フィードバック
        switch (type) {
          case HapticFeedbackType.lightImpact:
            await HapticFeedback.lightImpact();
          case HapticFeedbackType.mediumImpact:
            await HapticFeedback.mediumImpact();
          case HapticFeedbackType.heavyImpact:
            await HapticFeedback.heavyImpact();
          case HapticFeedbackType.selectionClick:
            await HapticFeedback.selectionClick();
        }

        // 追加の振動フィードバック（Android）
        if (await Vibration.hasVibrator()) {
          final amplitude = switch (type) {
            HapticFeedbackType.lightImpact => 50,
            HapticFeedbackType.mediumImpact => 100,
            HapticFeedbackType.heavyImpact => 150,
            HapticFeedbackType.selectionClick => 30,
          };
          await Vibration.vibrate(duration: 50, amplitude: amplitude);
        }
      } on Exception catch (e) {
        // エラーハンドリング
        debugPrint('Haptic feedback error: $e');
      }
    }

    // スキップ機能
    Future<void> skipToHome() async {
      if (isSkipped.value) return;
      isSkipped.value = true;

      // すべてのタイマーをキャンセル
      for (final timer in timers.value) {
        timer.cancel();
      }
      timers.value = [];

      await triggerHapticFeedback(type: HapticFeedbackType.heavyImpact);

      if (context.mounted) {
        GoRouter.of(context).go('/');
      }
    }

    useEffect(
      () {
        // スプラッシュアニメーションのシーケンス
        final timerList = <Timer>[
          Timer(const Duration(milliseconds: 100), () {
            if (!isSkipped.value) showBackgroundGradient.value = true;
          }),
          Timer(const Duration(milliseconds: 400), () {
            if (!isSkipped.value) {
              showFloatingParticles.value = true;
              triggerHapticFeedback();
            }
          }),
          Timer(const Duration(milliseconds: 800), () {
            if (!isSkipped.value) {
              showLogo.value = true;
              triggerHapticFeedback(type: HapticFeedbackType.mediumImpact);
            }
          }),
          Timer(const Duration(milliseconds: 1500), () {
            if (!isSkipped.value) showSkipButton.value = true;
          }),
          Timer(const Duration(milliseconds: 1800), () {
            if (!isSkipped.value) {
              showTitle.value = true;
              triggerHapticFeedback();
            }
          }),
          Timer(const Duration(milliseconds: 2600), () {
            if (!isSkipped.value) {
              showSubtitle.value = true;
              triggerHapticFeedback(type: HapticFeedbackType.selectionClick);
            }
          }),
          Timer(const Duration(milliseconds: 3200), () {
            if (!isSkipped.value) {
              showProgress.value = true;
              triggerHapticFeedback();
            }
          }),
          Timer(const Duration(milliseconds: 5000), () async {
            if (!isSkipped.value) {
              await triggerHapticFeedback(
                type: HapticFeedbackType.heavyImpact,
              );
              if (context.mounted) {
                GoRouter.of(context).go('/');
              }
            }
          }),
        ];

        timers.value = timerList;

        return () {
          // Cleanup function
          for (final timer in timerList) {
            timer.cancel();
          }
        };
      },
      [],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: GestureDetector(
        onTap: skipToHome,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < -300) {
            // Swipe up to skip
            skipToHome();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: showBackgroundGradient.value
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE3F2FD),
                      const Color(0xFFF3E5F5),
                      Colors.blue.shade50,
                    ],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFAFAFA), Color(0xFFFAFAFA)],
                  ),
          ),
          child: Stack(
            children: [
              // Floating particles background
              if (showFloatingParticles.value)
                const Positioned.fill(
                  child: FloatingParticles(),
                ),

              // Skip button
              if (showSkipButton.value)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: skipToHome,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'スキップ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )
                      .slideX(
                        begin: 0.3,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      ),
                ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(), // Top spacer
                    ),

                    // Logo section
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // App Logo/Icon with pulsing effect
                            if (showLogo.value)
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulsing background
                                  PulsingIcon(
                                    icon: Icons.circle,
                                    size: 160,
                                    color: Colors.blue.shade100.withValues(
                                      alpha: 0.3,
                                    ),
                                    pulseColor: Colors.blue.shade200,
                                    duration:
                                        const Duration(milliseconds: 2000),
                                  ),
                                  // Main logo container
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade600
                                              .withValues(alpha: 0.4),
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.flight_takeoff,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  )
                                      .animate()
                                      .scale(
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        curve: Curves.elasticOut,
                                      )
                                      .fadeIn(
                                        duration:
                                            const Duration(milliseconds: 800),
                                        curve: Curves.easeOut,
                                      )
                                      .shimmer(
                                        duration:
                                            const Duration(milliseconds: 1500),
                                        delay:
                                            const Duration(milliseconds: 1000),
                                      ),
                                ],
                              ),

                            const SizedBox(height: 40),

                            // App Title with character reveal animation
                            if (showTitle.value)
                              AnimatedTextReveal(
                                text: 'World Travel',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1565C0),
                                      letterSpacing: 1.5,
                                      fontSize: 32,
                                    ),
                                delay: const Duration(milliseconds: 200),
                                characterDelay:
                                    const Duration(milliseconds: 80),
                              ),

                            const SizedBox(height: 20),

                            // Subtitle with character reveal animation
                            if (showSubtitle.value)
                              AnimatedTextReveal(
                                text: '世界への扉を開こう',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                    ),
                                delay: const Duration(milliseconds: 400),
                                characterDelay:
                                    const Duration(milliseconds: 60),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Progress indicator section
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (showProgress.value) ...[
                            // Custom animated progress bar
                            Container(
                              width: 240,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 240,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade400,
                                          Colors.blue.shade600,
                                          Colors.purple.shade400,
                                        ],
                                      ),
                                    ),
                                  )
                                      .animate(
                                        onComplete: (controller) =>
                                            controller.repeat(),
                                      )
                                      .slideX(
                                        begin: -1.2,
                                        end: 1.2,
                                        duration:
                                            const Duration(milliseconds: 2000),
                                        curve: Curves.easeInOut,
                                      ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                )
                                .slideY(
                                  begin: 0.5,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                ),

                            const SizedBox(height: 32),

                            // Loading text with bouncing dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'アプリを準備中',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                BouncingDots(
                                  size: 6,
                                  color: Colors.grey.shade600,
                                  delay: const Duration(milliseconds: 200),
                                ),
                              ],
                            ).animate().fadeIn(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                  delay: const Duration(milliseconds: 200),
                                ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
}

class FloatingParticles extends StatefulWidget {
  const FloatingParticles({super.key});

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      8,
      (index) => AnimationController(
        duration: Duration(milliseconds: 3000 + (index * 500)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 1.2),
        end: const Offset(0, -0.2),
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear),
      );
    }).toList();

    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 400), () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        _controllers.length,
        (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return SlideTransition(
              position: _animations[index],
              child: Align(
                alignment: Alignment(
                  -1 + (index * 0.3),
                  0,
                ),
                child: Container(
                  width: 4 + (index % 3) * 2,
                  height: 4 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: [
                      Colors.blue.shade200,
                      Colors.purple.shade200,
                      Colors.cyan.shade200,
                    ][index % 3]
                        .withValues(alpha: 0.6),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
