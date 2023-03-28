import 'package:flutter/cupertino.dart';

class MyCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  MyCupertinoPageRoute(
      {required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);

  // 次の画面に進む処理
  @override
  Duration get transitionDuration => const Duration(seconds: 0);

  // 前の画面に戻る処理
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);
}
