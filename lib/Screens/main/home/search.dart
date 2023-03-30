import 'package:flutter/material.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:orpheus_client/storage/search_history.dart';
import 'package:orpheus_client/Screens/main/home/search_result.dart';

class HomeSearchArguments {
  final String searchText;
  HomeSearchArguments(this.searchText);
}

class HomeSearchScreen extends StatefulWidget {
  final HomeSearchArguments? arguments;
  const HomeSearchScreen({super.key, this.arguments});

  @override
  _HomeSearchScreenState createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  List<InputHistoryData> history = [];

  late TextEditingController _searchTextController;

  @override
  void initState() {
    super.initState();
    _searchTextController = TextEditingController();
    setState(() {
      if (widget.arguments != null) {
        _searchTextController.text = widget.arguments!.searchText;
      }
      SearchHistory.get().then((value) => {
            history = value,
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
              SliverAppBar(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                centerTitle: true,
                // search text input in title
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding:
                        const EdgeInsets.only(left: 40, bottom: 7, right: 10),
                    title: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 231, 231, 231),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Focus(
                          onFocusChange: (value) {
                            if (value) {
                              setState(() {
                                SearchHistory.get().then((value) => {
                                      history = value,
                                    });
                              });
                            }
                          },
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              if (RegExp(r'^[ 　]+$').hasMatch(value)) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: _searchTextController,
                            autofocus: true,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "曲名・人名・アルバム名",
                                suffixIcon: GestureDetector(
                                    onTap: () =>
                                        {_searchTextController.clear()},
                                    child: const Icon(Icons.clear,
                                        color: Colors.black))),
                            onFieldSubmitted: (value) {
                              if (history
                                  .any((element) => element.value == value)) {
                                SearchHistory.touch(InputHistoryData(
                                    value: value, createdAt: DateTime.now()));
                              } else {
                                SearchHistory.add(value);
                              }
                              SearchHistory.add(value);
                              setState(() {
                                SearchHistory.get().then((value) => {
                                      history = value,
                                    });
                              });
                              Navigator.of(context).pushReplacement(
                                MyCupertinoPageRoute(
                                    builder: (context) =>
                                        HomeSearchResultScreen(
                                            arguments:
                                                HomeSearchResultArguments(
                                                    value)),
                                    settings: const RouteSettings(
                                        name: '/home/search/result')),
                              );
                              // Navigator.pushNamed(context, '/search', arguments: value);
                            },
                          ),
                        ),
                      ),
                    )),
                pinned: true,
                shape: const Border(
                    bottom: BorderSide(
                        color: Color.fromARGB(255, 231, 231, 231), width: 1)),
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context)),
              )
            ],
        body: Scrollbar(
          child: Material(
            child: ListView(
              children: [
                ...history.map((e) => Dismissible(
                      key: ObjectKey(e),
                      background: Container(
                        padding: const EdgeInsets.only(
                          right: 10,
                        ),
                        alignment: AlignmentDirectional.centerEnd,
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // スワイプ後に実行される（削除処理などを書く）
                        setState(() {
                          SearchHistory.removeKey(e);
                          SearchHistory.get().then((value) => {
                                history = value,
                              });
                        });
                      },
                      child: ListTile(
                        leading: IconButton(
                          icon: const Icon(Icons.history),
                          onPressed: () {
                            setState(() {
                              SearchHistory.touch(e);
                              Navigator.of(context).pushReplacement(
                                MyCupertinoPageRoute(
                                    builder: (context) =>
                                        HomeSearchResultScreen(
                                            arguments:
                                                HomeSearchResultArguments(
                                                    e.value)),
                                    settings: const RouteSettings(
                                        name: '/home/search/result')),
                              );
                            });
                          },
                        ),
                        title: Text(e.value),
                        onTap: () {
                          SearchHistory.touch(e);
                          Navigator.of(context).pushReplacement(
                            MyCupertinoPageRoute(
                                builder: (context) => HomeSearchResultScreen(
                                    arguments:
                                        HomeSearchResultArguments(e.value)),
                                settings: const RouteSettings(
                                    name: '/home/search/result')),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.north_west),
                          onPressed: () {
                            final String text = " ${e.value} ";
                            _searchTextController.text =
                                text; // history and space
                            _searchTextController.selection =
                                TextSelection.collapsed(offset: text.length);
                          },
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}
