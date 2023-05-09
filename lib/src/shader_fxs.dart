import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../shader_fxs.dart';
import 'common.dart';

class ShaderFXs extends StatefulWidget {
  const ShaderFXs({
    super.key,
    required this.shaderAsset,
    this.autoStartWhenTapped = false,
    this.startRunning = true,
    this.duration,
    this.controller,
    this.iChannels,
  });

  /// Controller to start, stop, reset and swap channels
  /// Used also to get the current shader and pointer state or pointer gestures
  final ShaderController? controller;

  /// auto start shader.
  /// If set to false, it should be started with the controller
  final bool startRunning;

  /// asset file path of the fragment shader
  final String shaderAsset;

  /// start shader when touched
  final bool autoStartWhenTapped;

  /// duration within which to stop the shader
  final Duration? duration;

  /// list of [ChannelTexture] to use as textures
  final List<ChannelTexture>? iChannels;

  @override
  State<ShaderFXs> createState() => _ShaderFXsState();
}

class _ShaderFXsState extends State<ShaderFXs> with TickerProviderStateMixin {
  /// ticker used to animate the shader
  late Ticker? ticker;

  /// touch position used as iMouse shader uniform
  late IMouse iMouse;

  /// status of pointer
  late PointerState pointerStatus;

  /// starting touch coordinates. Used by iMouse.zw
  late Offset startingPos;

  /// the time since shader has been started. Used as iTime shader uniform
  late Stopwatch sw;

  /// used internally to know if all channel has been set
  late bool areChannelsSet;

  /// used internally to know if the 1st widget size has been acquired
  late bool isSizeAcquired;

  /// whether or not the shader is running
  late bool isStopped;

  /// list of [ChannelTexture]
  late List<ChannelTexture> iChannel;

  /// widget used to bulk together [AnimatedSampler] containing
  /// all [iChannel] widgets
  late ValueNotifier<Widget> child;

  /// flags used by iChannels initially to true to grab the widget. Then
  /// if the widget in [ChannelTexture] has [isDynamic] set to false, it
  /// is set to false also this to disable [AnimatedBuilder] to
  /// always grab the widget
  late List<ValueNotifier<bool>> isDynamicFlag;

  /// the size of the widget retrieved in LayoutBuilder
  late Size widgetSize;

  /// timer to stop the shader after [widget.duration] duration
  Timer? timer;



  @override
  void initState() {
    super.initState();

    widgetSize = Size.zero;
    areChannelsSet = false;
    isSizeAcquired = false;
    startingPos = Offset.zero;
    pointerStatus = PointerState.none;
    iMouse = IMouse.zero;

    isDynamicFlag = [];
    iChannel = [];
    setupChannels();

    ticker = createTicker(_tick);
    sw = Stopwatch();

    if (widget.controller != null) {
      widget.controller!.start = start;
      widget.controller!.stop = stop;
      widget.controller!.reset = reset;
      widget.controller!.swapChildren = swapChildren;
    }

    isStopped = true;
    if (widget.startRunning) {
      start();
    }
  }

  _tick(Duration elapsed) {
    setState(() {});
  }

  @override
  void dispose() {
    ticker?.dispose();
    super.dispose();
  }

  bool start() {
    if (!isStopped) return false;
    iMouse = IMouse.zero;
    sw.reset();
    sw.start();
    isStopped = false;

    if (!ticker!.isTicking) {
      ticker!.start();
    }

    if (widget.controller != null) {
      widget.controller!.pointerDetails = iMouse;
      widget.controller!.pointerState = PointerState.none;
      widget.controller!.shaderState = ShaderState.running;

      if (widget.duration != null) {
        timer = Timer(widget.duration!, () {
          widget.controller!.shaderState = ShaderState.timeout;
        });
      }
    }

    return true;
  }

  bool stop() {
    if (isStopped) return false;
    isStopped = true;
    sw.stop();

    if (widget.controller != null) {
      // widget.controller!.pointerState = PointerState.none;
      widget.controller!.shaderState = ShaderState.stopped;
    }

    if (ticker!.isTicking) {
      ticker!.stop();
    }
    setState(() {});
    return true;
  }

  reset() {
    sw.reset();
    iMouse = IMouse.zero;
  }

  /// swap 1st and 2nd channels
  swapChildren() {
    ChannelTexture tmpChannel = iChannel[0];
    iChannel[0] = iChannel[1];
    iChannel[1] = tmpChannel;
    loadWidget();
  }

  Future<void> setupChannels() async {
    if (widget.iChannels == null) return;

    for (int i = 0; i < widget.iChannels!.length; ++i) {
      isDynamicFlag.add(ValueNotifier(true));
      iChannel.add(await getImageShader(widget.iChannels![i]));
    }
    loadWidget();

    areChannelsSet = true;
  }

  Future<ChannelTexture> getImageShader(ChannelTexture channel) async {
    /// if [channel] has a child, leave that untouched
    if (channel.child != null) {
      await loadImage(channel); // meanwhile load the blank default image
      return channel;
    }

    /// load the image as texture
    if (channel.assetsImage != null && !(channel.isDynamic ?? false)) {
      return loadImage(channel);
    }

    /// load the dynamic image (GIF ?) as a widget Image
    if (channel.assetsImage != null && (channel.isDynamic ?? false)) {
      channel.child = Image.asset(channel.assetsImage!);
      channel.assetsImage = null;
      return channel;
    }
    return channel;
  }

  Future<ChannelTexture> loadImage(ChannelTexture channel) async {
    final Completer<ChannelTexture> completer = Completer();
    final imageData = await rootBundle.load(channel.assetsImage!);
    ui.decodeImageFromList(imageData.buffer.asUint8List(), (ui.Image img) {
      channel.texture = img.clone();
      return completer.complete(channel);
    });
    return completer.future;
  }

  /// for all iChannel create a Stack containing all of them with
  /// an AnimatedSampler parent
  loadWidget() {
    child = ValueNotifier<Widget>(
      Stack(
        children: [

          // if there are no iChannel.child(s) widgets but only texture images,
          // this Stack must have a size to grab Gestures
          Container(
            color: Colors.transparent,
            width: widgetSize.width,
            height: widgetSize.height,
          ),

          // the first channel must be on top
          for (int i = iChannel.length - 1; i >= 0; --i)
            if (iChannel[i].child != null)
                ValueListenableBuilder(
                  valueListenable: isDynamicFlag[i],
                  builder: (context, isDynamic, __) {
                    return AnimatedSampler(
                      key: UniqueKey(),
                      (ui.Image image, size, canvas) {
                        iChannel[i].texture = image.clone();
                        if (!iChannel[i].isDynamic!) {
                          // TODO: find a better way to be sure images
                          //       are grabbed when isDynamic is false
                          //
                          // grab other samplers after N ms in
                          // case the 1st isn't taken yet
                          // (happens when the widget has images which are
                          // decoded asynchronously)
                          Future.delayed(const Duration(milliseconds: 160), () {
                            isDynamicFlag[i].value = false;
                          });
                        }
                      },
                      enabled: isDynamic,
                      child: iChannel[i].child!,
                    );
                  }
                )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isSizeAcquired) {
      return LayoutBuilder(
        builder: (context, constraints) {
          assert(
              !(constraints.maxWidth == double.infinity ||
                  constraints.maxHeight == double.infinity),
              'width, height or both are unconstrained. '
              'For example, if this widget is a child of a ListView, '
              'please set ListView.itemExtent parameter or set '
              'a fixed size to ShaderFXs parent');
          isSizeAcquired = true;
          widgetSize = Size(constraints.maxWidth, constraints.maxHeight);

          if (!widget.startRunning && isStopped) {
            Future.delayed(Duration.zero, () {
              if (context.mounted) setState(() {});
            });
          }
          return const SizedBox.shrink();
        },
      );
    }

    if (!areChannelsSet) {
      if (!widget.startRunning && isStopped) {
        Future.delayed(Duration.zero, () {
          if (context.mounted) setState(() {});
        });
      }
      return SizedBox(
        width: widgetSize.width,
        height: widgetSize.height,
      );
    }

    return ShaderBuilder(
      (context, shader, child) {
        return AnimatedSampler(
          (ui.Image image, size, canvas) {
            // iChannel[0-3]
            for (int i = 0; i < iChannel.length; ++i) {
              if (iChannel[i].texture != null) {
                shader.setImageSampler(i, iChannel[i].texture!);
              }
            }
            shader.setFloat(0, size.width); // iResolution.x
            shader.setFloat(1, size.height); // iResolution.y
            shader.setFloat(2, sw.elapsedMilliseconds / 1000.0); // iTime
            shader.setFloat(3, iMouse.x); // iMouse.x
            shader.setFloat(4, iMouse.y); // iMouse.y
            shader.setFloat(5, iMouse.z); // iMouse.z
            shader.setFloat(6, iMouse.w); // iMouse.w

            canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
          },
          enabled: true, // !isStopped,
          child: child!,
        );
      },
      assetKey: widget.shaderAsset,
      child: GestureDetector(
        onPanStart: (event) {
          if (isStopped) {
            if (widget.autoStartWhenTapped) {
              isStopped = true;
              start();
            } else {
              return;
            }
          }
          startingPos = event.localPosition;
          iMouse = getIMouseValue(
            startingPos,
            event.localPosition,
            PointerState.onPointerDown,
          );
          updatePointer(PointerState.onPointerDown);
        },
        onPanUpdate: (event) {
          if (isStopped) return;
          iMouse = getIMouseValue(
            startingPos,
            event.localPosition,
            PointerState.onPointerMove,
          );
          updatePointer(PointerState.onPointerMove);
        },
        onPanEnd: (event) {
          if (isStopped) return;
          iMouse = getIMouseValue(
            startingPos,
            Offset(iMouse.x, iMouse.y),
            PointerState.onPointerUp,
          );
          updatePointer(PointerState.onPointerUp);
        },
        child: ValueListenableBuilder(
          valueListenable: child,
          builder: (_, animatedChildren, __) {
            return animatedChildren;
          },
        ),
      ),
    );
  }

  /// update iMouse when user interact
  updatePointer(PointerState state) {
    if (widget.controller != null) {
      widget.controller!.pointerDetails = IMouse(
        iMouse.x / widgetSize.width,
        iMouse.y / widgetSize.height,
        (iMouse.z / widgetSize.width).abs(),
        (iMouse.w / widgetSize.height).abs(),
      );
      widget.controller!.pointerState = state;
      if (state == PointerState.onPointerUp) {
        widget.controller!.pointerState = PointerState.none;
      }
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
  IMouse getIMouseValue(
    Offset startingPos,
    Offset pos,
    PointerState eventType,
  ) {
    return IMouse(
      pos.dx,
      pos.dy,
      eventType == PointerState.onPointerDown ||
              eventType == PointerState.onPointerMove
          ? startingPos.dx
          : -startingPos.dx,
      -startingPos.dy,
    );
  }
}
