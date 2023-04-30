# Shader FXs

A flutter pluging to use shaders and use them to make transitions between widgets and/or images, or just without textures.


- Still work in progress.

||Flutter 3.7.12 </br> channel stable|Flutter 3.10.0-16.0.pre.33 </br> channel master|
|---|---|---|
|**Android**|• Images and GIFs are grabbed correctly</br>• Performaces degradation till crash</br>• Swap textures when using a widget doesn't work as expected|Problems setting samplers|
|**iOS**|Problems setting samplers|Problems setting samplers|
|**web**|Not yet supported|Slow but no issues|
|**Linux**|• Images are not grabbed when used inside a widget</br>• Swap textures when using a widget doesn't work as expected|No issues|
|**Windows**|No issues|No issues|
|**MacOS**|No issues|No issues|

# Features

- ✅ transitions between widgets or image textures
- ✅ shader effects on widget or image texture
- ✅ controller to start, stop, reset or swap textures
- ✅ controller to listen the current shader and pointer state and pointer gestures

#### switch to master/stable channels
```
flutter channel [master|stable]
flutter upgrade
```

# Usage

Store your fragment shader in your assets folder, then link it into pubspec.yeaml under *flutter* key:

```
flutter:

  shaders:
    - assets/radial_blur.frag
```

use ShaderFX widget:

```
	/// shader transition between Page1 and Page2 widgets
    ShaderFXs(
      shaderAsset: 'assets/shaders/zoom_blur.frag',
      controller: controller,
      duration: const Duration(milliseconds: 1500),
      autoStartWhenTapped: false,
      startRunning: false,
      iChannels: [
        ChannelTexture(child: const Page1()),
        ChannelTexture(child: const Page2()),
        ChannelTexture(),
        ChannelTexture(),
      ],
    )
```
this will add the shader on the parent of ShaderFXs.

the controller is optional and with that it's possible to listen to the shader and pointer state and even the pan position when the user is interacting:

```
  ShaderController controller = ShaderController();
  controller.addListener(() async{
    PointerState pointerState = controller.pointerState;
    IMouse pointerDetails = controller.pointerDetails;
    ShaderState shaderState = controller.shaderState;

    // if pointer comes from rigth (pointerDetails.z) and
    // moved to the left
    // and the pointer is still moving
    // and the shader is running
    // then the page has been curled
    if (pointerDetails.x < 0.2 && pointerDetails.z > 0.2 &&
        pointerState == PointerState.onPointerMove &&
        shaderState == ShaderState.running
    ) {
      controller.reset!();
      controller.swapChildren!();
      controller.stop!();
    }

	// if pointer is up and shader still running
    // reset the shader to the first iChannel
    if (pointerState == PointerState.onPointerUp &&
        shaderState == ShaderState.running
    ) {
      controller.reset!();
    }
});
```

***shaderAsset***: string that points to the fragment text source

***controller***: ShaderController type (see below)

***startRunning***: bool to automatically start the shader

***duration***: Duration after wich the shader will stop

***iChannels***: list of [ChannelTexture]s

### *ShaderController*

||||
|---------|-------|---|
|**start**|start the shader|returns false if already running|
|**stop**|stop the shader at current execution time|returns false if already stopped|
|**reset**|reset iTime and iMouse||
|**swapChildren**|swap 1st and 2nd iChannel||
|**shaderState**|get the state of shader|returns a ShaderState enum which can be *stopped*, *running* or *timeout*|
|**pointerState**|get the status of pointer| retrun a PointerState enum which can be *onPointerDown*, *onPointerMove*, *onPointerUp* or *none*|
|**pointerDetails**|get details of pointer| retruns ***IMouse*** (see below)|

### *IMouse*

*IMouse.xy*  = current mouse position during pan (in percentage 0.0~1.0)

*IMouse.zw*  = mouse position when pan started (in percentage 0.0~1.0)

*sign(IMouse.z)*  = button is down

*sign(IMouse.w)*  = button is clicked


### *ChannelTexture*

|||
|---------|---|
|**assetsImage**|this is the path of the assets image|
|**child**|the widget to grab as texture|
|**isDynamic**|set it to true if the assets image is by example an animated GIF|


# Writing your own shader (WIP)
ShaderFXs has a fixed number of uniforms and cannot be modified for now. These uniforms are:
```
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec2 uResolution;
uniform float iTime;
uniform vec4 iMouse;
```

# Limitation

Shaders are compiled with SPIR-V which only support a [subset of SPIR-V within Flutter](https://docs.google.com/document/d/1z9K5LernwQ0LVAzfbAMW6ITx63QRdRsoax1NLYEfm4Y/edit#heading=h.se4z5ulru1zb). 
It only allows code that is legally working on GLSL ES 1.00 or WebGL 1.0 to be compatible to the most of devices.

Anyway [SkSL is Skia’s shading language](https://skia.org/docs/user/sksl/) is limited compared to [OpenGL Shading Language](https://www.khronos.org/opengl/wiki/OpenGL_Shading_Language) (GLSL).

As long as Impleller engine is still in developing stage, we can [try to use it!](https://github.com/flutter/engine/tree/main/impeller#try-impeller-in-flutter)

I didn't found a SPIRV-SkSL limits list, if someone know please tell me!

A few years ago, I began to develop a native [Flutter OpenGL ES plugin](https://github.com/alnitak/flutter_opengl) which now works on Android, Linux and Widnows. It has its pros and cons but it worth a try.



# Readings & Tools

[ShaderToy](https://www.shadertoy.com/) here you can get inspired and try to write your own new shaders
[Writing and using fragment shaders](https://docs.flutter.dev/development/ui/advanced/shaders)
[The Book of Shaders](https://thebookofshaders.com/) by Patricio Gonzalez Vivo and Jen Lowe
Mind blowing shaders by searching this tag [#つぶやきGLSL](https://twitter.com/search?q=%23%E3%81%A4%E3%81%B6%E3%82%84%E3%81%8DGLSL) in Twitter! Most of them are referring to [this](https://twigl.app/) geeks web site.

# Acknowledgements

Fagment shaders stored in ```example/assets/shaders``` are taken as-is from
[ShaderToy](https://www.shadertoy.com/) and the url of the shader is written 
in each of the .frag sources.


# The example

The following are screen recording of the example running on a Linux machine with AMD Ryzen 9 5950X and a Radeon RX 6600 XT





