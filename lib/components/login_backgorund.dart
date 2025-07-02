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

    final imagWidth = size.height.toDouble() * 0.25;

    return Container(
      height: size.height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF9F844B),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: (imagWidth * 1.5) * -0.3,
            left: 0,
            child: Transform.scale(
              scaleX: -1,
              child: Image.asset(
                "assets/login/background2.png",
                width: imagWidth,
                alignment: Alignment.bottomRight,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
