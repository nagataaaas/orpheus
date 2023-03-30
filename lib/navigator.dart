import 'package:flutter/cupertino.dart';

class MyCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  MyCupertinoPageRoute(
      {required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration => const Duration(seconds: 0);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);
}
