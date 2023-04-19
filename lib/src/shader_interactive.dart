import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'common.dart';

/// SnapshotWidget example
/// https://github.com/adil192/saber/blob/8b46c621d090df9d1c84e3aa6c19dfda6750b45d/lib/components/canvas/shader_sampler.dart

/// A shader transition from [foregroundChild] to [backgroundChild] with
/// user interaction (ie using pointer (iMouse uniform))
/// Used for examample for page_curl.frag shader
///
/// In the GLSL fragmet shader the following uniforms must be defined:
/// ```
/// layout(location = 0) uniform sampler2D iChannel0;
/// layout(location = 1) uniform sampler2D iChannel1;
/// layout(location = 2) uniform vec2 uResolution;
/// layout(location = 3) uniform vec4 iMouse;
/// ```
class ShaderInteractive extends StatefulWidget {
  const ShaderInteractive({
    super.key,
    required this.foregroundChild,
    required this.backgroundChild,
  });

  final Widget foregroundChild;
  final Widget backgroundChild;

  @override
  State<ShaderInteractive> createState() => _ShaderInteractiveState();
}

class _ShaderInteractiveState extends State<ShaderInteractive> {
  ui.Image? backgroundChildImg;
  late bool transitionCanStart;
  late IMouse iMouse;
  late PointerEventType pointerStatus;
  double widgetWidth = 0;
  bool pageCurled = false;
  Offset startingPos = Offset.zero;
  int n = 0;

  @override
  void initState() {
    super.initState();
    pointerStatus = PointerEventType.none;
    iMouse = IMouse(.0, .0, .0, .0);
    transitionCanStart = false;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (backgroundChildImg != null && !transitionCanStart) {
        setState(() {
          widgetWidth = backgroundChildImg!.width /
              MediaQuery.of(context).devicePixelRatio;
          iMouse.x = widgetWidth;
          transitionCanStart = true;
        });
      } else {
        if (pointerStatus != PointerEventType.none) {
          setState(() {});
        }
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
              if (n > 1) {
                backgroundChildImg = image.clone();
              } else {
                Future.delayed(Duration.zero, () {
                  setState(() {
                    n++;
                  });
                });
              }
            },
            enabled: true,
            child: widget.backgroundChild,
          ),
          widget.foregroundChild,
        ],
      );
    }

    Widget child;
    if (pointerStatus == PointerEventType.none) {
      if (pageCurled) {
        child = widget.backgroundChild;
      } else {
        child = widget.foregroundChild;
      }
    } else {
      child = ShaderBuilder(
        (context, shader, child) {
          return AnimatedSampler(
            (ui.Image image, size, canvas) {
              shader.setImageSampler(0, image); // iChannel0
              shader.setImageSampler(1, backgroundChildImg!); // iChannel1

              shader.setFloat(0, size.width);
              shader.setFloat(1, size.height);
              shader.setFloat(2, iMouse.x); // iMouse.x
              shader.setFloat(3, iMouse.y); // iMouse.y
              shader.setFloat(4, iMouse.z); // iMouse.z
              shader.setFloat(5, iMouse.w); // iMouse.w

              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
            },
            enabled: true,
            child: child!,
          );
        },
        assetKey: 'packages/shader_fxs/assets/page_curl.frag',
        child: widget.foregroundChild,
      );
    }

    return GestureDetector(
      onPanStart: (event) {
        startingPos = event.localPosition;
        iMouse = getIMouseValue(
          startingPos,
          event.localPosition,
          PointerEventType.onPointerDown,
        );
        pointerStatus = PointerEventType.onPointerDown;
        pageCurled = false;
        setState(() {});
      },
      onPanUpdate: (event) {
        iMouse = getIMouseValue(
          startingPos,
          event.localPosition,
          PointerEventType.onPointerMove,
        );
        pointerStatus = PointerEventType.onPointerMove;
      },
      onPanEnd: (event) {
        iMouse = getIMouseValue(
          startingPos,
          Offset(iMouse.x, iMouse.y),
          PointerEventType.onPointerUp,
        );
        pointerStatus = PointerEventType.none;
        pageCurled = iMouse.x < widgetWidth * 0.2;
      },
      child: Stack(children: [
        if (pointerStatus != PointerEventType.none)
          AnimatedSampler(
            (ui.Image image, size, canvas) {
              backgroundChildImg = image.clone();
            },
            enabled: true,
            child: widget.backgroundChild,
          ),
        child,
      ]),
    );
  }

  /// /////////////////////////////////
  /// Mouse position
  /// Shows how to use the mouse input (only left button supported):
  ///
  ///      mouse.xy  = mouse position during last button down
  ///  abs(mouse.zw) = mouse position during last button click
  /// sign(mouze.z)  = button is down
  /// sign(mouze.w)  = button is clicked
  /// https://www.shadertoy.com/view/llySRh
  /// https://www.shadertoy.com/view/Mss3zH
  IMouse getIMouseValue(
    Offset startingPos,
    Offset pos,
    PointerEventType eventType,
  ) {
    return IMouse(
      pos.dx,
      pos.dy,
      eventType == PointerEventType.onPointerDown ||
              eventType == PointerEventType.onPointerMove
          ? startingPos.dx
          : -startingPos.dx,
      -startingPos.dy,
    );
  }
}
