//20241212

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';

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
      home: GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  final CatGame catGame = CatGame();

  GamePage({super.key});

  @override
  Widget build(BuildContext context) {
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