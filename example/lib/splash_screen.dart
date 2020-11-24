import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("MyVPN"),
          SizedBox(
            height: 30,
          ),
          CircularProgressIndicator(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
