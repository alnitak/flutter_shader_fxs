import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const CircleAvatar(
                radius: 150,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 148,
                  backgroundImage: AssetImage('assets/gifs/1.gif'),
                ),
              ),
              const Text('Dire Straits', textScaleFactor: 4.0),
              const Text('Brothers in Arms', textScaleFactor: 2),
              const Text('Why Worry', textScaleFactor: 1.8),
              ElevatedButton(
                onPressed: () {
                  debugPrint('button pressed');
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
