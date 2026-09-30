import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../auth/views/sign_in_screen.dart';
import '../../../navigation/main_navigation_shell.dart';

/// Sensory Appetite-Inducing Splash Screen for JEEROLA
/// Designed to visually stimulate hunger through sizzling heat particles,
/// rising aromatic steam ribbons, cumin seed embers, and pulsing aroma waves.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Continuous loop controller for cooking physics (steam, embers, jeera seeds)
  late final AnimationController _sizzleController;

  // Single timeline controller for splash entry & text sequence
  late final AnimationController _timelineController;

  // Animations
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _hearthGlowAnimation;

  int _hungerStage = 0; // 0 = Sizzle, 1 = Aroma, 2 = Savor / Brand
  Timer? _stage1Timer;
  Timer? _stage2Timer;
  Timer? _autoNavTimer;
  bool _hasNavigated = false;

  // 32 pre-generated culinary particles (Cumin seeds, embers, ghee droplets)
  late final List<_CulinaryParticle> _particles;

  @override
  void initState() {
    super.initState();

    // 1. Sizzle Loop Controller (3.5s repeating smoothly)
    _sizzleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    // 2. Timeline Controller (3.2s total duration before navigation)
    _timelineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.05, 0.4, curve: Curves.easeIn),
      ),
    );

    _hearthGlowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(
        parent: _timelineController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOutSine),
      ),
    );

    _particles = _generateCulinaryParticles();

    _timelineController.forward();

    // Stage 1: Sizzle
    _stage1Timer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _hungerStage = 1);
    });

    // Stage 2: Aroma
    _stage2Timer = Timer(const Duration(milliseconds: 2100), () {
      if (mounted) setState(() => _hungerStage = 2);
    });

    // Auto navigate after duration
    _autoNavTimer = Timer(const Duration(milliseconds: 3200), () {
      _navigateToNext();
    });
  }

  List<_CulinaryParticle> _generateCulinaryParticles() {
    final rand = math.Random(42); // deterministic seed for beautiful harmony
    final list = <_CulinaryParticle>[];

    for (int i = 0; i < 30; i++) {
      final isJeera = i % 2 == 0;
      list.add(
        _CulinaryParticle(
          xRatio: 0.15 + (rand.nextDouble() * 0.70), // concentrated in center-mid
          startOffsetY: rand.nextDouble(),
          speed: 0.5 + (rand.nextDouble() * 0.7),
          size: isJeera ? (6.0 + rand.nextDouble() * 5.0) : (2.5 + rand.nextDouble() * 3.5),
          phase: rand.nextDouble() * math.pi * 2,
          swayAmount: 12.0 + (rand.nextDouble() * 22.0),
          isJeeraSeed: isJeera,
          color: isJeera
              ? Color.lerp(const Color(0xFFD87A22), const Color(0xFFFFB300), rand.nextDouble())!
              : Color.lerp(const Color(0xFFFF5722), const Color(0xFFFFD54F), rand.nextDouble())!,
        ),
      );
    }
    return list;
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _stage1Timer?.cancel();
    _stage2Timer?.cancel();
    _autoNavTimer?.cancel();

    final authVm = context.read<AuthViewModel>();
    final destination = authVm.isLoggedIn
        ? const MainNavigationShell()
        : const SignInScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _stage1Timer?.cancel();
    _stage2Timer?.cancel();
    _autoNavTimer?.cancel();
    _sizzleController.dispose();
    _timelineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C), // Deep Charcoal Velvet
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNext,
        child: Stack(
          children: [
            // 1. Hearth Fire Background Glow (Simulating charcoal oven / tandoor)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _hearthGlowAnimation,
                builder: (context, _) {
                  final glow = _hearthGlowAnimation.value;
                  return Stack(
                    children: [
                      // Warm Center Radiance
                      Center(
                        child: Container(
                          width: screenSize.width * 0.95,
                          height: screenSize.width * 0.95,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: glow * 0.38),
                                AppColors.secondary.withValues(alpha: glow * 0.18),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Bottom Sizzling Tawa Fire Halo
                      Positioned(
                        bottom: -80,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 260,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.bottomCenter,
                              radius: 1.1,
                              colors: [
                                const Color(0xFFFF3D00).withValues(alpha: glow * 0.32),
                                const Color(0xFFFFA000).withValues(alpha: glow * 0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 2. Continuous Sizzle, Steam Wisps, & Cumin Seed Embers Canvas
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _sizzleController,
                builder: (context, _) {
                  return CustomPaint(
                    size: screenSize,
                    painter: _SizzleAndSteamPainter(
                      animationValue: _sizzleController.value,
                      particles: _particles,
                    ),
                  );
                },
              ),
            ),

            // 3. Center Gourmet Cloche / Sizzling Pan Presentation (Safely scrollable if screen height is constrained)
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: AnimatedBuilder(
                      animation: _timelineController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Golden Sizzling Tawa Base / Cloche Silhouette
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Concentric Expanding Aroma Wave Rings
                                    AnimatedBuilder(
                                      animation: _sizzleController,
                                      builder: (context, _) {
                                        return CustomPaint(
                                          size: const Size(220, 220),
                                          painter: _AromaWavesPainter(
                                            progress: _sizzleController.value,
                                          ),
                                        );
                                      },
                                    ),

                                    // Glowing Culinary Rim
                                    Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const RadialGradient(
                                          colors: [
                                            Color(0xFF261208),
                                            Color(0xFF160904),
                                            Color(0xFF0E0E11),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: AppColors.gold.withValues(alpha: 0.65),
                                          width: 2.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.45),
                                            blurRadius: 36,
                                            spreadRadius: 4,
                                          ),
                                          BoxShadow(
                                            color: AppColors.secondary.withValues(alpha: 0.3),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: AppLogo(
                                          size: AppLogoSize.splash,
                                          showText: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 28),

                                // Jeerola Brand Typography with Saffron Accents
                                Text(
                                  'JEEROLA',
                                  style: AppTypography.displayLg.copyWith(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4.5,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.primary.withValues(alpha: 0.8),
                                        blurRadius: 18,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'AUTHENTIC FLAVORS • SIZZLING TADKA',
                                  style: AppTypography.metadata.copyWith(
                                    color: AppColors.secondary,
                                    letterSpacing: 2.5,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // 4. Salivation-Inducing Kinetic Storyline Banner
                                _buildSensoryAppetiteBadge(),

                                // Buffer space so content doesn't clash with bottom indicator on small devices
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 5. Bottom Live Kitchen Engine Status
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Heat Indicator Bar
                    SizedBox(
                      width: 120,
                      height: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: const LinearProgressIndicator(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE KITCHEN ACTIVE • READY IN 10-15 MINS',
                            style: AppTypography.metadata.copyWith(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dynamic Hunger-Triggering Narrative Badge
  Widget _buildSensoryAppetiteBadge() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildStageContent(_hungerStage),
    );
  }

  Widget _buildStageContent(int stage) {
    String text;
    IconData icon;
    Color iconColor;

    switch (stage) {
      case 0:
        text = 'Sizzling Tadka in Pure Desi Ghee...';
        icon = Icons.whatshot_rounded;
        iconColor = const Color(0xFFFF5722);
        break;
      case 1:
        text = 'Aroma of Freshly Roasted Spices...';
        icon = Icons.soup_kitchen_rounded;
        iconColor = const Color(0xFFFFA000);
        break;
      case 2:
      default:
        text = 'Crave Authentic. Served Piping Hot.';
        icon = Icons.restaurant_rounded;
        iconColor = const Color(0xFFFFD54F);
        break;
    }

    return Container(
      key: ValueKey<int>(stage),
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMd.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Culinary Particle Data
class _CulinaryParticle {
  final double xRatio;
  final double startOffsetY;
  final double speed;
  final double size;
  final double phase;
  final double swayAmount;
  final bool isJeeraSeed;
  final Color color;

  _CulinaryParticle({
    required this.xRatio,
    required this.startOffsetY,
    required this.speed,
    required this.size,
    required this.phase,
    required this.swayAmount,
    required this.isJeeraSeed,
    required this.color,
  });
}

/// CustomPainter that renders dancing golden cumin seeds, glowing ember sparks,
/// and undulating steam wisps rising into the air.
class _SizzleAndSteamPainter extends CustomPainter {
  final double animationValue;
  final List<_CulinaryParticle> particles;

  _SizzleAndSteamPainter({
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    // 1. Draw Rising Steam Wisps (Soft Gaussian curves)
    final steamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width * 0.5;
    final bottomY = size.height * 0.72;

    // 3 distinct rising steam trails
    for (int s = -1; s <= 1; s++) {
      final steamPath = Path();
      final steamOffset = s * 34.0;
      final wavePhase = animationValue * math.pi * 2 + (s * 1.8);

      steamPath.moveTo(centerX + steamOffset, bottomY);

      // Curve upward with dynamic sinusoidal sway
      final cp1x = centerX + steamOffset + math.sin(wavePhase) * 22.0;
      final cp1y = bottomY - 90;
      final cp2x = centerX + steamOffset - math.cos(wavePhase) * 28.0;
      final cp2y = bottomY - 190;
      final endX = centerX + steamOffset + math.sin(wavePhase + 1.0) * 36.0;
      final endY = bottomY - 290;

      steamPath.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, endY);

      steamPaint
        ..strokeWidth = 14.0 + (s.abs() * 4.0)
        ..color = const Color(0xFFFFF3E0).withValues(alpha: 0.05 + (0.03 * math.sin(wavePhase).abs()));

      canvas.drawPath(steamPath, steamPaint);

      // Delicate central bright core of the steam
      steamPaint
        ..strokeWidth = 4.0
        ..color = const Color(0xFFFFE0B2).withValues(alpha: 0.11);
      canvas.drawPath(steamPath, steamPaint);
    }

    // 2. Draw Floating Cumin Seeds & Glowing Heat Sparks
    for (final p in particles) {
      // Calculate continuous looping vertical position
      final progress = (p.startOffsetY - (animationValue * p.speed)) % 1.0;
      final y = (progress < 0 ? progress + 1.0 : progress) * size.height;

      // Horizontal position with sinusoidal wobble
      final x = (p.xRatio * size.width) +
          math.sin((animationValue * math.pi * 2) + p.phase) * p.swayAmount;

      // Alpha envelope: fade-in at bottom, fade-out as it floats past top
      double alpha = 1.0;
      if (y > size.height * 0.82) {
        alpha = (size.height - y) / (size.height * 0.18);
      } else if (y < size.height * 0.22) {
        alpha = y / (size.height * 0.22);
      }
      alpha = alpha.clamp(0.0, 1.0);

      if (alpha <= 0.01) continue;

      particlePaint.color = p.color.withValues(alpha: alpha * 0.85);

      if (p.isJeeraSeed) {
        // Draw Authentic Cumin Seed (Oval grain rotated gently)
        canvas.save();
        canvas.translate(x, y);
        final angle = math.sin((animationValue * math.pi * 3) + p.phase) * 0.75;
        canvas.rotate(angle);

        final seedRect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 0.45,
          height: p.size,
        );
        final seedRRect = RRect.fromRectAndRadius(
          seedRect,
          Radius.circular(p.size * 0.25),
        );
        canvas.drawRRect(seedRRect, particlePaint);

        // Little golden highlight down the center of the cumin seed
        final highlightPaint = Paint()
          ..color = const Color(0xFFFFE082).withValues(alpha: alpha * 0.7)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(0, -p.size * 0.3),
          Offset(0, p.size * 0.3),
          highlightPaint,
        );

        canvas.restore();
      } else {
        // Draw Glowing Ember Spark with Soft Glow
        final glowPaint = Paint()
          ..color = p.color.withValues(alpha: alpha * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawCircle(Offset(x, y), p.size * 1.8, glowPaint);
        canvas.drawCircle(Offset(x, y), p.size * 0.7, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SizzleAndSteamPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// CustomPainter that renders radiating concentric aroma ripples
class _AromaWavesPainter extends CustomPainter {
  final double progress;

  _AromaWavesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.58;

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i * 0.33)) % 1.0;
      final radius = 60.0 + (ringProgress * (maxRadius - 60.0));
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.35;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(
          const Color(0xFFFF5722),
          const Color(0xFFFFB300),
          ringProgress,
        )!
            .withValues(alpha: opacity);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AromaWavesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
