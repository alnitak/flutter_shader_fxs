import 'package:example/texture_chooser.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shader_fxs/shader_fxs.dart';

final runningProvider = StateProvider<bool>((ref) => true);

final fragsIndexProvider = StateProvider<List<int>>((ref) {
  return [0, 0];
});

/// Lists of shaders
List<List<String>> fragLists = [
  // 2 texture channels (transitions)
  [
    'assets/shaders/curl_noise.frag',
    'assets/shaders/page_curl.frag',
    'assets/shaders/noise_fade.frag',
    'assets/shaders/screen_melt.frag',
    'assets/shaders/zoom_blur.frag',
  ],
  // 1 texture channels
  [
    'assets/shaders/radial_blur.frag',
    'assets/shaders/ripple.frag',
  ],
  // no texture channels
  [
    'assets/shaders/test1.frag',
    'assets/shaders/test2.frag',
    'assets/shaders/test3.frag',
    'assets/shaders/test4.frag',
    'assets/shaders/test5.frag',
  ]
];

/// Widget to demostrate use of [ShaderFXs]
///
class ShaderPage extends ConsumerWidget {
  const ShaderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var chan0 = ref.watch(iChannel0Provider);
    var chan1 = ref.watch(iChannel1Provider);
    var chan2 = ref.watch(iChannel2Provider);
    var chan3 = ref.watch(iChannel3Provider);
    var frags = ref.watch(fragsIndexProvider);
    int listIndex = frags.first;
    int fragIndex = frags.last;

    ShaderController controller = ShaderController();
    // controller.addListener(() async {
    // /// here it's possible to check the user pointer coordinates
    // /// and, in case of using page curl effect, swap
    // /// the children when the user pan to the leftmost position
    // PointerState pointerState = controller.pointerState;
    // IMouse pointerDetails = controller.pointerDetails;
    // ShaderState shaderState = controller.shaderState;
    // print('******** $shaderState      $pointerDetails   $pointerState');
    //
    // if (pointerDetails.x < 0.2 && pointerDetails.z > 0.2 &&
    //     pointerState == PointerState.onPointerMove &&
    //     shaderState == ShaderState.running
    // ) {
    //   controller.reset!();
    //   controller.swapChildren!();
    //   controller.stop!();
    //   ref.read(runningProvider.notifier).update((state) => false);
    // }
    // });

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          shaderWidget(
              listIndex, fragIndex, controller, chan0, chan1, chan2, chan3),
          const SizedBox(height: 8),
          ListView(
            shrinkWrap: true,
            children: buttons(listIndex, fragIndex, controller, ref),
          ),
        ],
      ),
    );
  }

  String fragmentButtonText(String assetName) {
    return assetName.split('/').last.split('.').first.replaceAll('_', ' ');
  }

  Widget shaderWidget(
      int listIndex,
      int fragIndex,
      ShaderController controller,
      ChannelTexture chan0,
      ChannelTexture chan1,
      ChannelTexture chan2,
      ChannelTexture chan3) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 250,
        child: ShaderFXs(
          key: UniqueKey(),
          // autoStartWhenTapped: true,
          startRunning: true,
          shaderAsset: fragLists[listIndex][fragIndex],
          iChannels: [chan0, chan1, chan2, chan3],
          controller: controller,
        ),
      ),
    );
  }

  List<Widget> buttons(int listIndex, int fragIndex,
      ShaderController controller, WidgetRef ref) {
    return [
      /// FRAGMENT BUTTONS
      ///
      // 2 channel textures
      const Text(
        '2 channel textures',
        style:
            TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
      ),
      Wrap(
        runSpacing: 4,
        spacing: 6,
        children: List<Widget>.generate(
          fragLists[0].length,
          (index) {
            return ElevatedButton(
              style: listIndex == 0 && index == fragIndex
                  ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green))
                  : const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
              onPressed: () {
                ref
                    .read(fragsIndexProvider.notifier)
                    .update((state) => [0, index]);
              },
              child: Text(fragmentButtonText(fragLists[0][index])),
            );
          },
        ),
      ),
      const Divider(),

      // 1 channel texture
      const Text(
        '1 channel texture',
        style:
            TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
      ),
      Wrap(
        runSpacing: 4,
        spacing: 6,
        children: List<Widget>.generate(
          fragLists[1].length,
          (index) {
            return ElevatedButton(
              style: listIndex == 1 && index == fragIndex
                  ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green))
                  : const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
              onPressed: () {
                ref
                    .read(fragsIndexProvider.notifier)
                    .update((state) => [1, index]);
              },
              child: Text(fragmentButtonText(fragLists[1][index])),
            );
          },
        ),
      ),
      const Divider(),

      // no channel texture
      const Text(
        'no channel textures',
        style:
            TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
      ),
      Wrap(
        runSpacing: 4,
        spacing: 6,
        children: List<Widget>.generate(
          fragLists[2].length,
          (index) {
            return ElevatedButton(
              style: listIndex == 2 && index == fragIndex
                  ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green))
                  : const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
              onPressed: () {
                ref
                    .read(fragsIndexProvider.notifier)
                    .update((state) => [2, index]);
              },
              child: Text(fragmentButtonText(fragLists[2][index])),
            );
          },
        ),
      ),
      const Divider(),

      /// control buttons
      Consumer(builder: (_, ref, __) {
        var isRunning = ref.watch(runningProvider);

        return Wrap(
          spacing: 6,
          children: [
            ElevatedButton(
              style: isRunning
                  ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green))
                  : null,
              onPressed: () {
                controller.start!();
                ref.read(runningProvider.notifier).update((state) => true);
              },
              child: const Text('start'),
            ),
            ElevatedButton(
              style: !isRunning
                  ? const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green))
                  : null,
              onPressed: () {
                controller.stop!();
                ref.read(runningProvider.notifier).update((state) => false);
              },
              child: const Text('stop'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.reset!();
              },
              child: const Text('reset'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.swapChildren!();
              },
              child: const Text('swap 0-1'),
            ),
          ],
        );
      }),
      const Divider(),
      const TextureChooser(),
    ];
  }
}
