import 'package:flutter/material.dart';

import 'package:orpheus_client/Screens/main/home/navigation.dart';
import 'package:orpheus_client/Screens/main/playback/bottom_playback_bar.dart';
import 'package:orpheus_client/Screens/main/playback/navigation.dart';
import 'package:orpheus_client/Screens/main/playlist/navigation.dart';
import 'package:orpheus_client/providers/play_state.dart';
import 'package:orpheus_client/styles.dart';
import 'package:orpheus_client/Screens/main/account.dart';
import 'package:provider/provider.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  final homeNavigationNavigationKey = GlobalKey<NavigatorState>();
  final playlistNavigationNavigationKey = GlobalKey<NavigatorState>();
  final playbackNavigationNavigationKey = GlobalKey<NavigatorState>();
  late final _pages = [
    HomeNavigationScreen(
      navigatorKey: homeNavigationNavigationKey,
    ),
    PlaylistNavigationScreen(
      navigatorKey: playlistNavigationNavigationKey,
    ),
    PlaybackNavigationScreen(
      navigatorKey: playbackNavigationNavigationKey,
    ),
    const AccountScreen(),
  ];
  late PageController _pageController;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void setIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final iconSize = AppBar().preferredSize.height * 0.5;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayState()),
      ],
      child: Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
            onPageChanged: (int i) {
              setIndex(i);
            },
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedIndex != 2)
                BottomPlayBackBar(onTap: () {
                  setIndex(2);
                }),
              Container(
                decoration: BoxDecoration(
                    color: CommonColors.primaryThemeDarkColor,
                    border: Border(
                        top: BorderSide(
                            color: CommonColors.secondaryThemeDarkColor,
                            width: 0.5))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: CommonColors.primaryThemeDarkColor,
                    ),
                    child: BottomNavigationBar(
                        currentIndex: _selectedIndex,
                        selectedItemColor: CommonColors.primaryThemeColor,
                        unselectedItemColor: CommonColors.secondaryThemeColor,
                        selectedLabelStyle: const TextStyle(fontSize: 12),
                        onTap: (index) {
                          if (index == _selectedIndex) {
                            switch (index) {
                              case 0:
                                homeNavigationNavigationKey.currentState!
                                    .popUntil((route) => route.isFirst);
                                break;
                              case 1:
                                playlistNavigationNavigationKey.currentState!
                                    .popUntil((route) => route.isFirst);
                                break;
                              case 2:
                                playbackNavigationNavigationKey.currentState!
                                    .popUntil((route) => route.isFirst);
                                break;
                            }
                          } else {
                            setIndex(index);
                          }
                        },
                        items: const [
                          BottomNavigationBarItem(
                              icon: Icon(Icons.home_outlined),
                              activeIcon: Icon(Icons.home),
                              label: "ホーム",
                              tooltip: "新着アルバム・検索"),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.playlist_play_outlined),
                              activeIcon: Icon(Icons.playlist_play),
                              label: "プレイリスト",
                              tooltip: "プレイリストの編集・表示"),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.play_arrow_outlined),
                              activeIcon: Icon(Icons.play_arrow),
                              label: "再生",
                              tooltip: "音楽再生コントローラー・キューの確認"),
                          BottomNavigationBarItem(
                              icon: Icon(Icons.person_outlined),
                              activeIcon: Icon(Icons.person),
                              label: "アカウント",
                              tooltip: "アカウント情報の確認・ログアウト"),
                        ]),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
