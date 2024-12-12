//20241212_modified jump height
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

class CatGame extends FlameGame with TapDetector, KeyboardHandler {
  late CatSprite catSprite;
  late TextComponent scoreText;
  SpriteComponent? background;
  bool isGameWon = false;

  int score = 0;

  // Different score values for different actions
  static const int JUMP_SCORE = 10;
  static const int SPIN_SCORE = 20;
  static const int DANCE_SCORE = 30;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Load images
      final backgroundImage = await Flame.images.load('background.png');
      await Flame.images.load('cat.png');

      // Initialize and add background
      background = SpriteComponent()
        ..sprite = Sprite(backgroundImage)
        ..size = size;
      add(background!);

      // Add cat sprite
      catSprite = CatSprite()
        ..position = Vector2(size.x / 2, size.y - 150)
        ..size = Vector2(100, 100);
      add(catSprite);

      // Add score text
      scoreText = TextComponent(
        text: 'Score: $score',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(10, 10),
      );
      add(scoreText);
    } catch (e) {
      print('Error during loading: $e');
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    background?.size = canvasSize;
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (!paused && !isGameWon) {
      final touchPoint = info.eventPosition.widget;
      final vector2Point = Vector2(touchPoint.x, touchPoint.y);
      if (catSprite.containsPoint(vector2Point)) {
        // Random movement selection
        final random = DateTime.now().millisecondsSinceEpoch % 3;
        switch (random) {
          case 0:
            catSprite.jump();
            incrementScore(JUMP_SCORE);
            break;
          case 1:
            catSprite.spin();
            incrementScore(SPIN_SCORE);
            break;
          case 2:
            catSprite.dance();
            incrementScore(DANCE_SCORE);
            break;
        }
      }
    }
  }

  void incrementScore(int points) {
    score += points;
    scoreText.text = 'Score: $score';
    checkWinCondition();
  }

  void checkWinCondition() {
    if (score >= 1000 && !isGameWon) {
      isGameWon = true;
      showWinMessage();
    }
  }

  void showWinMessage() {
    final dialog = WinDialogComponent(
      size: Vector2(300, 200),
      position: size / 2,
      score: score,
    );
    add(dialog);
  }

  void reset() {
    score = 0;
    isGameWon = false;
    scoreText.text = 'Score: $score';
    catSprite.position = Vector2(size.x / 2, size.y - 150);
  }
}

class CatSprite extends SpriteComponent with HasGameRef<CatGame> {
  bool isAnimating = false;
  static const double jumpHeight = 500;
  static const double jumpDuration = 0.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = Sprite(Flame.images.fromCache('cat.png'));
    anchor = Anchor.center;
  }

  void jump() {
    if (!isAnimating) {
      isAnimating = true;
      add(
        MoveByEffect(
          Vector2(0, -jumpHeight),
          EffectController(
            duration: jumpDuration / 2,
            curve: Curves.easeOut,
            reverseDuration: jumpDuration / 2,
            alternate: true,
          ),
          onComplete: () => isAnimating = false,
        ),
      );
    }
  }

  void spin() {
    if (!isAnimating) {
      isAnimating = true;
      add(
        RotateEffect.by(
          2 * 3.14159, // Full rotation
          EffectController(
            duration: 1.0,
            curve: Curves.easeInOut,
          ),
        )..onComplete = () => isAnimating = false,
      );
    }
  }

  void dance() {
    if (!isAnimating) {
      isAnimating = true;
      add(
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
            alternate: true,
          ),
        )..onComplete = () => isAnimating = false,
      );
    }
  }
}

class WinDialogComponent extends PositionComponent {
  final int score;

  WinDialogComponent({
    required Vector2 position,
    required Vector2 size,
    required this.score,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
  );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Draw dialog background with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(20)),
      paint,
    );

    // Draw text
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );

    // Draw win message
    textPaint.render(
      canvas,
      'You Win!',
      Vector2(size.x / 2, size.y / 2 - 20),
      anchor: Anchor.center,
    );

    // Draw score
    textPaint.render(
      canvas,
      'Score: $score',
      Vector2(size.x / 2, size.y / 2 + 20),
      anchor: Anchor.center,
    );
  }
}