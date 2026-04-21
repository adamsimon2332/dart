import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GuessGameApp());
}

class GuessGameApp extends StatelessWidget {
  const GuessGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Számkitaláló Játék',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}

// globális beállításokhoz egyszerű osztály
class GameSettings {
  static int maxNumber = 100;
  static int bestScore = 999999; 
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Számkitaláló\nJáték',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2)),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Új Játék'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Beállítások'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 40),
              if (GameSettings.bestScore != 999999)
                Text(
                  'Legjobb eredmény: ${GameSettings.bestScore} próbálkozás',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _currentSliderValue = GameSettings.maxNumber.toDouble();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beállítások'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nehézségi szint (Maximum szám):',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              '1 és ${_currentSliderValue.toInt()} között',
              style: const TextStyle(fontSize: 20, color: Colors.teal),
            ),
            Slider(
              value: _currentSliderValue,
              min: 10,
              max: 1000,
              divisions: 99,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                  GameSettings.maxNumber = value.toInt();
                });
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Mentés és Vissza'),
              ),
            )
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
  final TextEditingController _guessController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late int _targetNumber;
  int _attempts = 0;
  String _feedbackMessage = 'Írj be egy számot!';
  Color _feedbackColor = Colors.grey.shade700;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _targetNumber = Random().nextInt(GameSettings.maxNumber) + 1;
      _attempts = 0;
      _feedbackMessage = 'Gondoltam egy számra 1 és ${GameSettings.maxNumber} között.';
      _feedbackColor = Colors.black87;
      _isGameOver = false;
      _guessController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () => _focusNode.requestFocus());
  }

  void _checkGuess() {
    if (_isGameOver) return;

    final String inputText = _guessController.text;
    if (inputText.isEmpty) return;

    final int? guess = int.tryParse(inputText);
    if (guess == null) {
      setState(() {
        _feedbackMessage = 'Kérlek, csak érvényes számot adj meg!';
        _feedbackColor = Colors.red;
      });
      return;
    }

    setState(() {
      _attempts++;
      if (guess < _targetNumber) {
        _feedbackMessage = 'Túl KICSI!\nPróbálj nagyobbat.';
        _feedbackColor = Colors.orange.shade700;
      } else if (guess > _targetNumber) {
        _feedbackMessage = 'Túl NAGY!\nPróbálj kisebbet.';
        _feedbackColor = Colors.redAccent.shade700;
      } else {
        _feedbackMessage = 'GRATULÁLOK! Eltaláltad!\nA szám $_targetNumber volt.';
        _feedbackColor = Colors.green.shade700;
        _isGameOver = true;
        
        if (_attempts < GameSettings.bestScore) {
          GameSettings.bestScore = _attempts;
        }
      }
      _guessController.clear();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _guessController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Játék'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Próbálkozások száma: $_attempts',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _feedbackColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _feedbackColor, width: 2),
                        ),
                        child: Text(
                          _feedbackMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _feedbackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (!_isGameOver) ...[
                TextField(
                  controller: _guessController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Tipped...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                  ),
                  onSubmitted: (_) => _checkGuess(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _checkGuess,
                    child: const Text('Tippelek!', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _startNewGame,
                    child: const Text('Új Játék', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
