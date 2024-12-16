/* 20241213_add to show the rank
/20241215 add exit button*/
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';
import 'storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat Interaction Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  List<Player> highScores = [];

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final scores = await ScoreManager.getHighScores();
    setState(() {
      highScores = scores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Game Login'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Login form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePage(playerName: _nameController.text), // Remove context parameter
                        ),
                      );
                    }
                  },
                  child: const Text('Start Game'),
                ),
                const SizedBox(height: 40),
                const Text(
                  'High Scores',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: highScores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text('${index + 1}'),
                        title: Text(highScores[index].name),
                        trailing: Text(highScores[index].score.toString()),
                      );
                    },
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

class GamePage extends StatelessWidget {
  final String playerName;

  const GamePage({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    // Create catGame inside build method to have access to context
    final catGame = CatGame(playerName: playerName, context: context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Interaction Game'),
      ),
      body: GameWidget<CatGame>(
        game: catGame,
        overlayBuilderMap: {
          'PauseMenu': (context, game) => PauseMenu(game: game),
        },
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (catGame.overlays.isActive('PauseMenu')) {
            catGame.overlays.remove('PauseMenu');
            catGame.resumeEngine();
          } else {
            catGame.overlays.add('PauseMenu');
            catGame.pauseEngine();
          }
        },
        child: Icon(
          catGame.overlays.isActive('PauseMenu') ? Icons.play_arrow : Icons.pause,
        ),
      ),
    );
  }
}

class PauseMenu extends StatelessWidget {
  final CatGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove('PauseMenu');
                game.resumeEngine();
              },
              child: const Text('Resume'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                game.reset();
                game.overlays.remove('PauseMenu');
                game.resumeEngine();
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
