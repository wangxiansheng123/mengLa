import 'package:flutter/material.dart';
import '../../utils/global_config.dart';

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => new _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('消息'),
        ),
        body: new Center(child: null),
      ),
      theme: GlobalConfig.themeData,
    );
  }
}
