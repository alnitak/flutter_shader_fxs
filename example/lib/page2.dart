import 'package:flutter/material.dart';
import 'package:shader_fxs/shader_fxs.dart';

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(width: 2, color: Colors.blue),
      borderRadius: BorderRadius.circular(8),
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 60,
          right: 60,
          top: 16,
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(300.0),
              child: SizedBox(
                width: 300,
                height: 300,
                child: ShaderFXs(
                  shaderAsset: 'assets/shaders/test1.frag',
                  iChannels: [
                    ChannelTexture(),
                    ChannelTexture(),
                    ChannelTexture(),
                    ChannelTexture(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'WELCOME\nto ShaderFXs',
              textScaleFactor: 3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            TextField(
              decoration: InputDecoration(
                hintText: 'email*',
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              decoration: InputDecoration(
                hintText: 'password*',
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () {},
                ),
                ElevatedButton(
                  child: const Text('Sign in'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
