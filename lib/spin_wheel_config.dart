library spin_wheel;

/// Configuration model for SpinWheel

import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import 'spin_wheel_label_alignment.dart';

/// SpinWheelConfig: All configuration for the Spin Wheel widget.
///
/// Supports per-segment customization:
/// - segmentColors: List<Color?>
/// - segmentGradients: List<Gradient?>
/// - segmentImages: List<String?> (asset or network path)
/// - segmentGifs: List<String?> (asset or network path)
/// - segmentLotties: List<String?> (Lottie JSON asset or network path)
/// All lists must match [divisions] in length or be null.
class SpinWheelConfig {
  /// An optional asset path for a background image for the entire wheel.
  final String? imageAsset;

  /// The total number of segments on the wheel.
  final int divisions;

  /// The width of the spin wheel widget.
  final double width;

  /// The height of the spin wheel widget.
  final double height;

  /// The starting angle of the wheel in radians. Use `initialSpinAngleInDegrees` for degrees.
  final double initialSpinAngle;

  /// The starting angle of the wheel in degrees. This is an alternative to `initialSpinAngle`.
  final double? initialSpinAngleInDegrees;

  /// A friction-like value that determines how many times the wheel spins before stopping.
  /// Must be between 0.0 (low resistance, more spins) and 1.0 (high resistance, fewer spins).
  final double spinResistance;

  /// The color of the lines that separate the segments.
  final Color dividerColor;

  /// The thickness of the lines that separate the segments.
  final double dividerThickness;
  // Optionally add typography/textStyle for future text support
  /// The default text style for all labels on the wheel.
  final TextStyle? labelTextStyle;

  /// A list of specific text styles for each label, overriding the default `labelTextStyle`.
  /// The list length must match `divisions`.
  final List<TextStyle?>? labelTextStyles;

  /// A list of specific rotation angles in degrees for each label, overriding `labelAlignment`.
  /// The list length must match `divisions`.
  final List<double?>? labelRotationsInDegrees;

  /// Defines how labels are aligned on the wheel. Defaults to [SpinWheelLabelAlignment.segment].
  final SpinWheelLabelAlignment labelAlignment;

  /// The text labels to display for each segment.
  /// The list length must match `divisions`.
  final List<String>? labels;

  /// A list of weights to determine the relative size of each segment.
  /// If null, all segments are of equal size. The list length must match `divisions`.
  final List<double>? segmentWeights;

  /// The animation curve used for the spin animation.
  final Curve? animationCurve;

  // Per-segment customization
  /// A list of background colors for each segment.
  /// The list length must match `divisions`.
  final List<Color?>? segmentColors;

  /// A list of background gradients for each segment. Overrides `segmentColors` if provided.
  /// The list length must match `divisions`.
  final List<LinearGradient?>? segmentGradients;

  /// A list of image asset paths for each segment.
  /// The list length must match `divisions`.
  final List<String?>? segmentImages;

  /// A list of GIF asset paths for each segment.
  /// The list length must match `divisions`.
  final List<String?>? segmentGifs;

  /// A list of Lottie animation asset paths for each segment.
  /// The list length must match `divisions`.
  final List<String?>? segmentLotties;

  /// A custom widget to display in the center of the wheel (e.g., a spin button).
  final Widget? centerWidget;

  /// A custom widget to use as the pointer that indicates the winning segment.
  final Widget? pointerWidget;

  /// The alignment of the `pointerWidget` relative to the wheel.
  final Alignment pointerAlignment;

  /// The total duration of the spin animation.
  final Duration spinDuration;

  /// The radius of the hollow center circle, creating a 'donut' effect.
  /// This value is a factor of the wheel's radius (e.g., 0.4 means 40% of the radius).
  /// Must be between 0.0 (no hole) and 1.0 (no wheel).
  final double centerHoleRadius;

  /// A factor (0.0 to 1.0) that determines the radial position of the labels.
  /// 0.0 places labels on the inner edge of the ring, 0.5 in the middle, and 1.0 on the outer edge.
  final double labelOffsetFromCenter;

  /// If true, tapping the wheel will trigger a spin with haptic feedback.
  final bool tapToSpin;

  // Sound and Effects
  /// An optional asset path for a sound to play while the wheel is spinning.
  final String? spinningSound;

  /// An optional asset path for a sound to play when the spin is complete.
  final String? winningSound;

  /// An optional controller to trigger a confetti celebration on win.
  final ConfettiController? confettiController;

  SpinWheelConfig({
    this.imageAsset,
    required this.divisions,
    required this.width,
    required this.height,
    double initialSpinAngle = 0.0,
    this.initialSpinAngleInDegrees,
    this.spinResistance = 0.5,
    this.dividerColor = const Color(0xFFAAAAAA),
    this.dividerThickness = 2.0,
    this.labelTextStyle,
    this.labelTextStyles,
    this.labelRotationsInDegrees,
    this.labels,
    this.labelAlignment = SpinWheelLabelAlignment.segment,
    this.segmentWeights,
    this.animationCurve,
    this.segmentColors,
    this.segmentGradients,
    this.segmentImages,
    this.segmentGifs,
    this.segmentLotties,
    this.centerWidget,
    this.pointerWidget,
    this.pointerAlignment = const Alignment(1.1, 0), // Default to right
    this.spinDuration = const Duration(seconds: 4),
    this.spinningSound,
    this.winningSound,
    this.confettiController,
    this.centerHoleRadius = 0.0,
    this.labelOffsetFromCenter = 0.5,
    this.tapToSpin = false,
  })  : assert(divisions > 0, 'divisions must be greater than 0'),
        assert(width > 0, 'width must be greater than 0'),
        assert(height > 0, 'height must be greater than 0'),
        assert(spinResistance >= 0 && spinResistance <= 1,
            'spinResistance must be between 0 and 1'),
        assert(initialSpinAngleInDegrees == null || initialSpinAngle == 0.0,
            'Cannot provide both initialSpinAngle and initialSpinAngleInDegrees'),
        assert(dividerThickness >= 0,
            'dividerThickness must be greater than or equal to 0'),
        assert(labels == null || labels.length == divisions,
            'labels length must match divisions'),
        assert(labelTextStyles == null || labelTextStyles.length == divisions,
            'labelTextStyles length must match divisions'),
        assert(
            labelRotationsInDegrees == null ||
                labelRotationsInDegrees.length == divisions,
            'labelRotationsInDegrees length must match divisions'),
        assert(
            segmentWeights == null ||
                (segmentWeights.length == divisions &&
                    segmentWeights.every((w) => w > 0)),
            'segmentWeights length must match divisions and all weights must be > 0'),
        assert(segmentColors == null || segmentColors.length == divisions,
            'segmentColors length must match divisions'),
        assert(segmentGradients == null || segmentGradients.length == divisions,
            'segmentGradients length must match divisions'),
        assert(segmentImages == null || segmentImages.length == divisions,
            'segmentImages length must match divisions'),
        assert(segmentGifs == null || segmentGifs.length == divisions,
            'segmentGifs length must match divisions'),
        assert(segmentLotties == null || segmentLotties.length == divisions,
            'segmentLotties length must match divisions'),
        assert(centerHoleRadius >= 0 && centerHoleRadius < 1,
            'centerHoleRadius must be between 0.0 and 1.0'),
        assert(labelOffsetFromCenter >= 0 && labelOffsetFromCenter <= 1,
            'labelOffsetFromCenter must be between 0.0 and 1.0'),
        initialSpinAngle = (initialSpinAngleInDegrees != null)
            ? (initialSpinAngleInDegrees * math.pi / 180)
            : initialSpinAngle;
}
