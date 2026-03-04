import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MagicSpellScreen(),
    );
  }
}

class MagicSpellScreen extends StatefulWidget {
  const MagicSpellScreen({super.key});

  @override
  State<MagicSpellScreen> createState() => _MagicSpellScreenState();
}

class _MagicSpellScreenState extends State<MagicSpellScreen> {
  int _counter = 0;
  String _lastSpell = 'None';
  List<Color> _gradientColors = [Colors.blue.shade200, Colors.purple.shade200];
  Color _textColor = Colors.black;

  final TextEditingController _controller = TextEditingController();
  late final Map<String, VoidCallback> _spells;

  @override
  void initState() {
    super.initState();

    _spells = {
      'Avada Kedavra': () {
        _counter = 0;
        _gradientColors = [Colors.deepPurple, Colors.black];
        _textColor = Colors.white;
      },
      'Lumos': () {
        _gradientColors = [Colors.yellow.shade300, Colors.orange.shade200];
        _textColor = Colors.black;
      },
      'Nox': () {
        _gradientColors = [Colors.indigo.shade900, Colors.black];
        _textColor = Colors.white;
      },
      'Expelliarmus': () {
        _counter -= 10;
        _gradientColors = [Colors.red.shade200, Colors.orange.shade200];
        _textColor = Colors.black;
      },
      'Sonorus': () {
        _counter *= 2;
        _gradientColors = [Colors.green.shade200, Colors.teal.shade200];
        _textColor = Colors.black;
      },
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleInput() {
    final input = _controller.text.trim();
    final spell = _spells[input];

    if (spell != null) {
      setState(() {
        spell();
        _lastSpell = input;
      });
    } else {
      final number = int.tryParse(input);

      if (number != null) {
        setState(() {
          _counter += number;
          _lastSpell = 'Added $number';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unknown spell or invalid number'),
          ),
        );
      }
    }

    _controller.clear();
  }

  int? _previewValue() {
    final input = _controller.text.trim();
    final number = int.tryParse(input);
    if (number != null) {
      return _counter + number;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewValue();

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Wizard Engine',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _textColor.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Last spell: $_lastSpell',
                  style: TextStyle(
                    fontSize: 16,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _controller,
                  style: TextStyle(color: _textColor),
                  decoration: InputDecoration(
                    labelText: 'Enter spell or number',
                    labelStyle: TextStyle(color: _textColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _textColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _textColor, width: 2),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _handleInput(),
                ),
                const SizedBox(height: 10),
                if (preview != null)
                  Text(
                    'Preview result: $preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: _textColor,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleInput,
                  child: const Text('Cast Spell'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
