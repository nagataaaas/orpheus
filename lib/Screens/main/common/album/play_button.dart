import 'package:flutter/material.dart';
import 'package:orpheus_client/styles.dart';

class PlayButton extends StatefulWidget {
  const PlayButton({
    Key? key,
    required this.scrollController,
    required this.maxAppBarHeight,
    required this.minAppBarHeight,
    required this.playPauseButtonSize,
    required this.infoBoxHeight,
  }) : super(key: key);

  final ScrollController scrollController;
  final double maxAppBarHeight;
  final double minAppBarHeight;
  final double playPauseButtonSize;
  final double infoBoxHeight;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.scrollController.addListener(() {
      setState(() {});
    });
  }

  double get getPositionFromTop {
    double position = widget.maxAppBarHeight;
    double finalPosition =
        widget.minAppBarHeight - widget.playPauseButtonSize / 2;

    if (widget.scrollController.hasClients) {
      try {
        double offset = widget.scrollController.offset;
        //When adjusting position, add/subtract in addOrSubtractValue
        double addOrSubtractValue =
            widget.infoBoxHeight - widget.playPauseButtonSize - 10;
        final bool isFinalPosition =
            offset > (position - finalPosition + addOrSubtractValue);
        if (!isFinalPosition) {
          position = position - offset + addOrSubtractValue;
        } else {
          position = finalPosition;
        }
      } catch (e) {
        // at very beginning, widget.scrollController.offset may be fail
        return 0;
      }
    }
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: getPositionFromTop,
      right: 10,
      child: ElevatedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: CommonColors.playButtonColor,
          fixedSize:
              Size(widget.playPauseButtonSize, widget.playPauseButtonSize),
          shape: const CircleBorder(),
        ),
        onPressed: () {},
        child: Icon(
          Icons.play_arrow,
          color: Colors.black,
        ),
      ),
    );
  }
}
