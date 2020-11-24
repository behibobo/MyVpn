import 'dart:developer';

import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140.0,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            buildMenuItem(Icons.account_balance, "ACCOUNT",
                opacity: 1.0, color: Color(0xFF015FFF)),
            Divider(),
            buildMenuItem(Icons.history, "PAYMENT HISTORY"),
            Divider(),
            buildMenuItem(Icons.settings, "SETTING"),
            Divider(),
            buildMenuItem(Icons.info, "ABOUT US"),
            Divider(),
          ],
        ),
      ),
    );
  }

  FlatButton buildMenuItem(IconData icon, String title,
      {double opacity = 1, Color color = Colors.black}) {
    return FlatButton(
        onPressed: () {
          log("here");
        },
        child: Opacity(
          opacity: opacity,
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Icon(
                  icon,
                  size: 25.0,
                  color: color,
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.0,
                        color: color)),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ));
  }
}
