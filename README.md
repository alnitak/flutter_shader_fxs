# Shader FXs


- Still work in progress.
- Tested on Linux and Android
- On stable Flutter channel, widget images (or animated gifs) are not 
grabbed correctly at first try. This has been fixed on **master channel**.

### ShaderTransition widget
Widget to use a shader trasition from [foregroundChild] to [backgroundChild] widget.
Still in WIP

### ShaderInteractive widget
A shader transition from [foregroundChild] to [backgroundChild] with 
user interaction (ie using pointer (iMouse uniform)).

Used for examample for page_curl.frag shader


**problems:** from my understanding AnimatedSampler builds a new widget and 
display it to grab its snapshot image. So the its state is not with its real state:
in the example, scrolling the ListView and press the play button, will 
first show the ListView not scrolled.