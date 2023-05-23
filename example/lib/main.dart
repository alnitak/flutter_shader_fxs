import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'example1.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'example2.dart';
import 'shader_ex.dart';

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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shader FXs example'),
          bottom: const TabBar(
            tabs: [
              Text('example 1'),
              Text('example 2'),
              Text('shaders tests'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            Example2(),
            Example1(),
            ShaderPage(),
          ],
        ),
      ),
    );
  }
}
