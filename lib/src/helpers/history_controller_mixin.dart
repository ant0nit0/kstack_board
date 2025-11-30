import 'package:flutter/foundation.dart';

/// Mixin to add history (undo/redo) capabilities to a ValueNotifier
mixin HistoryControllerMixin<T> on ValueNotifier<T> {
  final List<T> _undoStack = <T>[];
  final List<T> _redoStack = <T>[];

  /// Check if undo is possible
  bool get canUndo => _undoStack.isNotEmpty;

  /// Check if redo is possible
  bool get canRedo => _redoStack.isNotEmpty;

  /// Commit current state to history
  /// Should be called BEFORE making a change to [value]
  void commit() {
    _undoStack.add(value);
    _redoStack.clear();
  }

  /// Undo the last change
  void undo() {
    if (!canUndo) return;

    final T currentState = value;
    final T previousState = _undoStack.removeLast();

    _redoStack.add(currentState);
    value = previousState;
  }

  /// Redo the last undone change
  void redo() {
    if (!canRedo) return;

    final T currentState = value;
    final T nextState = _redoStack.removeLast();

    _undoStack.add(currentState);
    value = nextState;
  }

  /// Clear history
  void clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
