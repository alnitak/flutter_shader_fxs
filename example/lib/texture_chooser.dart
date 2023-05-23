import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shader_fxs/shader_fxs.dart';
import 'package:star_menu/star_menu.dart';

import 'test_widget.dart';

final iChannel0Provider = StateProvider<ChannelTexture>((ref) {
  // return ChannelTexture(assetsImage: 'assets/gifs/1.gif', isDynamic: true);
  // return ChannelTexture(assetsImage: 'assets/dash.png', isDynamic: false);
  return ChannelTexture(child: TestWidget(color: Colors.deepPurple.shade700), isDynamic: true);
});

final iChannel1Provider = StateProvider<ChannelTexture>((ref) {
  return ChannelTexture(assetsImage: 'assets/gifs/2.gif', isDynamic: true);
  // return ChannelTexture(assetsImage: 'assets/flutter.png', isDynamic: false);
  // return ChannelTexture(child: const TestWidget(color: Colors.white), isDynamic: false);
});

final iChannel2Provider = StateProvider<ChannelTexture>((ref) {
  return ChannelTexture();
  // return ChannelTexture(assetsImage: 'assets/flutter.png');
});

final iChannel3Provider = StateProvider<ChannelTexture>((ref) {
  return ChannelTexture();
  // return ChannelTexture(assetsImage: 'assets/flutter.png');
});

/// Row of 4 textures that represent the 4 iChannel[0-3]
///
class TextureChooser extends ConsumerWidget {
  const TextureChooser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) => TextureWidget(channelId: index)),
    );
  }
}

/// Widget that display the current binded texture
///
class TextureWidget extends ConsumerWidget {
  final int channelId;
  final double? width;
  final double? height;

  const TextureWidget({
    Key? key,
    required this.channelId,
    this.width = 80,
    this.height = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChannelTexture texture;
    switch (channelId) {
      case 0:
        texture = ref.watch(iChannel0Provider);
        break;
      case 1:
        texture = ref.watch(iChannel1Provider);
        break;
      case 2:
        texture = ref.watch(iChannel2Provider);
        break;
      case 3:
        texture = ref.watch(iChannel3Provider);
        break;
      default:
        texture = ref.watch(iChannel0Provider);
    }

    return Column(
      children: [
        Stack(
          children: [
            /// STARMENU POPUP
            StarMenu(
              params: StarMenuParameters(
                  backgroundParams: BackgroundParams(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    animatedBackgroundColor: true,
                    // animatedBlur: true,
                    // sigmaX: 10,
                    // sigmaY: 10,
                  ),
                  shape: MenuShape.linear,
                  linearShapeParams: const LinearShapeParams(
                    alignment: LinearAlignment.left,
                  ),
                  boundaryBackground: BoundaryBackground(
                    color: const Color(0x300e0e0e),
                    blurSigmaX: 15.0,
                    blurSigmaY: 15.0,
                  ),
                  centerOffset: const Offset(0, -100)),
              items: _items(),
              onItemTapped: (index, controller) {
                controller.closeMenu!();
              },
              child: Container(
                width: width,
                height: height,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 3, color: Colors.white),
                  image: texture.assetsImage == null
                      ? null
                      : DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(texture.assetsImage!),
                        ),
                ),
                child: FittedBox(child: texture.child),
              ),
            ),

            /// REMOVE TEXTURE
            Positioned(
              right: 9,
              top: 9,
              child: GestureDetector(
                onTap: () {
                  switch (channelId) {
                    case 0:
                      ref
                          .read(iChannel0Provider.notifier)
                          .update((state) => ChannelTexture());
                      break;
                    case 1:
                      ref
                          .read(iChannel1Provider.notifier)
                          .update((state) => ChannelTexture());
                      break;
                    case 2:
                      ref
                          .read(iChannel2Provider.notifier)
                          .update((state) => ChannelTexture());
                      break;
                    case 3:
                      ref
                          .read(iChannel3Provider.notifier)
                          .update((state) => ChannelTexture());
                      break;
                  }
                },
                child: const Icon(Icons.delete_outline, size: 24),
              ),
            ),
          ],
        ),
        Text('iChannel$channelId'),
      ],
    );
  }

  List<Widget> _items() {
    return [
      Item(
          channelId: channelId,
          texture: ChannelTexture(assetsImage: 'assets/dash.png'),
          text: 'texture\n1481x900'),
      Item(
          channelId: channelId,
          texture: ChannelTexture(assetsImage: 'assets/flutter.png'),
          text: 'texture\n512x512'),
      Item(
          channelId: channelId,
          texture: ChannelTexture(assetsImage: 'assets/rgba_noise_medium.png'),
          text: 'texture\n96x96'),
      Item(
          channelId: channelId,
          texture: ChannelTexture(assetsImage: 'assets/rgba_noise_small.png'),
          text: 'texture\n96x96'),
      Item(
          channelId: channelId,
          texture:
              ChannelTexture(assetsImage: 'assets/gifs/2.gif', isDynamic: true),
          text: 'animated GIF'),
      Item(
          channelId: channelId,
          texture: ChannelTexture(
            child: TestWidget(color: Colors.deepPurple.shade700),
          ),
          text: 'test widget'),
      Item(
          channelId: channelId,
          texture: ChannelTexture(
            child: const TestWidget(color: Colors.white),
          ),
          text: 'test widget'),
    ];
  }
}

/// Entry for the menu
///
/// It display the texture image and its resolution
class Item extends ConsumerWidget {
  final int channelId;
  final ChannelTexture texture;
  final String text;

  const Item({
    Key? key,
    required this.channelId,
    required this.texture,
    required this.text,
  }) : super(key: key);

  _setTexture(WidgetRef ref) {
    StateController<ChannelTexture> channelProvider;
    switch (channelId) {
      case 0:
        channelProvider = ref.read(iChannel0Provider.notifier);
        break;
      case 1:
        channelProvider = ref.read(iChannel1Provider.notifier);
        break;
      case 2:
        channelProvider = ref.read(iChannel2Provider.notifier);
        break;
      case 3:
        channelProvider = ref.read(iChannel3Provider.notifier);
        break;
      default:
        channelProvider = ref.read(iChannel0Provider.notifier);
        break;
    }
    channelProvider.update((state) => texture);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget child = const SizedBox.shrink();
    if (texture.child != null) {
      child = SizedBox(
        width: 80,
        height: 80,
        child: FittedBox(child: texture.child!),
      );
    } else if (texture.assetsImage != null) {
      child = Image.asset(texture.assetsImage!, width: 80, height: 80);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => _setTexture(ref),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3f3f3f),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 1, color: Colors.black),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: child,
              ),
              const SizedBox(width: 10),
              Text(text),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
