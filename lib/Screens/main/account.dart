import 'package:flutter/material.dart';
import 'package:orpheus_client/storage/credentials.dart' as credentials;
import 'package:intl/intl.dart';
import 'package:orpheus_client/styles.dart';

class Tuple2<T1, T2> {
  final T1 first;
  final T2 second;

  Tuple2({
    required this.first,
    required this.second,
  });
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<Tuple2<String?, DateTime?>> fetchUserInfo() async {
    return Tuple2<String?, DateTime?>(
        first: await credentials.Subscriber.get(),
        second: await credentials.SubscriptionExpiresAt.get());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "アカウント",
        ),
        backgroundColor: CommonColors.primaryThemeDarkColor,
        centerTitle: true,
        titleTextStyle:
            TextStyle(color: CommonColors.secondaryTextColor, fontSize: 20),
        shape: Border(
            bottom: BorderSide(
                color: CommonColors.secondaryThemeDarkColor, width: 1)),
      ),
      body: FutureBuilder(
        future: fetchUserInfo(),
        builder: (context, snapshot) => Container(
          decoration: BoxDecoration(color: CommonColors.primaryThemeDarkColor),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("サブスクリプション",
                          style: TextStyle(
                              fontSize: 14,
                              color: CommonColors.secondaryTextColor)),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("ユーザ名",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CommonColors.secondaryTextColor)),
                              Text(snapshot.data?.first ?? "Unknown",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: CommonColors.secondaryTextColor)),
                            ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("有効期限",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CommonColors.secondaryTextColor)),
                              Text(
                                  (snapshot.data?.second != null)
                                      ? DateFormat('yyyy/MM/dd HH:mm:ss')
                                          .format(
                                              snapshot.data!.second!.toLocal())
                                      : "",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: CommonColors.secondaryTextColor)),
                            ]),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 30),
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("ログアウトしますか？"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("キャンセル")),
                                  TextButton(
                                      onPressed: () {
                                        credentials
                                            .clearCredentials()
                                            .then((_) {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pushNamedAndRemoveUntil(
                                                  '/login', (route) => false);
                                        });
                                      },
                                      child: const Text("ログアウト"))
                                ],
                              ));
                    },
                    style: TextButton.styleFrom(
                      fixedSize: Size(size.width, 60),
                      foregroundColor: CommonColors.dangerColor,
                      padding: const EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text("ログアウト",
                        style: TextStyle(
                            fontSize: 20,
                            color: CommonColors.dangerColor,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
