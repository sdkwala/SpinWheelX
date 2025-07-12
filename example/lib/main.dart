import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:spin_wheel/spin_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tap_gradient_demo.dart';
import 'image_demo.dart';
// import 'package:lottie/lottie.dart'; // Uncomment if you use Lottie files

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spin Wheel Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DemoHomeTabs(),
    );
  }
}

class DemoHomeTabs extends StatelessWidget {
  const DemoHomeTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Spin Wheel Demos',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Basic'),
              Tab(text: 'Gradient'),
              Tab(text: 'Image'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const SpinWheelDemo(),
            const TapGradientDemo(),
            ImageDemo(),
          ],
        ),
      ),
    );
  }
}

class SpinWheelDemo extends StatefulWidget {
  const SpinWheelDemo({super.key});

  @override
  State<SpinWheelDemo> createState() => _SpinWheelDemoState();
}

class _SpinWheelDemoState extends State<SpinWheelDemo> {
  late final SpinWheelController _controller;

  // Labels and colors for 8 segments as per reference
  final List<String> _labels = [
    r'$30', // $30
    r'$10', // $10
    r'$250', // $250
    r'$20', // $20
    'LOSE',
    r'$5', // $5
    r'$500', // $500
    r'$80', // $80
  ];

  final List<Color> _colors = [
    Color(0xFFFFD600), // Yellow
    Color(0xFFFF9100), // Orange
    Color(0xFFFF1744), // Red
    Color(0xFFF06292), // Pink
    Color(0xFF757575), // Gray
    Color(0xFF00BFAE), // Teal
    Color(0xFF2979FF), // Blue
    Color(0xFF8E24AA), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _controller = SpinWheelController();
  }

  // The controller no longer needs to be disposed.

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VibrantBackgroundPainter(),
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
        appBar: AppBar(
          title: Text('Spin Wheel Demo',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.black.withOpacity(0.2),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // The wheel itself (first, so pointer is above)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: SpinWheel(
                      controller: _controller,
                      config: SpinWheelConfig(
                        width: 350,
                        height: 350,
                        divisions: _labels.length,
                        labels: _labels,
                        segmentColors: _colors,
                        pointerWidget: null,
                        centerHoleRadius: 0.22,
                        dividerColor: Colors.white,
                        dividerThickness: 4,
                        labelAlignment: SpinWheelLabelAlignment.curved,
                        labelOffsetFromCenter: 0.68,
                        labelTextStyle: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        initialSpinAngle: -math.pi / _labels.length,
                      ),
                      onSpinEnd: (selectedIndex) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF232526),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text('Congratulations!',
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            content: Text('You won: ${_labels[selectedIndex]}',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Pointer above the wheel (last in the list = on top)
                  Positioned(
                    top: -28,
                    child: _SvgStylePointer(small: true, withShadow: true),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _AnimatedSpinButton(onPressed: () {
                final randomIndex = math.Random().nextInt(_labels.length);
                _controller.spin(randomIndex);
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom clipper to create the teardrop-shaped pointer.
class _ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(0, size.height / 2, size.width / 2, size.height);
    path.quadraticBezierTo(size.width, size.height / 2, size.width / 2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _ReferencePointer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Circle at the top
          Positioned(
            top: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Triangle/teardrop below
          Positioned(
            top: 20,
            child: ClipPath(
              clipper: _ArrowClipper(),
              child: Container(
                width: 32,
                height: 36,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSpinButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedSpinButton({required this.onPressed});

  @override
  State<_AnimatedSpinButton> createState() => _AnimatedSpinButtonState();
}

class _AnimatedSpinButtonState extends State<_AnimatedSpinButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Spin!',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SvgStylePointer extends StatelessWidget {
  final bool small;
  final bool withShadow;
  const _SvgStylePointer({this.small = false, this.withShadow = false});

  @override
  Widget build(BuildContext context) {
    final width = small ? 54.0 : 44.0;
    final height = small ? 68.0 : 56.0;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SvgPointerPainter(withShadow: withShadow),
      ),
    );
  }
}

class _SvgPointerPainter extends CustomPainter {
  final bool withShadow;
  _SvgPointerPainter({this.withShadow = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (withShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
      // Draw shadow for circle
      final circleRadius = size.width * 0.36;
      final circleCenter = Offset(size.width / 2, circleRadius + 2);
      canvas.drawCircle(circleCenter, circleRadius, shadowPaint);
      // Draw shadow for teardrop
      final path = Path();
      final topY = circleRadius * 2 - 2;
      path.moveTo(size.width / 2, topY);
      path.quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.65,
        size.width / 2,
        size.height - 2,
      );
      path.quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.65,
        size.width / 2,
        topY,
      );
      path.close();
      canvas.drawPath(path, shadowPaint);
    }
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    // Draw the circle at the top
    final circleRadius = size.width * 0.36;
    final circleCenter = Offset(size.width / 2, circleRadius);
    canvas.drawCircle(circleCenter, circleRadius, paint);
    // Draw the teardrop/triangle below
    final path = Path();
    final topY = circleRadius * 2 - 2;
    path.moveTo(size.width / 2, topY);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.65,
      size.width / 2,
      size.height - 2,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.65,
      size.width / 2,
      topY,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VibrantBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw radial gradient
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: const Alignment(0, -0.1),
      radius: 1.1,
      colors: [
        const Color(0xFFFFF176), // Light yellow
        const Color(0xFFFFD600), // Yellow
        const Color(0xFFFF9800), // Orange
      ],
      stops: [0.0, 0.6, 1.0],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw stars and sparkles
    final starPaint = Paint()..color = const Color(0xFFFFF9C4);
    final redStarPaint = Paint()..color = const Color(0xFFFF3D00);
    final random = math.Random(42);
    for (int i = 0; i < 32; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = random.nextDouble();
      if (r < 0.2) {
        _drawStar(canvas, Offset(x, y), 12, 5, starPaint);
      } else if (r < 0.3) {
        _drawStar(canvas, Offset(x, y), 10, 5, redStarPaint);
      } else {
        // Sparkle
        canvas.drawCircle(Offset(x, y), 1.5 + random.nextDouble() * 1.5,
            starPaint..color = starPaint.color.withOpacity(0.7));
      }
    }
  }

  void _drawStar(
      Canvas canvas, Offset center, double radius, int points, Paint paint) {
    final path = Path();
    final angle = math.pi / points;
    for (int i = 0; i < 2 * points; i++) {
      final r = (i % 2 == 0) ? radius : radius / 2.5;
      final x = center.dx + r * math.cos(i * angle);
      final y = center.dy + r * math.sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
