import 'package:flutter/material.dart';
import '../helpers/snap_calculator.dart';
import 'snap_guide_overlay.dart';

/// Provider widget that manages snap guide lines state
class SnapGuideProvider extends StatefulWidget {
  const SnapGuideProvider({super.key, required this.child});

  final Widget child;

  @override
  State<SnapGuideProvider> createState() => _SnapGuideProviderState();
}

class _SnapGuideProviderState extends State<SnapGuideProvider> {
  List<SnapGuideLine> _snapGuideLines = <SnapGuideLine>[];

  void updateSnapGuideLines(List<SnapGuideLine> lines) {
    if (mounted) {
      setState(() {
        _snapGuideLines = lines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SnapGuideProviderScope(
      updateSnapGuideLines: updateSnapGuideLines,
      snapGuideLines: _snapGuideLines,
      child: widget.child,
    );
  }
}

/// Scope that provides snap guide update function to children
class SnapGuideProviderScope extends InheritedWidget {
  const SnapGuideProviderScope({
    required this.updateSnapGuideLines,
    required this.snapGuideLines,
    required super.child,
  });

  final void Function(List<SnapGuideLine>) updateSnapGuideLines;
  final List<SnapGuideLine> snapGuideLines;

  static SnapGuideProviderScope? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SnapGuideProviderScope>();
  }

  static SnapGuideProviderScope of(BuildContext context) {
    final SnapGuideProviderScope? result = _maybeOf(context);
    assert(result != null, 'No SnapGuideProviderScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SnapGuideProviderScope oldWidget) {
    return oldWidget.snapGuideLines != snapGuideLines;
  }
}

/// Widget that displays snap guide lines
class SnapGuideLayer extends StatelessWidget {
  const SnapGuideLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final SnapGuideProviderScope? scope =
        SnapGuideProviderScope._maybeOf(context);
    if (scope == null) {
      return const SizedBox.shrink();
    }

    return SnapGuideOverlay(
      guideLines: scope.snapGuideLines,
    );
  }
}

/// Extension to access snap guide update function from context
extension SnapGuideContext on BuildContext {
  void updateSnapGuideLines(List<SnapGuideLine> lines) {
    SnapGuideProviderScope.of(this).updateSnapGuideLines(lines);
  }
}
