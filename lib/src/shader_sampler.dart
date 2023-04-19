import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import 'common.dart';

class ShaderSampler extends StatefulWidget {
  const ShaderSampler({super.key, required this.child});

  final Widget child;

  @override
  State<ShaderSampler> createState() => _ShaderSamplerState();
}

class _ShaderSamplerState extends State<ShaderSampler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late IMouse iMouse;
  late PointerEventType pointerStatus;
  Offset startingPos = Offset.zero;
  late Stopwatch sw;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    _controller.repeat();

    sw = Stopwatch();
    sw.start();
    pointerStatus = PointerEventType.none;
    iMouse = IMouse(.0, .0, .0, .0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
        (context, shader, child) {
          return AnimatedSampler(
            (ui.Image image, size, canvas) {
              shader.setImageSampler(0, image);

              shader.setFloat(0, size.width);
              shader.setFloat(1, size.height);
              shader.setFloat(2, sw.elapsedMilliseconds / 1000.0); // iTime
              shader.setFloat(3, iMouse.x); // iMouse.x
              shader.setFloat(4, iMouse.y); // iMouse.y
              shader.setFloat(5, iMouse.z); // iMouse.z
              shader.setFloat(6, iMouse.w); // iMouse.w

              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
          },
          enabled: true,
          child: child!,
        );
      },
      assetKey: 'packages/shader_fxs/assets/test.frag',
      child: GestureDetector(
        onPanStart: (event) {
          startingPos = event.localPosition;
          iMouse = getIMouseValue(
            startingPos,
            event.localPosition,
            PointerEventType.onPointerDown,
          );
          pointerStatus = PointerEventType.onPointerDown;
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
        },
        child: widget.child,
      ),
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
