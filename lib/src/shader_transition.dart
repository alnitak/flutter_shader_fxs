import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'common.dart';

/// SnapshotWidget example
/// https://github.com/adil192/saber/blob/8b46c621d090df9d1c84e3aa6c19dfda6750b45d/lib/components/canvas/shader_sampler.dart

/// A shader transition from [foregroundChild] to [backgroundChild]
/// Used for examample for noise_fade.frag shader
///
/// In the GLSL fragmet shader the following uniforms must be defined:
/// ```
/// layout(location = 0) uniform sampler2D iChannel0;
/// layout(location = 1) uniform sampler2D iChannel1;
/// layout(location = 2) uniform vec2 uResolution;
/// layout(location = 3) uniform float iTime;
/// ```
class ShaderTransition extends StatefulWidget {
  ShaderTransition({
    super.key,
    controller,
    listener,
    required this.foregroundChild,
    required this.backgroundChild,
    this.duration = const Duration(milliseconds: 600),
  }) : controller = controller ?? ShaderController();

  final Widget foregroundChild;
  final Widget backgroundChild;
  final Duration duration;

  /// controls to start, stop and get progress
  final ShaderController? controller;

  @override
  State<ShaderTransition> createState() => _ShaderTransitionState();
}

class _ShaderTransitionState extends State<ShaderTransition> {
  ui.Image? backgroundChildImg;
  late bool transitionCanStart;
  late Stopwatch sw;
  late Widget foregroundChild;
  late Widget backgroundChild;
  Offset startingPos = Offset.zero;
  int n = 0;

  @override
  void initState() {
    super.initState();
    sw = Stopwatch();
    transitionCanStart = false;
    foregroundChild = widget.foregroundChild;
    backgroundChild = widget.backgroundChild;

    if (!widget.controller!.isInitialized()) {
      widget.controller!.start = start;
      widget.controller!.stop = stop;
      widget.controller!.progress = progress;
    }
  }

  @override
  void dispose() {
    widget.controller!.stop!();
    widget.controller!.state = ShaderState.stopped;
    widget.controller!.dispose();
    super.dispose();
  }

  start() {
    sw.reset();
    sw.start();
    setState(() {
      transitionCanStart = false;
      widget.controller!.state = ShaderState.running;
    });
  }

  stop() {
    sw.stop();
    setState(() {
      widget.controller!.state = ShaderState.stopped;
    });
  }

  Duration progress() {
    return Duration(milliseconds: sw.elapsedMilliseconds);
  }

  @override
  Widget build(BuildContext context) {
    if (!sw.isRunning) {
      return foregroundChild;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (backgroundChildImg != null && !transitionCanStart) {
        setState(() {
          transitionCanStart = true;
        });
      } else {
        setState(() {});
      }
    });

    if (!transitionCanStart) {
      return Stack(
        children: [
          AnimatedSampler(
            (ui.Image image, size, canvas) {
              /// grab the 3rd frame to be sure the Image()s of child2
              /// are initialized? (got some problems when getting it at first)
              /// (doesn't happens in master channel)
              if (n >= 0) {
                backgroundChildImg = image.clone();
              } else {
                n++;
              }
            },
            enabled: true,
            child: backgroundChild,
          ),
          foregroundChild,
        ],
      );
    }

    Widget child;
    if (sw.elapsedMilliseconds > widget.duration.inMilliseconds) {
      sw.stop();

      /// the transition is terminated. Swapping widgets
      Widget tmpChild = foregroundChild;
      foregroundChild = backgroundChild;
      backgroundChild = tmpChild;

      child = foregroundChild;
      widget.controller!.state = ShaderState.stopped;
    } else {
      child = ShaderBuilder(
        (context, shader, child) {
          return AnimatedSampler(
            (ui.Image image, size, canvas) {
              shader.setFloat(0, size.width); // uResolution.x
              shader.setFloat(1, size.height); // uResolution.y
              shader.setFloat(2, sw.elapsedMilliseconds / 1000.0); // iTime

              shader.setImageSampler(0, backgroundChildImg!); // iChannel0
              shader.setImageSampler(1, image); // iChannel1

              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
            },
            enabled: true,
            child: child!,
          );
        },
        assetKey: 'packages/shader_fxs/assets/noise_fade.frag',
        child: foregroundChild,
      );
    }

    return child;
  }
}
