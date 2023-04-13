import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/main/common/album/album.dart';
import 'package:orpheus_client/Screens/main/playlist/playlist.dart';
import 'package:orpheus_client/Screens/main/playlist/show_playlist.dart';

class PlaylistScreenChildArguments {
  CommonAlbumArguments? commonAlbumArguments;
  ShowPlaylistArguments? showPlaylistArguments;
}

class PlaylistScreenRoutes {
  static const String root = '/';
  static const String showPlaylist = '/playlist/show';
  static const String showAlbum = '/album/show';
}

class PlaylistNavigationScreen extends StatelessWidget {
  final PlaylistScreenChildArguments? arguments;
  late GlobalKey<NavigatorState>? navigatorKey;

  PlaylistNavigationScreen({super.key, this.navigatorKey, this.arguments});

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    PlaylistScreenChildArguments? arguments = this.arguments;
    return {
      PlaylistScreenRoutes.root: (context) => const PlaylistScreen(),
      PlaylistScreenRoutes.showPlaylist: (context) {
        if (arguments?.showPlaylistArguments == null) {
          throw Exception('No arguments passed to playlist screen');
        }
        return ShowPlaylistScreen(
          playlistId: arguments!.showPlaylistArguments!.playlistId,
          playlistTitle: arguments.showPlaylistArguments!.playlistTitle,
        );
      },
      PlaylistScreenRoutes.showAlbum: (context) {
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
          initialRoute: PlaylistScreenRoutes.root,
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
