import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:orpheus_client/components/skelton_text.dart';

class AlbumDescription extends StatelessWidget {
  final String? title;
  final String? label;
  final Future<dynamic> Function() onTapAction;

  const AlbumDescription({
    Key? key,
    required this.title,
    required this.label,
    required this.onTapAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black87,
              ],
              stops: [
                0.00022,
                1.0,
              ]),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTapAction,
                child: Column(
                  children: [
                    title == null
                        ? SkeletonText(height: 28, width: size.width * 0.8)
                        : Text(title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        label == null
                            ? SkeletonText(height: 28, width: size.width * 0.8)
                            : Text(
                                "Provider: ${(jsonDecode(label!)?['description'] ?? "Unknown Label")}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        // TODO: create bookmark
                        Icons.bookmark_add_outlined,
                        color: Colors.white,
                      )),
                  Container(
                    width: 15,
                  ),
                  // tap to open description icon
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
