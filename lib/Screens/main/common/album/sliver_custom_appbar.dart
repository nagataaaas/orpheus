import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:orpheus_client/Screens/main/common/album/album_image.dart';
import 'package:orpheus_client/Screens/main/common/album/fixed_appbar.dart';
import 'package:orpheus_client/Screens/main/common/album/sliver_appbar_delegate.dart';
import 'package:orpheus_client/styles.dart';

class SliverCustomeAppBar extends StatelessWidget {
  const SliverCustomeAppBar({
    Key? key,
    required this.albumTitle,
    required this.albumImage,
    required this.maxAppBarHeight,
    required this.minAppBarHeight,
    required this.onTapAction,
  }) : super(key: key);

  final String albumTitle;
  final StatefulWidget albumImage;
  final double maxAppBarHeight;
  final double minAppBarHeight;
  final Function() onTapAction;

  @override
  Widget build(BuildContext context) {
    final extraTopPadding = MediaQuery.of(context).size.height * 0.05;
    //app bar content padding
    final padding = EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + extraTopPadding,
        right: 10,
        left: 10);

    return SliverPersistentHeader(
        pinned: true,
        delegate: SliverAppBarDelegate(
            maxHeight: maxAppBarHeight,
            minHeight: minAppBarHeight,
            builder: (context, shrinkOffset) {
              final double shrinkToMaxAppBarHeightRatio =
                  shrinkOffset / maxAppBarHeight;
              const double animatAlbumImageFromPoint = 0.4;
              final animateAlbumImage =
                  shrinkToMaxAppBarHeightRatio >= animatAlbumImageFromPoint;
              final animateOpacityToZero = shrinkToMaxAppBarHeightRatio > 0.6;
              final albumPositionFromTop = animateAlbumImage
                  ? (animatAlbumImageFromPoint - shrinkToMaxAppBarHeightRatio) *
                      maxAppBarHeight
                  : null;
              final albumImageSize =
                  MediaQuery.of(context).size.height * 0.3 - shrinkOffset / 2;
              final showFixedAppBar = shrinkToMaxAppBarHeightRatio == 1;
              final double titleOpacity = showFixedAppBar
                  ? 1 - (maxAppBarHeight - shrinkOffset) / minAppBarHeight
                  : 0;

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: albumPositionFromTop,
                    child: GestureDetector(
                      onTap: onTapAction,
                      child: AlbumImage(
                        albumImage: albumImage,
                        padding: padding,
                        animateOpacityToZero: animateOpacityToZero,
                        animateAlbumImage: animateAlbumImage,
                        shrinkToMaxAppBarHeightRatio:
                            shrinkToMaxAppBarHeightRatio,
                        albumImageSize: albumImageSize,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      // TODO: calculate accent color from album image
                      gradient: showFixedAppBar
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                  CommonColors.primaryThemeAccentColor,
                                  CommonColors.primaryThemeAccentColor
                                      .withOpacity(0.8),
                                ],
                              stops: const [
                                  0,
                                  0.5
                                ])
                          : null,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: minAppBarHeight,
                      child: FixedAppBar(
                        title: albumTitle,
                        titleOpacity: titleOpacity,
                      ),
                    ),
                  ),
                ],
              );
            }));
  }
}
