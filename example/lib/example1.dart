import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shader_fxs/shader_fxs.dart';

final songProvider = StateProvider<Song>((ref) {
  return songList[0];
});

class Song {
  Song(
    this.assetsImage,
    this.artist,
    this.album,
    this.title,
    this.duration,
  );

  String assetsImage;
  String artist;
  String album;
  String title;
  String duration;
}

final List<Song> songList = [
  Song(
    'assets/gifs/1.gif',
    'Dire Straits',
    'Brothers in Arms',
    'Why Worry',
    '08:26',
  ),
  Song(
    'assets/gifs/2.gif',
    'Dire Straits',
    'Brothers in Arms',
    'Money For Nothing',
    '08:26',
  ),
  Song(
    'assets/flutter.png',
    'Scorpions',
    'Crazy World',
    'Tease Me Please Me',
    '04:46',
  ),
  Song(
    'assets/dash.png',
    'Dire Straits',
    'Brothers in Arms',
    'Ride Across The River',
    '06:59',
  ),
];

class Example1 extends ConsumerWidget {
  const Example1({Key? key}) : super(key: key);

  final int itemCount = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// generate a controller for each item row
    List<ShaderController> controllers = List.generate(itemCount, (index) {
      ShaderController ctrl = ShaderController();
      ctrl.addListener(() async {
        /// here it's possible to check the user pointer coordinates
        /// and, in case of using page curl effect, swap
        /// the children when the user pan to the leftmost position
        PointerState pointerState = ctrl.pointerState;
        IMouse pointerDetails = ctrl.pointerDetails;
        ShaderState shaderState = ctrl.shaderState;

        // if pointer comes from right (pointerDetails.z) and
        // moved to the left
        // and the pointer is still moving
        // and the shader is running
        // then the page has been curled
        if (pointerDetails.x < 0.2 && // current x position
            pointerDetails.z > 0.2 && // starting x position
            pointerState == PointerState.onPointerMove &&
            shaderState == ShaderState.running) {
          ctrl.reset!();
          ctrl.swapChildren!();
          ctrl.stop!();
        }

        // if pointer is up and shader still running
        // reset the shader to the first iChannel
        if (pointerState == PointerState.onPointerUp &&
            shaderState == ShaderState.running) {
          ctrl.reset!();
        }
      });
      return ctrl;
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ListView.builder(
            itemCount: itemCount,
            // itemExtent: 100,
            itemBuilder: (_, index) {
              return SizedBox(
                // give a finite height to the ShaderFXs
                height: 100,
                child: ShaderFXs(
                  shaderAsset: 'assets/shaders/page_curl.frag',
                  autoStartWhenTapped: true,
                  startRunning: false,
                  iChannels: [
                    ChannelTexture(
                      isDynamic: false,
                      child: SongRow(
                        isBackgroundChild: false,
                        index: index % songList.length,
                        song: songList[index % songList.length],
                        onTap: (song) {
                          ref
                              .read(songProvider.notifier)
                              .update((state) => song);
                        },
                      ),
                    ),
                    ChannelTexture(
                      isDynamic: false,
                      child: SongRow(
                        isBackgroundChild: true,
                        index: index % songList.length,
                        song: songList[index % songList.length],
                        onTap: (song) {
                          ref
                              .read(songProvider.notifier)
                              .update((state) => song);
                        },
                      ),
                    ),
                    ChannelTexture(),
                    ChannelTexture(),
                  ],
                  controller: controllers.elementAt(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ListView row
class SongRow extends ConsumerWidget {
  const SongRow({
    Key? key,
    required this.isBackgroundChild,
    required this.onTap,
    required this.index,
    required this.song,
  }) : super(key: key);

  final bool isBackgroundChild;
  final int index;
  final Song song;
  final Function(Song) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => onTap(song),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: !isBackgroundChild
              ? ForegroundChild(
                  assetsImage: song.assetsImage,
                  title: song.title,
                  subTitle: '${song.artist} - ${song.album}\n${song.duration}',
                  onTap: () => onTap(song),
                )
              : BackgroundChild(
                  assetsImage: song.assetsImage,
                  title: song.title,
                  subTitle: '${song.artist} - ${song.album}\n${song.duration}',
                  onTap: () => onTap(song),
                ),
        ),
      ),
    );
  }
}

/// foreground ListView row
class ForegroundChild extends StatelessWidget {
  const ForegroundChild({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.assetsImage,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final String assetsImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textScaleFactor: 1.1,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              subTitle,
              textScaleFactor: 0.9,
            ),
          ],
        ),
        const Spacer(),
        Image.asset(
          assetsImage,
          height: 100,
          width: 180,
          fit: BoxFit.fill,
        ),
      ],
    );
  }
}

/// background ListView row
class BackgroundChild extends ConsumerWidget {
  const BackgroundChild({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.assetsImage,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final String assetsImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(assetsImage, fit: BoxFit.fitWidth, gaplessPlayback: true),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              textScaleFactor: 1.8,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
