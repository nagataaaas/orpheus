import 'package:flutter/material.dart';
import 'package:orpheus_client/navigator.dart';
import 'package:orpheus_client/storage/search_history.dart';
import 'package:orpheus_client/Screens/main/home/search_result.dart';
import 'package:orpheus_client/styles.dart';

class HomeSearchArguments {
  final String searchText;
  HomeSearchArguments(this.searchText);
}

List<InputHistoryData> filterHistory(
    String? query, List<InputHistoryData> histories) {
  if (query == null || query.trim().isEmpty) {
    return histories;
  }
  final queries = query.toLowerCase().split(RegExp(r"\s+"));
  return histories.where((history) {
    return queries.every((query) {
      return history.value.toLowerCase().contains(query);
    });
  }).toList();
}

class HomeSearchScreen extends StatefulWidget {
  final HomeSearchArguments? arguments;
  const HomeSearchScreen({super.key, this.arguments});

  @override
  _HomeSearchScreenState createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  List<InputHistoryData> history = [];
  List<InputHistoryData> filteredHistory = [];

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
            filteredHistory =
                filterHistory(_searchTextController.text, history),
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
              SliverAppBar(
                backgroundColor: CommonColors.primaryThemeDarkColor,
                centerTitle: true,
                // search text input in title
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding:
                        const EdgeInsets.only(left: 40, bottom: 7, right: 10),
                    title: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: CommonColors.secondaryThemeDarkColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Focus(
                          onFocusChange: (value) {
                            if (value) {
                              setState(() {
                                SearchHistory.get().then((value) => {
                                      history = value,
                                      filteredHistory = filterHistory(
                                          _searchTextController.text, history),
                                    });
                              });
                            }
                          },
                          child: TextFormField(
                            style: TextStyle(
                              color: CommonColors.secondaryTextColor,
                            ),
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
                                fillColor: CommonColors.secondaryThemeDarkColor,
                                hintText: "曲名・人名・アルバム名",
                                hintStyle: TextStyle(
                                  color: CommonColors.secondaryTextColor,
                                ),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      _searchTextController.clear();
                                      setState(() {
                                        filteredHistory = filterHistory(
                                            _searchTextController.text,
                                            history);
                                      });
                                    },
                                    child: Icon(Icons.clear,
                                        color:
                                            CommonColors.primaryThemeColor))),
                            onChanged: (value) {
                              setState(() {
                                filteredHistory = filterHistory(
                                    _searchTextController.text, history);
                              });
                            },
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
                            },
                          ),
                        ),
                      ),
                    )),
                pinned: true,
                shape: Border(
                    bottom: BorderSide(
                        color: CommonColors.secondaryThemeDarkColor, width: 1)),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: CommonColors.primaryThemeColor),
                    onPressed: () => Navigator.pop(context)),
              )
            ],
        body: Scrollbar(
          child: Container(
            color: CommonColors.primaryThemeDarkColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...filterHistory(_searchTextController.text, history).map((e) =>
                    Dismissible(
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
                        setState(() {
                          SearchHistory.removeKey(e);
                          SearchHistory.get().then((value) => {
                                history = value,
                              });
                        });
                      },
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            Icons.history,
                            color: CommonColors.secondaryTextColor,
                          ),
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
                        title: Text(
                          e.value,
                          style:
                              TextStyle(color: CommonColors.secondaryTextColor),
                        ),
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
                          color: CommonColors.secondaryTextColor,
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
