import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shader_fxs/shader_fxs.dart';

import 'page1.dart';
import 'page2.dart';

final songProvider = StateProvider<Song>((ref) {
  return songList[0];
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          dividerTheme: const DividerThemeData(
            color: Colors.white54,
            thickness: 2,
          )),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  late ShaderController shaderController;

  @override
  void initState() {
    super.initState();
    shaderController = ShaderController()
      ..addListener(() {
        debugPrint('shaderController: ${shaderController.state}');
      });
  }

  @override
  void dispose() {
    shaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page1(),
          ShaderTransition(
            controller: shaderController,
            duration: const Duration(milliseconds: 2500),
            foregroundChild: Page1(),
            backgroundChild: Page2(),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.timer_outlined),
            onPressed: () {
              print(shaderController.progress!());
            },
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            child: const Icon(Icons.play_arrow),
            onPressed: () {
              shaderController.start!();
            },
          ),
        ],
      ),
    );
  }
}
