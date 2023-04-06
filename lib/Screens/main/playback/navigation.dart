import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/main/common/album/album.dart';

import 'playback.dart';

class PlaybackScreenChildArguments {
  CommonAlbumArguments? commonAlbumArguments;
}

class PlaybackScreenRoutes {
  static const String root = '/';
  static const String showAlbum = '/album/show';
}

class PlaybackNavigationScreen extends StatelessWidget {
  final PlaybackScreenChildArguments? arguments;
  late GlobalKey<NavigatorState>? navigatorKey;

  PlaybackNavigationScreen({super.key, this.navigatorKey, this.arguments});

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    PlaybackScreenChildArguments? arguments = this.arguments;
    return {
      PlaybackScreenRoutes.root: (context) => const PlayBackScreen(),
      PlaybackScreenRoutes.showAlbum: (context) {
        if (arguments?.commonAlbumArguments == null) {
          throw Exception('No arguments passed to album screen');
        }
        return CommonAlbumScreen(
          albumId: arguments!.commonAlbumArguments!.albumId,
          albumTitle: arguments.commonAlbumArguments!.albumTitle,
          image: arguments.commonAlbumArguments!.image,
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);
    final navKey = navigatorKey ?? GlobalKey<NavigatorState>();
    return WillPopScope(
      onWillPop: () async {
        return await navKey.currentState?.maybePop() != true;
      },
      child: Scaffold(
        body: Navigator(
          key: navKey,
          initialRoute: PlaybackScreenRoutes.root,
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute(
                builder: (context) =>
                    routeBuilders[routeSettings.name]!(context));
          },
        ),
      ),
    );
  }
}
