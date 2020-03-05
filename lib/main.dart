import 'package:flutter/material.dart';

import 'pages/index/index.dart';

void main() => runApp(new ZhiHu());

class ZhiHu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "勐拉生活网",
      home: new Index(),
    );
  }
}
