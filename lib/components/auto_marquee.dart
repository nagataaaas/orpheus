import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:orpheus_client/styles.dart';

SizedBox buildAutoMarquee(String text, double maxWidth) {
  return SizedBox(
    height: 45,
    width: maxWidth,
    child: Align(
      alignment: Alignment.centerLeft,
      child: AutoSizeText(
        text,
        maxLines: 2,
        style: TextStyle(color: CommonColors.tertiaryTextColor, fontSize: 14),
        overflowReplacement: Marquee(
          text: text,
          style: TextStyle(color: CommonColors.tertiaryTextColor, fontSize: 14),
          velocity: 30,
          startAfter: const Duration(seconds: 2),
          pauseAfterRound: const Duration(seconds: 1),
          blankSpace: 100,
          fadingEdgeStartFraction: 0,
          fadingEdgeEndFraction: 0,
        ),
      ),
    ),
  );
}
