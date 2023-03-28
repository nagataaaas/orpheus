import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double imagWidth;
    if (size.width > size.height) {
      // background image is 16:9
      // and make this image a little bit bigger to half of the screen
      imagWidth = size.height.toDouble() * (16 / 9) * 0.6;
    } else {
      imagWidth = size.width.toDouble();
    }
    return Container(
      height: size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF05121A),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "assets/login/background.png",
              width: imagWidth,
              alignment: Alignment.bottomRight,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
