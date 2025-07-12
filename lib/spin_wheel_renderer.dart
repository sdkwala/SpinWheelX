import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'spin_wheel_config.dart';
import 'spin_wheel_controller.dart';
import 'spin_wheel_label_alignment.dart';

class SpinWheelRenderer extends StatefulWidget {
  final SpinWheelConfig config;
  final SpinWheelController controller;
  final void Function(int selectedIndex)? onSpinEnd;

  const SpinWheelRenderer({
    super.key,
    required this.config,
    required this.controller,
    this.onSpinEnd,
  });

  @override
  State<SpinWheelRenderer> createState() => _SpinWheelRendererState();
}

class _SpinWheelRendererState extends State<SpinWheelRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentAngle = 0.0;
  bool _isSpinning = false;
  int? _winningIndex;

  late AudioPlayer _spinningAudioPlayer;
  late AudioPlayer _winningAudioPlayer;

  @override
  @override
  void initState() {
    super.initState();
    _currentAngle = widget.config.initialSpinAngle;

    _spinningAudioPlayer = AudioPlayer();
    _winningAudioPlayer = AudioPlayer();

    if (widget.config.spinningSound != null) {
      _spinningAudioPlayer.setSource(AssetSource(widget.config.spinningSound!));
      _spinningAudioPlayer.setReleaseMode(ReleaseMode.loop);
    }

    if (widget.config.winningSound != null) {
      _winningAudioPlayer.setSource(AssetSource(widget.config.winningSound!));
    }
    _animationController = AnimationController(
      vsync: this,
      duration: widget.config.spinDuration,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(_animationController)
      ..addListener(() {
        setState(() {
          _currentAngle = _animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _spinningAudioPlayer.stop();
          _winningAudioPlayer.resume();
          widget.config.confettiController?.play();
          _isSpinning = false;
          if (widget.onSpinEnd != null && _winningIndex != null) {
            widget.onSpinEnd!(_winningIndex!);
          }
        }
      });
    widget.controller.registerSpinCallback(_startSpin);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _spinningAudioPlayer.dispose();
    _winningAudioPlayer.dispose();
    super.dispose();
  }

  void _startSpin(int targetIndex) {
    assert(targetIndex >= 0 && targetIndex < widget.config.divisions,
        'targetIndex must be a valid segment index.');
    if (_isSpinning) return;
    if (widget.config.divisions <= 0) return;
    setState(() {
      _isSpinning = true;
    });

    _winningIndex = targetIndex;

    final double spins = 4 + (2 * widget.config.spinResistance);
    final double fullSpinsInRadians = 2 * math.pi * spins;
    final double segmentAngle = 2 * math.pi / widget.config.divisions;
    final double winningSegmentCenter =
        (segmentAngle * _winningIndex!) + (segmentAngle / 2);
    final double targetRotation = -math.pi / 2 - winningSegmentCenter;
    final double currentRotationOffset = _currentAngle % (2 * math.pi);
    final double end =
        fullSpinsInRadians + targetRotation - currentRotationOffset;

    _animation = Tween<double>(begin: _currentAngle, end: _currentAngle + end)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.config.animationCurve ?? Curves.decelerate,
    ));
    _animationController.reset();
    _spinningAudioPlayer.resume();
    _animationController.forward();
  }

  double _getSegmentAngle(int index) {
    return (2 * math.pi * index) / widget.config.divisions;
  }

  double _getLabelAngle(int index) {
    return _getSegmentAngle(index) + (math.pi / widget.config.divisions);
  }

  Offset _getLabelOffset() {
    final outerRadius = widget.config.width / 2;
    final innerRadius = outerRadius * widget.config.centerHoleRadius;
    // Position the label in the middle of the ring by default
    final distance = innerRadius +
        (outerRadius - innerRadius) * widget.config.labelOffsetFromCenter;
    return Offset(distance, 0);
  }

  double _getLabelRotation(int index) {
    // Priority 1: Use specific degree rotation if provided
    if (widget.config.labelRotationsInDegrees != null &&
        index < widget.config.labelRotationsInDegrees!.length &&
        widget.config.labelRotationsInDegrees![index] != null) {
      return widget.config.labelRotationsInDegrees![index]! * (math.pi / 180);
    }

    // Priority 2: Use label alignment
    switch (widget.config.labelAlignment) {
      case SpinWheelLabelAlignment.segment:
        return 0; // No additional rotation needed
      case SpinWheelLabelAlignment.horizontal:
        return -_getLabelAngle(index); // Counter-rotate to keep horizontal
      case SpinWheelLabelAlignment.tangential:
        // Rotate with the segment, then add 90 degrees to be perpendicular to the radius
        final labelAngle = _getLabelAngle(index);
        return labelAngle > math.pi / 2 && labelAngle < 3 * math.pi / 2
            ? labelAngle - math.pi / 2
            : labelAngle + math.pi / 2;
      case SpinWheelLabelAlignment.curved:
      case SpinWheelLabelAlignment.radial:
      default:
        // For curved, rotation is handled by the painter. For radial, it's 0.
        return 0.0;
    }
  }

  TextStyle _getLabelStyle(int index) {
    final styles = widget.config.labelTextStyles;
    if (styles != null && index < styles.length && styles[index] != null) {
      return styles[index]!;
    }
    return widget.config.labelTextStyle ?? const TextStyle();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(widget.config.width, widget.config.height);
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: _currentAngle,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Segments, optional background image, and dividers
                SizedBox.fromSize(
                  size: size,
                  child: CustomPaint(
                    painter: _WheelPainter(config: widget.config),
                  ),
                ),

                // Labels
                if (widget.config.labels != null &&
                    widget.config.labels!.isNotEmpty) ...[
                  for (int i = 0; i < widget.config.divisions; i++) ...[
                    if (i < widget.config.labels!.length &&
                        widget.config.labels![i].isNotEmpty) ...[
                      if (widget.config.labelAlignment ==
                          SpinWheelLabelAlignment.curved) ...[
                        SizedBox.fromSize(
                          size: size,
                          child: CustomPaint(
                            painter: _CurvedTextPainter(
                              text: widget.config.labels![i],
                              textStyle: _getLabelStyle(i),
                              radius: size.width / 2 * 0.7,
                              angle: _getLabelAngle(i),
                            ),
                          ),
                        ),
                      ] else ...[
                        Transform.rotate(
                          angle: _getLabelAngle(i),
                          child: Transform.translate(
                            offset: _getLabelOffset(),
                            child: Transform.rotate(
                              angle: _getLabelRotation(i),
                              child: Text(
                                widget.config.labels![i],
                                style: _getLabelStyle(i),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ],
              ],
            ),
          ),
          // Center CTA Widget
          if (widget.config.centerWidget != null) ...[
            widget.config.centerWidget!,
          ],
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final SpinWheelConfig config;
  _WheelPainter({required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * config.centerHoleRadius;
    final rect = Rect.fromCircle(center: center, radius: outerRadius);
    final segmentAngle = 2 * math.pi / config.divisions;

    for (int i = 0; i < config.divisions; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = config.segmentColors![i % config.segmentColors!.length] ??
            Colors.grey;

      if (config.segmentGradients != null &&
          i < config.segmentGradients!.length) {
        paint.shader = config.segmentGradients![i]!.createShader(rect);
      }

      // Create a path for the donut segment
      final path = Path();
      if (config.centerHoleRadius > 0) {
        path.moveTo(center.dx + innerRadius * math.cos(startAngle),
            center.dy + innerRadius * math.sin(startAngle));
        path.arcTo(rect, startAngle, segmentAngle, false);
        path.arcTo(Rect.fromCircle(center: center, radius: innerRadius),
            startAngle + segmentAngle, -segmentAngle, false);
        path.close();
      } else {
        path.moveTo(center.dx, center.dy);
        path.arcTo(rect, startAngle, segmentAngle, false);
        path.close();
      }
      canvas.drawPath(path, paint);
    }

    // Draw dividers
    if (config.dividerThickness > 0) {
      final dividerPaint = Paint()
        ..color = config.dividerColor
        ..strokeWidth = config.dividerThickness;
      for (int i = 0; i < config.divisions; i++) {
        final angle = i * segmentAngle - math.pi / 2;
        final from = Offset(center.dx + innerRadius * math.cos(angle),
            center.dy + innerRadius * math.sin(angle));
        final to = Offset(center.dx + outerRadius * math.cos(angle),
            center.dy + outerRadius * math.sin(angle));
        canvas.drawLine(from, to, dividerPaint);
      }
    }

    // Draw outer border
    final borderPaint = Paint()
      ..color = config.dividerColor // Use divider color for consistency
      ..strokeWidth = config.dividerThickness
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, outerRadius, borderPaint);

    // Draw inner border (around center hole)
    if (config.centerHoleRadius > 0) {
      final innerBorderPaint = Paint()
        ..color = config.dividerColor
        ..strokeWidth = config.dividerThickness
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, innerRadius, innerBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurvedTextPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double radius;
  final double angle;

  _CurvedTextPainter({
    required this.text,
    required this.textStyle,
    required this.radius,
    required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();

    final double textArc = textPainter.width / radius;
    double currentAngle = angle - textArc / 2;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charPainter = TextPainter(
          text: TextSpan(text: char, style: textStyle),
          textDirection: TextDirection.ltr);
      charPainter.layout();

      final double charArc = charPainter.width / radius;
      final x = radius * math.cos(currentAngle + charArc / 2);
      final y = radius * math.sin(currentAngle + charArc / 2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentAngle + charArc / 2 + math.pi / 2);

      charPainter.paint(
          canvas, Offset(-charPainter.width / 2, -charPainter.height / 2));

      canvas.restore();

      currentAngle += charArc;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CurvedTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.radius != radius ||
        oldDelegate.angle != angle;
  }
}
