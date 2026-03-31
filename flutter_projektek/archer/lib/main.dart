import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(const ArcherGameApp());
  });
}

class ArcherGameApp extends StatelessWidget {
  const ArcherGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archer Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF87CEEB), // Sky Blue
        fontFamily: 'Roboto',
      ),
      home: const MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  int _highScore = 0;
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('high_score') ?? 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky Blue
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: 50,
            left: 100,
            child: Icon(
              Icons.cloud,
              color: Colors.white.withOpacity(0.6),
              size: 100,
            ),
          ),
          Positioned(
            top: 150,
            right: 80,
            child: Icon(
              Icons.cloud,
              color: Colors.white.withOpacity(0.4),
              size: 140,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ARCHER\nMASTER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(3, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'HIGH SCORE: $_highScore',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 50),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ArcherGameScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 20,
                      ),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.black54,
                    ),
                    child: const Text(
                      'TAP TO START',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArcherGameScreen extends StatefulWidget {
  const ArcherGameScreen({super.key});

  @override
  State<ArcherGameScreen> createState() => _ArcherGameScreenState();
}

enum GameState { idle, aiming, shooting, gameOver }

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double life;
  double maxLife;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.life,
  }) : maxLife = life;
}

class FloatingText {
  Offset position;
  String text;
  double life;
  double maxLife;

  FloatingText({required this.position, required this.text, required this.life})
    : maxLife = life;
}

class _ArcherGameScreenState extends State<ArcherGameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // Game state
  GameState _gameState = GameState.idle;
  int _score = 0;
  int _highScore = 0;
  int _arrowsRemaining = 5;
  int _level = 1;
  int _combo = 0;

  // Physics constraints
  final double _gravity = 980.0;
  final double _groundY = 50.0; // from bottom
  final Offset _bowPosition = const Offset(
    100,
    300,
  ); // Fixed position for the bow

  // Arrow physics
  Offset _arrowPos = Offset.zero;
  double _arrowAngle = 0.0;
  Offset _arrowVelocity = Offset.zero;

  // Aiming
  Offset _dragStart = Offset.zero;
  Offset _dragCurrent = Offset.zero;
  final double _maxPullDistance = 150.0;

  // Target
  Offset _targetPosition = const Offset(600, 300);
  double _targetRadius = 40.0;
  double _wind = 0.0; // Wind velocity
  double _targetTime = 0.0; // For target movement animation

  // Effects
  List<Particle> _particles = [];
  List<FloatingText> _floatingTexts = [];
  double _cameraShake = 0.0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _resetArrow();
    _generateLevel();
    _ticker = createTicker(_tick);
    _ticker.start(); // Continuously running for animations & particles
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('high_score') ?? 0;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _generateLevel() {
    final rand = math.Random();
    double targetX = 400.0 + rand.nextDouble() * 300.0;
    // Lowered the minimum Y position so it doesn't spawn offscreen or too high.
    // Assuming Y=0 is top, we want it to be lower (larger Y).
    // Let's constrain Y between 150 and 250 explicitly.
    double targetY = 200.0 + rand.nextDouble() * 100.0;
    _targetPosition = Offset(targetX, targetY);
    _targetRadius = math.max(15.0, 50.0 - (_level * 2.0));
    _wind = (rand.nextDouble() - 0.5) * 200.0 * (_level / 5.0).clamp(0.0, 1.0);
    _targetTime = 0.0;
  }

  void _resetArrow() {
    _arrowPos = _bowPosition;
    _arrowAngle = 0.0;
    _arrowVelocity = Offset.zero;
    _dragStart = Offset.zero;
    _dragCurrent = Offset.zero;
  }

  void _spawnParticles(Offset pos, bool bullseye) {
    final rand = math.Random();
    int count = bullseye ? 50 : 20;
    for (int i = 0; i < count; i++) {
      double angle = rand.nextDouble() * math.pi * 2;
      double speed = rand.nextDouble() * (bullseye ? 300.0 : 150.0);
      _particles.add(
        Particle(
          position: pos,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: bullseye ? Colors.amberAccent : Colors.brown,
          life: 0.5 + rand.nextDouble() * 0.5,
        ),
      );
    }
  }

  void _tick(Duration elapsed) {
    final dt = 1.0 / 60.0; // Fixed timestep approx

    setState(() {
      // Update particles
      for (var p in _particles) {
        p.position += p.velocity * dt;
        p.velocity += Offset(0, _gravity * 0.5 * dt); // particles fall
        p.life -= dt;
      }
      _particles.removeWhere((p) => p.life <= 0);

      // Update floating texts
      for (var f in _floatingTexts) {
        f.position += const Offset(0, -50.0) * dt; // Float up
        f.life -= dt;
      }
      _floatingTexts.removeWhere((f) => f.life <= 0);

      // Shake decay
      if (_cameraShake > 0) {
        _cameraShake -= dt * 10;
        if (_cameraShake < 0) _cameraShake = 0;
      }

      // Moving target logic for higher levels
      if (_level > 2) {
        _targetTime += dt;
        double speed = math.min(_level * 0.5, 3.0);

        // Use base target position stored during _generateLevel
        // To strictly do this right we'd need a baseTargetPosition var, but this approximation pushes it slightly frame by frame.
        // For simplicity let's just make it wobble on Y axis.
        _targetPosition += Offset(
          0,
          math.cos(_targetTime * speed * 2) *
              1.5 *
              (_level / 3.0).clamp(1.0, 3.0),
        );
      }
      if (_gameState != GameState.shooting) return;

      // Wind affects horizontal velocity
      _arrowVelocity += Offset(_wind * 0.5 * dt, _gravity * dt);
      _arrowPos += _arrowVelocity * dt;
      // Update angle based on velocity vector
      _arrowAngle = math.atan2(_arrowVelocity.dy, _arrowVelocity.dx);

      _checkCollisions();
    });
  }

  void _checkCollisions() {
    // Ground collision
    final screenSize = MediaQuery.of(context).size;
    if (_arrowPos.dy >= screenSize.height - _groundY) {
      _finishShot(hit: false);
      return;
    }

    // Screen bounds (flew away)
    if (_arrowPos.dx > screenSize.width ||
        _arrowPos.dx < 0 ||
        _arrowPos.dy < 0) {
      _finishShot(hit: false);
      return;
    }

    // Target collision (simple circle collision)
    // The tip of the arrow is offset by the arrow length
    const arrowLength = 60.0;
    final tipPoint = Offset(
      _arrowPos.dx + math.cos(_arrowAngle) * arrowLength / 2,
      _arrowPos.dy + math.sin(_arrowAngle) * arrowLength / 2,
    );

    final dist = (tipPoint - _targetPosition).distance;
    if (dist <= _targetRadius) {
      // Calculate score based on distance from center (bullseye)
      int points = 10;
      bool isBullseye = false;
      if (dist < _targetRadius * 0.2) {
        points = 50;
        isBullseye = true;
      } else if (dist < _targetRadius * 0.5)
        points = 25;

      _combo++;
      int comboMultiplier =
          1 + (_combo ~/ 3); // Extra multiplier every 3 consecutive hits
      int totalPoints = points * comboMultiplier;

      _score += totalPoints;

      HapticFeedback.heavyImpact();
      if (isBullseye) {
        _cameraShake = 5.0;
      }

      _spawnParticles(tipPoint, isBullseye);
      _floatingTexts.add(
        FloatingText(
          position: tipPoint - const Offset(0, 20),
          text:
              '+$totalPoints${comboMultiplier > 1 ? ' (x$comboMultiplier)' : ''}',
          life: 1.5,
        ),
      );

      _finishShot(hit: true);
    }
  }

  void _finishShot({required bool hit}) async {
    if (!hit) {
      _combo = 0; // reset combo
      HapticFeedback.lightImpact();

      // Screen bounds finish might not need particles, but ground collision can
      if (_arrowPos.dy >= MediaQuery.of(context).size.height - _groundY) {
        _spawnParticles(_arrowPos, false);
      }
    }

    setState(() {
      _arrowsRemaining--;
      if (hit) {
        _level++;
        _generateLevel();
        _gameState = GameState.idle;
        _resetArrow();
      } else {
        if (_arrowsRemaining <= 0) {
          _gameState = GameState.gameOver;
          _checkHighScore();
        } else {
          _gameState = GameState.idle;
          _resetArrow();
        }
      }
    });
  }

  Future<void> _checkHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = prefs.getInt('high_score') ?? 0;
    if (_score > currentHigh) {
      await prefs.setInt('high_score', _score);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_gameState != GameState.idle && _gameState != GameState.aiming) return;
    setState(() {
      _gameState = GameState.aiming;
      _dragStart = details.localPosition;
      _dragCurrent = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_gameState != GameState.aiming) return;
    setState(() {
      _dragCurrent = details.localPosition;

      // Calculate pull vector (Angry birds style: pull back to shoot forward)
      final pullVector = _dragStart - _dragCurrent;
      double distance = pullVector.distance.clamp(0.0, _maxPullDistance);

      if (distance > 0) {
        _arrowAngle = math.atan2(pullVector.dy, pullVector.dx);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_gameState != GameState.aiming) return;

    final pullVector = _dragStart - _dragCurrent;
    double pullDistance = pullVector.distance.clamp(0.0, _maxPullDistance);

    if (pullDistance < 10.0) {
      // Tap or too small pull, cancel
      setState(() {
        _gameState = GameState.idle;
        _resetArrow();
      });
      return;
    }

    // Shoot
    setState(() {
      _gameState = GameState.shooting;
      HapticFeedback.mediumImpact();
      final power = pullDistance * 8;
      _arrowVelocity = Offset(
        math.cos(_arrowAngle) * power,
        math.sin(_arrowAngle) * power,
      );
      // Removed _ticker.start(); because ticker runs continuously now
    });
  }

  void _resetGame() {
    setState(() {
      _score = 0;
      _combo = 0;
      _arrowsRemaining = 5;
      _level = 1;
      _gameState = GameState.idle;
      _generateLevel();
      _resetArrow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Set static bow position relative to screen
    final bowPos = Offset(100, size.height - _groundY - 100);
    if (_gameState == GameState.idle) {
      _arrowPos = bowPos;
    }

    // Camera shake offset
    final rand = math.Random();
    final shakeOffset = _cameraShake > 0
        ? Offset(
            (rand.nextDouble() - 0.5) * _cameraShake * 10,
            (rand.nextDouble() - 0.5) * _cameraShake * 10,
          )
        : Offset.zero;

    return Scaffold(
      body: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            // Game rendering
            Transform.translate(
              offset: shakeOffset,
              child: CustomPaint(
                size: Size.infinite,
                painter: GamePainter(
                  bowPosition: bowPos,
                  arrowPosition: _arrowPos,
                  arrowAngle: _arrowAngle,
                  targetPosition: _targetPosition,
                  targetRadius: _targetRadius,
                  dragStart: _dragStart,
                  dragCurrent: _dragCurrent,
                  gameState: _gameState,
                  groundY: _groundY,
                  particles: _particles,
                  floatingTexts: _floatingTexts,
                  tickCount: _targetTime,
                ),
              ),
            ),

            // HUD
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score: $_score',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          'High Score: ${math.max(_score, _highScore)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          'Level: $_level',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Arrows: $_arrowsRemaining',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                        if (_wind.abs() > 10.0)
                          Row(
                            children: [
                              Text(
                                'Wind ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                _wind > 0
                                    ? Icons.arrow_forward
                                    : Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Game Over Overlay
            if (_gameState == GameState.gameOver)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Game Over!',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Final Score: $_score',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: _resetGame,
                        child: const Text(
                          'Play Again',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MainMenuScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Main Menu',
                          style: TextStyle(fontSize: 20, color: Colors.white),
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
}

class GamePainter extends CustomPainter {
  final Offset bowPosition;
  final Offset arrowPosition;
  final double arrowAngle;
  final Offset targetPosition;
  final double targetRadius;
  final Offset dragStart;
  final Offset dragCurrent;
  final GameState gameState;
  final double groundY;
  final List<Particle> particles;
  final List<FloatingText> floatingTexts;
  final double tickCount;

  GamePainter({
    required this.bowPosition,
    required this.arrowPosition,
    required this.arrowAngle,
    required this.targetPosition,
    required this.targetRadius,
    required this.dragStart,
    required this.dragCurrent,
    required this.gameState,
    required this.groundY,
    required this.particles,
    required this.floatingTexts,
    required this.tickCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Parallax Background
    _drawBackground(canvas, size);

    // Draw Ground
    final groundPaint = Paint()..color = const Color(0xFF2E8B57); // Sea Green
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - groundY, size.width, groundY),
      groundPaint,
    );

    // Draw Target
    _drawTarget(canvas);

    // Draw Bow
    _drawBow(canvas);

    // Draw Arrow
    _drawArrow(canvas);

    // Draw trajectory prediction if aiming (Optional enhancement)
    if (gameState == GameState.aiming) {
      _drawTrajectory(canvas, size);
    }

    // Draw Particles
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color.withOpacity((p.life / p.maxLife).clamp(0.0, 1.0));
      canvas.drawCircle(p.position, 3.0, paint);
    }

    // Draw Floating Texts
    for (var f in floatingTexts) {
      final textSpan = TextSpan(
        text: f.text,
        style: TextStyle(
          color: Colors.white.withOpacity((f.life / f.maxLife).clamp(0.0, 1.0)),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        f.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Sun
    final sunPaint = Paint()..color = Colors.amber.withOpacity(0.8);
    canvas.drawCircle(const Offset(150, 100), 40, sunPaint);

    // Clouds (simple)
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.6);
    double cloudOffset = tickCount * 10; // slowly moving clouds
    _drawCloud(
      canvas,
      Offset((200 + cloudOffset) % size.width, 120),
      cloudPaint,
    );
    _drawCloud(
      canvas,
      Offset((500 + cloudOffset * 0.8) % size.width, 80),
      cloudPaint,
    );
    _drawCloud(
      canvas,
      Offset((800 + cloudOffset * 1.2) % size.width, 150),
      cloudPaint,
    );

    // Distant Mountains
    final mountPaint = Paint()..color = Colors.teal.withOpacity(0.3);
    final mountPath = Path();
    mountPath.moveTo(0, size.height - groundY);
    mountPath.lineTo(size.width * 0.3, size.height - groundY - 150);
    mountPath.lineTo(size.width * 0.6, size.height - groundY);
    mountPath.lineTo(size.width * 0.8, size.height - groundY - 100);
    mountPath.lineTo(size.width, size.height - groundY - 50);
    mountPath.lineTo(size.width, size.height - groundY);
    mountPath.close();
    canvas.drawPath(mountPath, mountPaint);
  }

  void _drawCloud(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center, 20, paint);
    canvas.drawCircle(center + const Offset(20, -10), 25, paint);
    canvas.drawCircle(center + const Offset(40, 0), 20, paint);
    canvas.drawCircle(center + const Offset(20, 10), 20, paint);
  }

  void _drawTarget(Canvas canvas) {
    final colors = [
      Colors.red,
      Colors.white,
      Colors.red,
      Colors.white,
      Colors.yellow,
    ];
    final step = targetRadius / colors.length;

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()..color = colors[i];
      canvas.drawCircle(targetPosition, targetRadius - (i * step), paint);
    }

    // Draw target stand
    final standPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 6;
    canvas.drawLine(
      Offset(targetPosition.dx, targetPosition.dy + targetRadius),
      Offset(targetPosition.dx, targetPosition.dy + targetRadius + 100),
      standPaint,
    );
  }

  void _drawBow(Canvas canvas) {
    final bowPaint = Paint()
      ..color = Colors.brown[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final stringPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const bowHeight = 100.0;
    const bowCurve = 30.0;

    // Bow rotation based on aiming angle
    canvas.save();
    canvas.translate(bowPosition.dx, bowPosition.dy);

    double renderingAngle = arrowAngle;
    if (gameState == GameState.idle) {
      renderingAngle = 0.0; // Default look right
    }
    canvas.rotate(renderingAngle);

    // Draw bow wood
    final path = Path();
    path.moveTo(0, -bowHeight / 2);
    path.quadraticBezierTo(bowCurve, 0, 0, bowHeight / 2);
    canvas.drawPath(path, bowPaint);

    // Calculate string pull
    double pullOffset = 0.0;
    if (gameState == GameState.aiming) {
      final pullVector = dragStart - dragCurrent;
      pullOffset =
          -math.min(pullVector.distance, 150.0) * 0.4; // visual pull distance
    }

    // Draw string
    final stringPath = Path();
    stringPath.moveTo(0, -bowHeight / 2);
    stringPath.lineTo(pullOffset, 0);
    stringPath.lineTo(0, bowHeight / 2);
    canvas.drawPath(stringPath, stringPaint);

    canvas.restore();
  }

  void _drawArrow(Canvas canvas) {
    const arrowLength = 60.0;

    canvas.save();

    // If aiming, the arrow gets pulled back
    Offset renderPos = arrowPosition;
    if (gameState == GameState.aiming) {
      final pullVector = dragStart - dragCurrent;
      final pullDistance = math.min(pullVector.distance, 150.0) * 0.4;
      renderPos = Offset(
        bowPosition.dx + math.cos(arrowAngle) * pullDistance,
        bowPosition.dy + math.sin(arrowAngle) * pullDistance,
      );
    }

    canvas.translate(renderPos.dx, renderPos.dy);
    canvas.rotate(arrowAngle);

    final shaftPaint = Paint()
      ..color = Colors.brown[300]!
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final tipPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    final fletchingPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Shaft
    canvas.drawLine(
      const Offset(-arrowLength / 2, 0),
      const Offset(arrowLength / 2, 0),
      shaftPaint,
    );

    // Tip
    final tipPath = Path();
    tipPath.moveTo(arrowLength / 2 + 10, 0);
    tipPath.lineTo(arrowLength / 2, -5);
    tipPath.lineTo(arrowLength / 2, 5);
    tipPath.close();
    canvas.drawPath(tipPath, tipPaint);

    // Fletching (feathers)
    canvas.drawLine(
      const Offset(-arrowLength / 2, 0),
      const Offset(-arrowLength / 2 - 10, -5),
      fletchingPaint,
    );
    canvas.drawLine(
      const Offset(-arrowLength / 2, 0),
      const Offset(-arrowLength / 2 - 10, 5),
      fletchingPaint,
    );

    canvas.restore();
  }

  void _drawTrajectory(Canvas canvas, Size size) {
    final pullVector = dragStart - dragCurrent;
    double pullDistance = math.min(pullVector.distance, 150.0);
    if (pullDistance < 10) return;

    final power = pullDistance * 7.5;
    double vx = math.cos(arrowAngle) * power;
    double vy = math.sin(arrowAngle) * power;

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double x = bowPosition.dx;
    double y = bowPosition.dy;
    const double dt = 0.05;
    const double g = 980.0;

    Path path = Path();
    path.moveTo(x, y);

    for (int i = 0; i < 20; i++) {
      vy += g * dt; // ignoring wind for aiming trajectory for simplicity
      x += vx * dt;
      y += vy * dt;

      if (y > size.height - groundY) break;

      path.lineTo(x, y);
    }

    // Draw dashed path
    canvas.drawPath(path, paint); // Simplify as solid or add dotted line logic
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
