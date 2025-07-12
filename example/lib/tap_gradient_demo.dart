import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:spin_wheel/spin_wheel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class TapGradientDemo extends StatefulWidget {
  const TapGradientDemo({super.key});

  @override
  State<TapGradientDemo> createState() => _TapGradientDemoState();
}

class _TapGradientDemoState extends State<TapGradientDemo> {
  late final SpinWheelController _controller;

  final List<String> _labels = [
    '🍎',
    '🍊',
    '🍋',
    '🍏',
    '🍇',
    '🍉',
    '🍒',
    '🍍',
  ];

  final List<LinearGradient?> _gradients = [
    LinearGradient(colors: [Colors.red, Colors.pink]),
    LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
    LinearGradient(colors: [Colors.yellow, Colors.amber]),
    LinearGradient(colors: [Colors.green, Colors.lightGreen]),
    LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
    LinearGradient(colors: [Colors.teal, Colors.cyan]),
    LinearGradient(colors: [Colors.blue, Colors.indigo]),
    null, // Will use image for this segment
  ];

  final List<String?> _images = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    'assets/coupon.png', // Place a test image in example/assets/coupon.png
  ];

  @override
  void initState() {
    super.initState();
    _controller = SpinWheelController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tap-to-Spin & Gradient/Image Segments'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: 350,
              height: 350,
              child: SpinWheel(
                controller: _controller,
                config: SpinWheelConfig(
                  width: 350,
                  height: 350,
                  divisions: _labels.length,
                  labels: _labels,
                  segmentGradients: _gradients,
                  segmentImages: _images,
                  tapToSpin: true,
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
                  HapticFeedback.heavyImpact();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF232526),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: Text('Result',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      content: Text('You got: ${_labels[selectedIndex]}',
                          style: GoogleFonts.montserrat(color: Colors.white)),
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
            const SizedBox(height: 24),
            const Text('Tap the wheel to spin!'),
          ],
        ),
      ),
    );
  }
}
