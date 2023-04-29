import 'package:flutter/material.dart';

/// Test widget used as a shader texture
///
class TestWidget extends StatefulWidget {
  const TestWidget({
    Key? key,
    required this.color,
  }) : super(key: key);
  final Color color;

  @override
  State<TestWidget> createState() => TestWidgetState();
}

class TestWidgetState extends State<TestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late int counter;

  @override
  void initState() {
    super.initState();
    counter = 0;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      width: 400,
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/flutter.png', width: 130),
              const SizedBox(width: 30),
              RotationTransition(
                turns: controller,
                child: const FlutterLogo(size: 130),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    counter--;
                  });
                },
                child: const Icon(Icons.exposure_minus_1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.black,
                child: Text(
                  counter.toString(),
                  textScaleFactor: 4,
                ),
              ),
              FloatingActionButton(
                onPressed: () {
                  setState(() {
                    counter++;
                  });
                },
                child: const Icon(Icons.exposure_plus_1),
              ),
            ],
          )
        ],
      ),
    );
  }
}
