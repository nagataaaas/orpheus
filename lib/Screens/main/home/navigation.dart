import 'package:flutter/material.dart';
import 'package:orpheus_client/Screens/main/common/album/album.dart';

import 'package:orpheus_client/styles.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'home.dart';
import 'search.dart';
import 'search_result.dart';

class HomeScreenChildArguments {
  HomeSearchResultArguments? homeSearchResultArguments;
  CommonAlbumArguments? commonAlbumArguments;
}

class HomeScreenRoutes {
  static const String root = '/';
  static const String search = '/search';
  static const String searchResult = '/search/result';
  static const String showAlbum = '/album/show';
}

class HomeNavigationScreen extends StatelessWidget {
  final HomeScreenChildArguments? arguments;
  late GlobalKey<NavigatorState>? navigatorKey;

  HomeNavigationScreen({super.key, this.navigatorKey, this.arguments});

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    HomeScreenChildArguments? arguments = this.arguments;
    return {
      HomeScreenRoutes.root: (context) => const HomeScreen(),
      HomeScreenRoutes.search: (context) => const HomeSearchScreen(),
      HomeScreenRoutes.searchResult: (context) {
        if (arguments?.homeSearchResultArguments == null) {
          throw Exception('No arguments passed to search result screen');
        }
        return HomeSearchResultScreen(
          arguments: arguments!.homeSearchResultArguments!,
        );
      },
      HomeScreenRoutes.showAlbum: (context) {
        if (arguments?.commonAlbumArguments == null) {
          throw Exception('No arguments passed to album screen');
        }
        return CommonAlbumScreen(
          albumId: arguments!.commonAlbumArguments!.albumId!,
          albumTitle: arguments!.commonAlbumArguments!.albumTitle!,
          image: arguments!.commonAlbumArguments!.image!,
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
          initialRoute: HomeScreenRoutes.root,
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
