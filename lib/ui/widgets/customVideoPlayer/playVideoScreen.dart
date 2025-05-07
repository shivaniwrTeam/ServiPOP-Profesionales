import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../app/generalImports.dart';
import 'widgets/playPauseButton.dart';
import 'widgets/videoControlsContainer.dart';

class PlayVideoScreen extends StatefulWidget {
  const PlayVideoScreen({
    super.key,
    this.videoFile,
    this.videoURL,
  });

  final File? videoFile;
  final String? videoURL;

  @override
  State<PlayVideoScreen> createState() => _PlayVideoScreenState();
}

class _PlayVideoScreenState extends State<PlayVideoScreen> with TickerProviderStateMixin {

  //need to use this to ensure youtube/video controller disposed properly
  //When user changed the video so for 100 milliseconds we set assignedVideoController
  //to false
  late bool assignedVideoController = false;

  VideoPlayerController? _videoPlayerController;

  late final AnimationController controlsMenuAnimationController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  late Animation<double> controlsMenuAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: controlsMenuAnimationController, curve: Curves.easeInOut));

  @override
  void initState() {
    loadVideoController();

    super.initState();
  }

  //To load non youtube video
  void loadVideoController() {
    if (widget.videoURL != null) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoURL!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((value) {
          setState(() {});
          _videoPlayerController?.play();
        });
    } else {
      _videoPlayerController = VideoPlayerController.file(
        widget.videoFile!,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((value) {
          setState(() {});
          _videoPlayerController?.play();
        });
    }
    assignedVideoController = true;
  }

  @override
  void dispose() {
    controlsMenuAnimationController.dispose();

    _videoPlayerController?.dispose();
    super.dispose();
  }

  //To show play/pause button and and other control related details
  Widget _buildVideoControlMenuContainer(Orientation orientation) {
    return AnimatedBuilder(
      animation: controlsMenuAnimationController,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: controlsMenuAnimation.value,
          child: GestureDetector(
            onTap: () {
              if (controlsMenuAnimationController.isCompleted) {
                controlsMenuAnimationController.reverse();
              } else {
                controlsMenuAnimationController.forward();
              }
            },
            child: CustomContainer(
              color: Colors.black45,
              child: Stack(
                children: [
                  //
                  Center(
                    child: PlayPauseButtonContainer(
                      controlsAnimationController: controlsMenuAnimationController,
                      videoPlayerController: _videoPlayerController,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: VideoControlsContainer(
                      videoPlayerController: _videoPlayerController,
                      controlsAnimationController: controlsMenuAnimationController,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //To display the video and it's controls
  Widget _buildPlayVideoContainer(Orientation orientation) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomContainer(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Center(
          child: AspectRatio(
            aspectRatio: 5 / 8,
            child: Stack(
              children: [
                Positioned.fill(
                  child: VideoPlayer(
                    _videoPlayerController!,
                  ),
                ),

                //show controls
                _buildVideoControlMenuContainer(orientation),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return PopScope(
          canPop: orientation == Orientation.portrait,
          onPopInvokedWithResult: (didPop, _) {
            if (orientation == Orientation.landscape) {
              SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
            }
          },
          child: Scaffold(
            body: Stack(
              children: [
                //If controller is available to play video then
                //show video container
                if (assignedVideoController)
                  _buildPlayVideoContainer(orientation)
                else
                  const CustomSizedBox()
              ],
            ),
          ),
        );
      },
    );
  }
}
