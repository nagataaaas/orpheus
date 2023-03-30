import 'package:flutter/material.dart';

import 'package:orpheus_client/Screens/main/home/navigation.dart';
import 'package:orpheus_client/styles.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:orpheus_client/Screens/main/account.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  static final _pages = [
    HomeNavigationScreen(
      navigatorKey: GlobalKey(),
    ),
    Text("bookmark"),
    Text("playback"),
    const AccountScreen(),
  ];
  late PageController _pageController;
  // static final _screens = [
  //   HomeScreen(),
  //   HomeScreen(),
  //   HomeScreen(),
  //   HomeScreen(),
  // ];

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        // body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              border: Border(
                  top: BorderSide(
                      color: Color.fromARGB(255, 202, 202, 202), width: 0.5))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GNav(
              onTabChange: (value) => setState(() {
                _selectedIndex = value;
                _pageController.jumpToPage(_selectedIndex);
                print(_selectedIndex);
              }),
              gap: 4,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              tabBackgroundColor: Color.fromARGB(255, 131, 131, 131),
              padding: EdgeInsets.all(16),
              color: Color.fromARGB(255, 126, 126, 126),
              activeColor: Color.fromARGB(255, 255, 255, 255),
              tabs: [
                GButton(
                    icon:
                        _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                    text: 'ホーム'),
                GButton(
                    icon: _selectedIndex == 1
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                    text: 'ブックマーク'),
                GButton(
                    icon: _selectedIndex == 2
                        ? Icons.play_arrow
                        : Icons.play_arrow_outlined,
                    text: '再生'),
                GButton(
                    icon: _selectedIndex == 3
                        ? Icons.person
                        : Icons.person_outlined,
                    text: 'アカウント'),
              ],
            ),
          ),
        ));
  }
}
