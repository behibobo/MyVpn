import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:qrscan/qrscan.dart' as scanner;
import 'package:qrscan_example/models/data.dart';
import 'package:qrscan_example/services/auth.dart';
import 'package:qrscan_example/widgets/app_drawer.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<AccountPage> {
  String accountCode = "";
  Future<dynamic> data;
  bool loading = true;

  @override
  void initState() {
    setState(() {
      data = _getAccount();
    });
    super.initState();
  }

  Future<dynamic> _getAccount() async {
    AuthService appAuth = new AuthService();
    String token = await AuthService.getToken();
    var _res = await appAuth.login(token);
    setState(() {
      loading = false;
    });
    return _res;
  }

  _scan() async {
    try {
      String barcode = await scanner.scan();
      if (barcode != "") {
        setState(() {
          loading = true;
        });
        AuthService.storeUserData(barcode);
        setState(() {
          data = _getAccount();
        });
      }
    } on Exception catch (_) {
      // do something on error.
    }
  }

  _setAccoutCode() {
    if (accountCode != "") {
      setState(() {
        loading = true;
      });
      AuthService.storeUserData(accountCode);
      setState(() {
        data = _getAccount();
      });
    }
  }

  Card topArea() => Card(
      margin: EdgeInsets.all(10.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50.0))),
      child: FutureBuilder<dynamic>(
        future: data,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == false) {
              return Container(
                  height: 150,
                  decoration: BoxDecoration(
                      gradient: RadialGradient(
                          colors: [Color(0xFF015FFF), Color(0xFF015FFF)])),
                  padding: EdgeInsets.all(5.0),
                  // color: Color(0xFF015FFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text("Trial Account",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 24.0)),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text("Buy Premuim Account",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 17.0)),
                        ),
                      ),
                    ],
                  ));
            } else {
              Data acc = snapshot.data;
              return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: RadialGradient(
                          colors: [Color(0xFF015FFF), Color(0xFF015FFF)])),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  // color: Color(0xFF015FFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: SvgPicture.asset(
                          "assets/verified_user.svg",
                          color: Colors.white,
                          matchTextDirection: true,
                          width: 50,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                          child: Text(
                        acc.customer,
                        style: TextStyle(color: Colors.white),
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                          child: Text(
                        acc.remainingDays.toString() + " left",
                        style: TextStyle(color: Colors.white),
                      )),
                      SizedBox(height: 15.0),
                    ],
                  ));
            }
          } else {
            return Container(
                height: 150,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                        colors: [Color(0xFF015FFF), Color(0xFF015FFF)])),
                padding: EdgeInsets.all(5.0),
                // color: Color(0xFF015FFF),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ],
                ));
          }
        },
      ));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue, //change your color here
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Text(
            "Accounts",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              (loading == true) ? loadingDisplay() : topArea(),
              Text("Scan Account QRCode"),
              GestureDetector(
                onTap: _scan,
                child: Image.asset(
                  'assets/scanner.png',
                  width: 55,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              RaisedButton(
                  child: Text(
                    "Or Manually Enter The Code",
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    showMenu(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadingDisplay() {
    return Card(
        margin: EdgeInsets.all(10.0),
        elevation: 1.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0))),
        child: Container(
            height: 150,
            decoration: BoxDecoration(
                gradient: RadialGradient(
                    colors: [Color(0xFF015FFF), Color(0xFF015FFF)])),
            padding: EdgeInsets.all(5.0),
            // color: Color(0xFF015FFF),
            child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            )));
  }

  showMenu(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 0.5,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    onChanged: (code) {
                      setState(() {
                        accountCode = code;
                      });
                    },
                    autofocus: false,
                    style: TextStyle(fontSize: 15.0, color: Colors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Username',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.only(
                          left: 14.0, bottom: 6.0, top: 8.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[200]),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.green,
                        onPressed: () {
                          if (accountCode != "") {
                            _setAccoutCode();
                          }
                        },
                        child: Text(
                          'Activate Account',
                          style: TextStyle(color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.green)),
                      ),
                    )),
              ],
            ),
          );
        });
  }

  Container accountItems(
          String item, String charge, String dateString, String type,
          {Color oddColour = Colors.white}) =>
      Container(
        decoration: BoxDecoration(color: oddColour),
        padding:
            EdgeInsets.only(top: 20.0, bottom: 20.0, left: 5.0, right: 5.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(item, style: TextStyle(fontSize: 16.0)),
                Text(charge, style: TextStyle(fontSize: 16.0))
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(dateString,
                    style: TextStyle(color: Colors.grey, fontSize: 14.0)),
                Text(type, style: TextStyle(color: Colors.grey, fontSize: 14.0))
              ],
            ),
          ],
        ),
      );

  displayAccoutList() {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          accountItems("Trevello App", r"+ $ 4,946.00", "28-04-16", "credit",
              oddColour: const Color(0xFFF7F7F9)),
          accountItems(
              "Creative Studios", r"+ $ 5,428.00", "26-04-16", "credit"),
          accountItems("Amazon EU", r"+ $ 746.00", "25-04-216", "Payment",
              oddColour: const Color(0xFFF7F7F9)),
          accountItems(
              "Creative Studios", r"+ $ 14,526.00", "16-04-16", "Payment"),
          accountItems(
              "Book Hub Society", r"+ $ 2,876.00", "04-04-16", "Credit",
              oddColour: const Color(0xFFF7F7F9)),
        ],
      ),
    );
  }
}
