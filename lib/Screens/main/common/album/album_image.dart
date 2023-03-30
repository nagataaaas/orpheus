import 'package:flutter/material.dart';

class AlbumImage extends StatelessWidget {
  const AlbumImage({
    Key? key,
    required this.albumImage,
    required this.padding,
    required this.animateOpacityToZero,
    required this.animateAlbumImage,
    required this.shrinkToMaxAppBarHeightRatio,
    required this.albumImageSize,
  }) : super(key: key);

  final StatefulWidget albumImage;
  final EdgeInsets padding;
  final bool animateOpacityToZero;
  final bool animateAlbumImage;
  final double shrinkToMaxAppBarHeightRatio;
  final double albumImageSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: animateOpacityToZero
              ? 0
              : animateAlbumImage
                  ? 1 - shrinkToMaxAppBarHeightRatio
                  : 1,
          child: Container(
            height: albumImageSize,
            width: albumImageSize,
            decoration: const BoxDecoration(
              color: Colors.deepPurpleAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black87,
                  spreadRadius: 1,
                  blurRadius: 50,
                ),
              ],
            ),
            child: albumImage,
          ),
        ));
  }
}
