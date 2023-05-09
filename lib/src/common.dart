import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Define the objects to feed [ShaderFXs.iChannels]
///
/// [assetsImage] the assets image to use as Sampler2D.
/// TODO: add other URI images
/// [child] the widget to grab as texture
/// [isDynamic] set it to true if the assets image is ie an animated GIF
/// TODO: remove this
/// [texture] used internally
class ChannelTexture {
  String? assetsImage;
  Widget? child;

  ui.Image? texture;
  bool? isDynamic;

  ChannelTexture({
    this.assetsImage = 'packages/shader_fxs/assets/blank-16x16.bmp',
    this.child,
    this.isDynamic = false,
  });

  @override
  String toString() {
    return 'isDynamic: $isDynamic    child: $child   assetsImage: $assetsImage';
  }

  ChannelTexture copyWith({
    bool? isDynamic,
  }) {
    return ChannelTexture(
      isDynamic: isDynamic ?? this.isDynamic,
    );
  }
}

/// /////////////////////////////////
/// Mouse position
/// Shows how to use the mouse input (only left button supported):
///
///      mouse.xy  = mouse position during last button down
/// abs(mouse.zw)  = mouse position during last button click
/// sign(mouse.z)  = button is down
/// sign(mouse.w)  = button is clicked
/// https://www.shadertoy.com/view/llySRh
/// https://www.shadertoy.com/view/Mss3zH
class IMouse {
  double x = 0;
  double y = 0;
  double z = 0;
  double w = 0;

  IMouse(this.x, this.y, this.z, this.w);

  static IMouse zero = IMouse(0.0, 0.0, 0.0, 0.0);

  @override
  String toString() {
    return 'x: $x  y: $y  z: $z  w: $w';
  }
}

/// the current pointer state
///
enum PointerState {
  onPointerDown,
  onPointerMove,
  onPointerUp,
  none,
}

/// the current shader state
///
enum ShaderState {
  stopped,
  running,
  timeout,
}

/// Controller to start, stop, reset and swap channels
/// Used also to get the current shader and pointer state or pointer gestures
///
class ShaderController with AnimationLocalListenersMixin {
  /// start the shader.	Returns false if already running
  bool Function()? start;

  /// stop the shader at current execution time. Returns false if already stopped
  bool Function()? stop;

  /// reset iTime and iMouse
  VoidCallback? reset;

  /// swap 1st and 2nd iChannel
  VoidCallback? swapChildren;

  ShaderState _shaderState = ShaderState.stopped;

  ShaderState get shaderState => _shaderState;

  set shaderState(ShaderState value) {
    if (value == _shaderState) return;
    _shaderState = value;
    notifyListeners();
  }

  PointerState _pointerState = PointerState.none;

  PointerState get pointerState => _pointerState;

  set pointerState(PointerState value) {
    _pointerState = value;
    notifyListeners();
  }

  IMouse _pointerDetails = IMouse(0.0, 0.0, 0.0, 0.0);

  IMouse get pointerDetails => _pointerDetails;

  set pointerDetails(IMouse value) {
    _pointerDetails = value;
    notifyListeners();
  }

  void dispose() {
    super.clearListeners();
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
