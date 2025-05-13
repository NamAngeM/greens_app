import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget qui affiche un arbre écologique visuel dont la croissance
/// représente la progression de l'utilisateur dans son parcours écologique
class EcoTreeWidget extends StatefulWidget {
  final double progress; // 0.0 à 1.0
  final int ecoPoints;
  final int level;
  final bool animate;

  const EcoTreeWidget({
    Key? key,
    required this.progress,
    required this.ecoPoints,
    required this.level,
    this.animate = true,
  }) : super(key: key);

  @override
  State<EcoTreeWidget> createState() => _EcoTreeWidgetState();
}

class _EcoTreeWidgetState extends State<EcoTreeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(EcoTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      );
      if (widget.animate) {
        _controller.forward(from: 0.0);
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(width, height),
              painter: _EcoTreePainter(
                progress: _animation.value,
                ecoPoints: widget.ecoPoints,
                level: widget.level,
              ),
            );
          },
        );
      },
    );
  }
}

class _EcoTreePainter extends CustomPainter {
  final double progress;
  final int ecoPoints;
  final int level;

  _EcoTreePainter({
    required this.progress,
    required this.ecoPoints,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height);

    // Calculer les paramètres basés sur le niveau
    final trunkHeight = height * 0.4 * (0.5 + progress * 0.5);
    final trunkWidth = width * 0.1 * (0.8 + level * 0.04);
    final canopySize = width * 0.8 * progress;
    final leafDensity = math.min(30 + level * 5, 100);
    final fruitsCount = math.min(level, 10);
    
    // Dessiner le sol
    final groundPaint = Paint()
      ..color = const Color(0xFF8D6E63).withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(width / 2, height),
        width: width * 0.8,
        height: height * 0.1,
      ),
      math.pi,
      math.pi,
      true,
      groundPaint,
    );
    
    // Dessiner le tronc
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;
    
    final trunkPath = Path()
      ..moveTo(center.dx - trunkWidth / 2, center.dy)
      ..lineTo(center.dx - trunkWidth / 3, center.dy - trunkHeight)
      ..lineTo(center.dx + trunkWidth / 3, center.dy - trunkHeight)
      ..lineTo(center.dx + trunkWidth / 2, center.dy)
      ..close();
    
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Dessiner les branches
    if (progress > 0.4) {
      final branchPaint = Paint()
        ..color = const Color(0xFF795548)
        ..style = PaintingStyle.stroke
        ..strokeWidth = trunkWidth / 4;
      
      // Branche gauche
      final leftBranchPath = Path()
        ..moveTo(center.dx - trunkWidth / 4, center.dy - trunkHeight * 0.7)
        ..quadraticBezierTo(
          center.dx - width * 0.25 * progress,
          center.dy - trunkHeight * 0.8,
          center.dx - width * 0.3 * progress,
          center.dy - trunkHeight * 0.75,
        );
      
      // Branche droite
      final rightBranchPath = Path()
        ..moveTo(center.dx + trunkWidth / 4, center.dy - trunkHeight * 0.6)
        ..quadraticBezierTo(
          center.dx + width * 0.2 * progress,
          center.dy - trunkHeight * 0.7,
          center.dx + width * 0.25 * progress,
          center.dy - trunkHeight * 0.65,
        );
      
      // Branche centrale
      final centerBranchPath = Path()
        ..moveTo(center.dx, center.dy - trunkHeight)
        ..lineTo(center.dx, center.dy - trunkHeight - canopySize * 0.3);
      
      canvas.drawPath(leftBranchPath, branchPaint);
      canvas.drawPath(rightBranchPath, branchPaint);
      canvas.drawPath(centerBranchPath, branchPaint);
    }
    
    // Dessiner le feuillage
    if (progress > 0.2) {
      // Feuillage principal
      final random = math.Random(ecoPoints);
      final leafColors = [
        const Color(0xFF4CAF50), // Vert
        const Color(0xFF66BB6A), // Vert clair
        const Color(0xFF43A047), // Vert foncé
        const Color(0xFF81C784), // Vert pâle
      ];
      
      for (int i = 0; i < leafDensity; i++) {
        final leafSize = width * (0.05 + random.nextDouble() * 0.07) * progress;
        final angle = random.nextDouble() * 2 * math.pi;
        final distance = canopySize * 0.5 * random.nextDouble();
        final x = center.dx + math.cos(angle) * distance;
        final y = center.dy - trunkHeight - canopySize * 0.3 + math.sin(angle) * distance;
        
        final leafPaint = Paint()
          ..color = leafColors[random.nextInt(leafColors.length)]
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), leafSize, leafPaint);
      }
      
      // Dessiner des fruits (pour les niveaux supérieurs)
      if (progress > 0.7 && level > 2) {
        final fruitColors = [
          const Color(0xFFF44336), // Rouge
          const Color(0xFFFF9800), // Orange
          const Color(0xFFFFEB3B), // Jaune
        ];
        
        for (int i = 0; i < fruitsCount; i++) {
          final fruitSize = width * 0.03 * progress;
          final angle = random.nextDouble() * 2 * math.pi;
          final distance = canopySize * 0.35 * random.nextDouble();
          final x = center.dx + math.cos(angle) * distance;
          final y = center.dy - trunkHeight - canopySize * 0.2 + math.sin(angle) * distance;
          
          final fruitPaint = Paint()
            ..color = fruitColors[random.nextInt(fruitColors.length)]
            ..style = PaintingStyle.fill;
          
          canvas.drawCircle(Offset(x, y), fruitSize, fruitPaint);
        }
      }
    }
    
    // Dessiner les éléments supplémentaires (fleurs, oiseaux, etc.) pour les niveaux élevés
    if (level > 5 && progress > 0.8) {
      final random = math.Random(ecoPoints + level);
      
      // Dessiner des fleurs
      final flowerColors = [
        const Color(0xFFE91E63), // Rose
        const Color(0xFFFF9800), // Orange
        const Color(0xFF9C27B0), // Violet
        const Color(0xFFFFEB3B), // Jaune
      ];
      
      for (int i = 0; i < level - 3; i++) {
        final flowerSize = width * 0.02;
        final angle = random.nextDouble() * 2 * math.pi;
        final distance = canopySize * 0.45 * random.nextDouble();
        final x = center.dx + math.cos(angle) * distance;
        final y = center.dy - trunkHeight - canopySize * 0.3 + math.sin(angle) * distance;
        
        final flowerPaint = Paint()
          ..color = flowerColors[random.nextInt(flowerColors.length)]
          ..style = PaintingStyle.fill;
        
        // Centre de la fleur
        canvas.drawCircle(Offset(x, y), flowerSize, flowerPaint);
        
        // Pétales
        for (int j = 0; j < 5; j++) {
          final petalAngle = j * (2 * math.pi / 5);
          final petalX = x + math.cos(petalAngle) * flowerSize * 1.5;
          final petalY = y + math.sin(petalAngle) * flowerSize * 1.5;
          
          canvas.drawCircle(Offset(petalX, petalY), flowerSize, flowerPaint);
        }
      }
      
      // Dessiner des oiseaux pour les niveaux très élevés
      if (level > 8) {
        final birdPaint = Paint()
          ..color = const Color(0xFF3F51B5)
          ..style = PaintingStyle.fill;
        
        for (int i = 0; i < math.min(level - 7, 3); i++) {
          final angle = random.nextDouble() * math.pi - math.pi / 2;
          final distance = canopySize * 0.6 * random.nextDouble();
          final x = center.dx + math.cos(angle) * distance;
          final y = center.dy - trunkHeight - canopySize * 0.3 + math.sin(angle) * distance;
          
          // Corps de l'oiseau
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(x, y),
              width: width * 0.04,
              height: width * 0.025,
            ),
            birdPaint,
          );
          
          // Ailes
          final wingPath = Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(
              x, y - width * 0.02,
              x + width * 0.03, y,
            );
          
          canvas.drawPath(wingPath, birdPaint);
        }
      }
    }
    
    // Niveau et points (en texte)
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    // Niveau
    textPainter.text = TextSpan(
      text: 'Niveau $level',
      style: const TextStyle(
        color: Color(0xFF4CAF50),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, height - height * 0.08),
    );
    
    // Points
    textPainter.text = TextSpan(
      text: '$ecoPoints points',
      style: const TextStyle(
        color: Color(0xFF4CAF50),
        fontSize: 12,
      ),
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, height - height * 0.04),
    );
  }

  @override
  bool shouldRepaint(_EcoTreePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ecoPoints != ecoPoints ||
        oldDelegate.level != level;
  }
}

/// Widget qui affiche une version réduite de l'arbre écologique pour le menu ou les aperçus
class EcoTreePreviewWidget extends StatelessWidget {
  final double progress;
  final int level;
  final double size;

  const EcoTreePreviewWidget({
    Key? key,
    required this.progress,
    required this.level,
    this.size = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EcoTreePreviewPainter(
          progress: progress,
          level: level,
        ),
      ),
    );
  }
}

class _EcoTreePreviewPainter extends CustomPainter {
  final double progress;
  final int level;

  _EcoTreePreviewPainter({
    required this.progress,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height);

    // Version simplifiée du tronc
    final trunkPaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.fill;
    
    final trunkWidth = width * 0.2;
    final trunkHeight = height * 0.6 * progress;
    
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - trunkWidth / 2,
        height - trunkHeight,
        trunkWidth,
        trunkHeight,
      ),
      trunkPaint,
    );
    
    // Feuillage simplifié
    final canopyPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF81C784),
        const Color(0xFF2E7D32),
        progress * level / 10,
      )!
      ..style = PaintingStyle.fill;
    
    final canopyRadius = width * 0.4 * progress;
    
    canvas.drawCircle(
      Offset(center.dx, height - trunkHeight - canopyRadius * 0.5),
      canopyRadius,
      canopyPaint,
    );
    
    // Niveau (petit)
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.text = TextSpan(
      text: '$level',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        height - trunkHeight - canopyRadius * 0.5 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_EcoTreePreviewPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.level != level;
  }
} 