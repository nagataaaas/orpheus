// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:orpheus_client/api/auth.dart';

Future<bool> asyncMain() async {
  print(await Auth.login('2541_gt421', 'gCiY72UJ'));
  return true;
}

void main() {
  print("start");
  asyncMain().then((val) => {});
}
