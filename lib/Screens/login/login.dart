import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:orpheus_client/storage/credentials.dart' as credentials;
import '../../components/login_backgorund.dart';
import 'package:orpheus_client/styles.dart' as styles;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:orpheus_client/api/auth.dart' as auth;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;
  bool rememberMe = false;

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    credentials.RememberMe.get().then((value) {
      if (value) {
        setState(() {
          credentials.readFromStorage();
          rememberMe = true;
        });
      }
    });
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isLoading = false;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Background(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                  child: SizedBox(
                    height: size.height,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.bottomCenter,
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text(
                                  //   "Orpheus Client へ ようこそ",
                                  //   style: TextStyle(
                                  //       fontWeight: FontWeight.bold,
                                  //       fontSize: 16,
                                  //       color: styles.CommonColors.primaryTextColor),
                                  // ),
                                  Text(
                                    "Login to NML",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 36,
                                        color: styles
                                            .CommonColors.secondaryTextColor),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 50),
                                    child: RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: "ログインすることによって、本アプリの",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: styles.CommonColors
                                                  .secondaryTextColor)),
                                      TextSpan(
                                        text: "利用規約",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: styles
                                                .CommonColors.linkTextColor),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => showDialogueModal(
                                              context,
                                              "assets/dialogue/terms_of_service.md"),
                                      ),
                                      TextSpan(
                                          text: "と",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: styles.CommonColors
                                                  .secondaryTextColor)),
                                      TextSpan(
                                        text: "プライバシーポリシー",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: styles
                                                .CommonColors.linkTextColor),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => showDialogueModal(
                                              context,
                                              "assets/dialogue/privacy_policy.md"),
                                      ),
                                      TextSpan(
                                          text: "に同意したものとみなされます。",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: styles.CommonColors
                                                  .secondaryTextColor)),
                                    ])),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      "※ 本アプリの利用には、日本語版Naxos Music Libraryのアカウントが必要です。",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: styles
                                              .CommonColors.secondaryTextColor),
                                    ),
                                  ),
                                  // username textfield using TextEditingController usernameController
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: TextField(
                                      onTapOutside: (event) => {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus()
                                      },
                                      controller:
                                          credentials.usernameController,
                                      style: TextStyle(
                                          color: styles
                                              .CommonColors.secondaryTextColor),
                                      decoration: InputDecoration(
                                        labelText: "ユーザー名",
                                        fillColor: styles
                                            .CommonColors.secondaryTextColor,
                                        labelStyle: TextStyle(
                                            color: styles.CommonColors
                                                .secondaryTextColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: styles.CommonColors
                                                  .primaryThemeColor),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: styles.CommonColors
                                                  .primaryThemeColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // password textfield using TextEditingController passwordController with obscureText and show/hide password button
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    child: TextField(
                                      onTapOutside: (event) => {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus()
                                      },
                                      controller:
                                          credentials.passwordController,
                                      style: TextStyle(
                                          color: styles
                                              .CommonColors.secondaryTextColor),
                                      obscureText: obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: "パスワード",
                                        fillColor: styles
                                            .CommonColors.secondaryTextColor,
                                        labelStyle: TextStyle(
                                            color: styles.CommonColors
                                                .secondaryTextColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: styles.CommonColors
                                                  .primaryThemeColor),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: styles.CommonColors
                                                  .primaryThemeColor),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            obscurePassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: styles
                                                .CommonColors.primaryThemeColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              obscurePassword =
                                                  !obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    // remember me checkbox
                                  ),
                                  CheckboxListTile(
                                    contentPadding:
                                        const EdgeInsets.only(left: -30),
                                    activeColor: styles
                                        .CommonColors.primaryThemeAccentColor,
                                    // white border and blue checkmark on checked
                                    checkColor:
                                        styles.CommonColors.primaryThemeColor,
                                    side: BorderSide(
                                        color: styles
                                            .CommonColors.primaryThemeColor,
                                        width: 1),
                                    title: Text(
                                      "Remember me",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: styles
                                              .CommonColors.secondaryTextColor),
                                    ),
                                    value: rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        rememberMe = value!;
                                      });
                                    },
                                  ),
                                  // full width login button
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    width: size.width,
                                    child: isLoading
                                        ? const CircularProgressIndicator()
                                        : ElevatedButton(
                                            onPressed: () async {
                                              var username = credentials
                                                  .usernameController.text;
                                              var password = credentials
                                                  .passwordController.text;

                                              if (username.isEmpty ||
                                                  password.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      "ユーザー名とパスワードを入力してください。"),
                                                  backgroundColor: Colors.red,
                                                ));
                                                return;
                                              }
                                              await credentials.RememberMe.set(
                                                  rememberMe);
                                              if (rememberMe) {
                                                await credentials.UserName.set(
                                                    username);
                                                await credentials.Password.set(
                                                    password);
                                              }
                                              // show loading indicator while
                                              setState(() {
                                                isLoading = true;
                                              });

                                              bool result =
                                                  await auth.Auth.login(
                                                      username, password);
                                              setState(() {
                                                isLoading = true;
                                              });

                                              if (result) {
                                                if (!mounted) return;
                                                Navigator.pushReplacementNamed(
                                                    context, "/navigation");
                                              } else {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      "ユーザー名またはパスワードが間違っています"),
                                                  backgroundColor: Colors.red,
                                                ));
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: styles
                                                  .CommonColors
                                                  .primaryThemeAccentColor,
                                              foregroundColor: styles
                                                  .CommonColors
                                                  .primaryTextColor,
                                              fixedSize:
                                                  const Size.fromHeight(50),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text("LOGIN",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: styles.CommonColors
                                                        .primaryThemeColor)),
                                          ),
                                  ),
                                ]),
                          ),
                        ]),
                  ),
                ))));
  }
}

void showDialogueModal(context, filePath) {
  showModalBottomSheet<void>(
    backgroundColor: styles.CommonColors.primaryTextColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        widthFactor: 0.9,
        child: Column(
          children: [
            // close button on right top

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                    color: styles.CommonColors.secondaryThemeDarkColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(top: 10),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // terms of service
            Expanded(
                child: FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 150))
                        .then((value) {
                      return rootBundle.loadString(filePath);
                    }),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Markdown(
                          data: snapshot.data!,
                        );
                      }
                      return const Center(child: CupertinoActivityIndicator());
                    })),
          ],
        ),
      );
    },
  );
}
