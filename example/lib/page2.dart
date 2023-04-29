import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'page1.dart';

class Page2 extends ConsumerWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Song song = ref.watch(songProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 150,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 148,
                  backgroundImage: AssetImage(song.assetsImage),
                ),
              ),
              Text(song.title, textScaleFactor: 2.0),
              Text(song.duration, textScaleFactor: 1.5),
              Text(song.album, textScaleFactor: 1.3),
              ElevatedButton(
                onPressed: () {
                  print('page2 button pressed');
                },
                child: const Text('button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
