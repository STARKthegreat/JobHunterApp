import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class YoutubeVideoViewWidget extends StatelessWidget {
  const YoutubeVideoViewWidget({super.key});
  @override
  Widget build(BuildContext context) {
    const viewID = 'youtube-video-view';
        // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        viewID,
            (int id) => html.IFrameElement()
          ..width = MediaQuery.of(context).size.width.toString()
          ..height = MediaQuery.of(context).size.height.toString()
          ..src = 'https://www.youtube.com/embed/YAP12Xz0hBU?si=0qUQBG1KWrhyn8oU'
          ..style.border = 'none');

    return const SizedBox(
      height: 500,
      child: HtmlElementView(
        viewType: viewID,
      ),
    );
  }
}