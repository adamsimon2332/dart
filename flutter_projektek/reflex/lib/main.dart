import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReflexGameApp());
}

class ReflexGameApp extends StatelessWidget {
  const ReflexGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reflex Játék',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', score);
  }

  void _startGame(BuildContext context) async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
    if (result != null && result > _highScore) {
      setState(() {
        _highScore = result;
      });
      await _saveHighScore(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Reflex Játék',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Legjobb Pontszám: $_highScore',
              style: const TextStyle(fontSize: 24, color: Colors.lightGreen),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 24),
              ),
              onPressed: () => _startGame(context),
              child: const Text('Indítás'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gameDurationSeconds = 30; // 30 mp játékidő

  int _score = 0;
  int _timeLeft = gameDurationSeconds;
  int _targetIndex = -1;
  int _bombIndex = -1;
  int _bonusIndex = -1;
  int _timeIndex = -1;
  Timer? _gameTimer;
  Timer? _targetTimer;
  final Random _random = Random();
  final int _gridSize = 16;
  int _currentDelay = 1500; // Kezdetben 1.5 másodpercenként változik

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _timeLeft = gameDurationSeconds;
    _currentDelay = 1500;
    _setNewTarget();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          if (_timeLeft % 5 == 0 && _currentDelay > 500) {
            _currentDelay -= 200; // Idővel gyorsul
          }
        } else {
          _endGame();
        }
      });
    });
  }

  void _startTargetTimer() {
    _targetTimer?.cancel();
    _targetTimer = Timer(Duration(milliseconds: _currentDelay), () {
      if (_timeLeft > 0) {
        _setNewTarget();
      }
    });
  }

  void _setNewTarget() {
    _startTargetTimer();
    setState(() {
      int nextTarget;
      int nextBomb = -1;
      int nextBonus = -1;
      int nextTime = -1;

      do {
        nextTarget = _random.nextInt(_gridSize);
      } while (nextTarget == _targetIndex);

      if (_random.nextDouble() > 0.5) {
        do {
          nextBomb = _random.nextInt(_gridSize);
        } while (nextBomb == nextTarget);
        _bombIndex = nextBomb;
      } else {
        _bombIndex = -1;
      }

      if (_random.nextDouble() > 0.8) {
        do {
          nextBonus = _random.nextInt(_gridSize);
        } while (nextBonus == nextTarget || nextBonus == _bombIndex);
        _bonusIndex = nextBonus;
      } else {
        _bonusIndex = -1;
      }

      if (_random.nextDouble() > 0.85) {
        do {
          nextTime = _random.nextInt(_gridSize);
        } while (nextTime == nextTarget ||
            nextTime == _bombIndex ||
            nextTime == _bonusIndex);
        _timeIndex = nextTime;
      } else {
        _timeIndex = -1;
      }

      _targetIndex = nextTarget;
    });
  }

  void _onButtonTap(int index) {
    if (_timeLeft <= 0) return;

    if (index == _targetIndex) {
      setState(() {
        _score += 10;
        _setNewTarget();
      });
    } else if (index == _bombIndex) {
      setState(() {
        _score -= 15;
        if (_score < 0) _score = 0;
        _setNewTarget();
      });
    } else if (index == _bonusIndex) {
      setState(() {
        _score += 30;
        _bonusIndex =
            -1; // Ne lehessen többször rákattintani a következő váltásig
      });
    } else if (index == _timeIndex) {
      setState(() {
        _timeLeft += 3; // +3 extra másodperc
        _timeIndex = -1;
      });
    } else {
      setState(() {
        if (_score > 0) {
          _score -= 5;
        }
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Játék vége!'),
          content: Text('A végső pontszámod: $_score\nNagyon szép munka!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // dialog bezárás
                Navigator.of(context).pop(_score); // vissza a menübe
              },
              child: const Text('Vissza a menübe'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflex Mód'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Idő: $_timeLeft s',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'Pont: $_score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Piros: Cél (+10) | Sárga: Bomba (-15)\nZöld: Bónusz (+30) | Kék: Idő (+3 mp)',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final gridSize =
                      min(constraints.maxWidth, constraints.maxHeight) -
                      20; // Kis padding
                  return SizedBox(
                    width: gridSize,
                    height: gridSize,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _gridSize,
                      itemBuilder: (context, index) {
                        final isTarget = index == _targetIndex;
                        final isBomb = index == _bombIndex;
                        final isBonus = index == _bonusIndex;
                        final isTime = index == _timeIndex;
                        return GestureDetector(
                          onTap: () => _onButtonTap(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isTarget
                                  ? Colors.redAccent
                                  : isBomb
                                  ? Colors.yellowAccent
                                  : isBonus
                                  ? Colors.greenAccent
                                  : isTime
                                  ? Colors.blueAccent
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: _getBoxShadow(
                                isTarget,
                                isBomb,
                                isBonus,
                                isTime,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BoxShadow> _getBoxShadow(
    bool isTarget,
    bool isBomb,
    bool isBonus,
    bool isTime,
  ) {
    if (isTarget) {
      return [
        BoxShadow(
          color: Colors.redAccent.withOpacity(0.6),
          blurRadius: 15,
          spreadRadius: 5,
        ),
      ];
    } else if (isBomb) {
      return [
        BoxShadow(
          color: Colors.yellowAccent.withOpacity(0.4),
          blurRadius: 10,
          spreadRadius: 3,
        ),
      ];
    } else if (isBonus) {
      return [
        BoxShadow(
          color: Colors.greenAccent.withOpacity(0.5),
          blurRadius: 12,
          spreadRadius: 4,
        ),
      ];
    } else if (isTime) {
      return [
        BoxShadow(
          color: Colors.blueAccent.withOpacity(0.5),
          blurRadius: 12,
          spreadRadius: 4,
        ),
      ];
    }
    return [];
  }
}
