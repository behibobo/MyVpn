import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qrscan_example/pages/main_page.dart';
import 'package:qrscan_example/pages/notfound/notfound_page.dart';
import 'package:qrscan_example/splash_screen.dart';
import 'package:qrscan_example/utils/init.dart';

class App extends StatelessWidget {
  final Future _initFuture = Init.initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "MyVPN - Unlimited, A Fast, Free VPN Proxy",
        theme: ThemeData(
            primaryColor: Colors.blue[600], primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        home: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return MainPage();
            } else {
              return SplashScreen();
            }
          },
        ),
        routes: <String, WidgetBuilder>{},
        onUnknownRoute: (RouteSettings rs) =>
            new MaterialPageRoute(builder: (context) => new NotFoundPage()));
    ;
  }
}
