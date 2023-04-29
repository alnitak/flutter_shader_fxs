import 'package:flutter/material.dart';
import 'package:shader_fxs/shader_fxs.dart';

import 'page1.dart';
import 'page2.dart';

/// Transition example page
///
class Transition extends StatefulWidget {
  const Transition({super.key});

  @override
  State<Transition> createState() => _TransitionAndInteractiveState();
}

class _TransitionAndInteractiveState extends State<Transition> {
  late ShaderController controller;

  @override
  void initState() {
    super.initState();

    controller = ShaderController()
      ..addListener(() {
        debugPrint('shaderController: ${controller.pointerState}    '
            'shaderState: ${controller.shaderState}');
        if (controller.shaderState == ShaderState.timeout) {
          controller.swapChildren!();
          controller.reset!();
          controller.stop!();
        }
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// shader transition between Page1 and Page2 widgets
          ShaderFXs(
            shaderAsset: 'assets/shaders/zoom_blur.frag',
            controller: controller,
            duration: const Duration(milliseconds: 1500),
            autoStartWhenTapped: false,
            startRunning: false,
            iChannels: [
              ChannelTexture(
                child: const Page1(),
              ),
              ChannelTexture(
                child: const Page2(),
              ),
              ChannelTexture(),
              ChannelTexture(),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.play_arrow),
        onPressed: () {
          controller.start!();
        },
      ),
    );
  }
}
