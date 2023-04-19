import 'package:flutter/animation.dart';

class IMouse {
  double x = 0;
  double y = 0;
  double z = 0;
  double w = 0;

  IMouse(this.x, this.y, this.z, this.w);

  @override
  String toString() {
    return 'x: $x  y: $y  z: $z  w: $w';
  }
}

enum PointerEventType {
  onPointerDown,
  onPointerMove,
  onPointerUp,
  none,
}

enum ShaderState {
  stopped,
  running,
}

/// Controller to start, stop and get shader progression and state
class ShaderController with AnimationLocalListenersMixin {
  VoidCallback? start;
  VoidCallback? stop;
  Duration Function()? progress;

  ShaderState? _state;
  ShaderState? get state => _state;
  set state(ShaderState? value) {
    if (value == _state) return;
    _state = value;
    notifyListeners();
  }

  bool isInitialized() {
    return start != null && stop != null && progress != null;
  }

  void dispose() {
    start = null;
    stop = null;
    progress = null;
  }

  void updateState(ShaderState newState) {
    state = newState;
  }

  @override
  void didRegisterListener() {
    // TODO: implement didRegisterListener
  }

  @override
  void didUnregisterListener() {
    // TODO: implement didUnregisterListener
  }
}