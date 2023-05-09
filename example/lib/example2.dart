import 'package:flutter/material.dart';
import 'package:shader_fxs/shader_fxs.dart';

import 'page1.dart';
import 'page2.dart';

/// Transition example page
///
class Example2 extends StatefulWidget {
  const Example2({super.key});

  @override
  State<Example2> createState() => _TransitionAndInteractiveState();
}

class _TransitionAndInteractiveState extends State<Example2> {
  late ShaderController controller;

  @override
  void initState() {
    super.initState();

    controller = ShaderController()
      ..addListener(() {
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
          // const Page1(),
          /// shader transition between Page1 and Page2 widgets
          ShaderFXs(
            shaderAsset: 'assets/shaders/zoom_blur.frag',
            controller: controller,
            duration: const Duration(milliseconds: 1500),
            autoStartWhenTapped: false,
            startRunning: false,
            iChannels: [
              ChannelTexture(
                isDynamic: true,
                child: const Page2(),
              ),
              ChannelTexture(
                isDynamic: true,
                child: const Page1(),
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
