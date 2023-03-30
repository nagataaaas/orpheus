import 'package:flutter/material.dart';
import 'package:orpheus_client/storage/credentials.dart' as credentials;
import 'package:intl/intl.dart';

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

    return FutureBuilder(
      future: fetchUserInfo(),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("アカウント"),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
          shape: const Border(
              bottom: BorderSide(
                  color: Color.fromARGB(255, 231, 231, 231), width: 1)),
        ),
        body: !snapshot.hasData
            ? const CircularProgressIndicator()
            : SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("サブスクリプション",
                              style: TextStyle(fontSize: 14)),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("ユーザ名",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text(snapshot.data!.first ?? "Unknown",
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("有効期限",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      (snapshot.data!.second != null)
                                          ? DateFormat('yyyy/MM/dd HH:mm:ss')
                                              .format(snapshot.data!.second!
                                                  .toLocal())
                                          : "",
                                      style: const TextStyle(fontSize: 16)),
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
                                                      '/login',
                                                      (route) => false);
                                            });
                                          },
                                          child: const Text("ログアウト"))
                                    ],
                                  ));
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size(size.width, 60),
                          foregroundColor:
                              const Color.fromARGB(255, 230, 72, 60),
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                        ),
                        child: const Text("ログアウト",
                            style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 230, 72, 60),
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
      ),
    );
  }
}
