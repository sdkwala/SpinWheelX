/// Defines how labels are aligned on the spin wheel.
enum SpinWheelLabelAlignment {
  /// The label is aligned with the segment and rotates with the wheel.
  segment,

  /// Labels are positioned radially, but the text itself remains upright.
  /// On the left half of the wheel, the text is flipped 180 degrees to remain readable.
  radial,

  /// Labels are drawn along a curve, following the arc of the segment.
  curved,

  /// Labels are drawn horizontally and do not rotate with the wheel.
  horizontal,

  /// The text is aligned tangentially to the wheel's curve, remaining upright.
  tangential,
}
