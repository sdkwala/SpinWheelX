import 'package:flutter/widgets.dart';

/// A function signature for a custom widget that renders a segment's content.
///
/// - [context]: The build context.
/// - [index]: The index of the segment being rendered.
/// - [data]: The data associated with the segment (e.g., an image path, Lottie JSON).
typedef SegmentRenderer = Widget Function(BuildContext context, int index, dynamic data);

/// A central registry for discovering and using spin wheel plugins.
///
/// Plugins can register custom renderers for different segment content types (e.g., 'lottie', 'gif').
/// The [SpinWheelRenderer] uses this registry to find the appropriate renderer for a given segment.
class SpinWheelPluginRegistry {
  static final Map<String, SegmentRenderer> _renderers = {};

    /// Registers a [SegmentRenderer] for a specific content [type].
  ///
  /// This is typically called by a plugin's initialization logic.
  static void registerRenderer(String type, SegmentRenderer renderer) {
    _renderers[type] = renderer;
  }

    /// Retrieves a registered [SegmentRenderer] for a given content [type].
  ///
  /// Returns `null` if no renderer is found for the specified type.
  static SegmentRenderer? getRenderer(String type) => _renderers[type];
}
