import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:animator/animator.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:qrscan_example/models/connection.dart';
import 'package:qrscan_example/models/data.dart';
import 'package:qrscan_example/models/server.dart';
import 'package:qrscan_example/pages/account_page.dart';
import 'package:qrscan_example/services/api.dart';
import 'package:qrscan_example/services/auth.dart';
import 'package:qrscan_example/utils/ad_manager.dart';
import 'package:qrscan_example/utils/utils.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AuthService appAuth = new AuthService();
  Future<dynamic> data;
  bool loading = true;

  bool loggedIn;
  final GlobalKey _menuKey = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final bgColorDisconnected = [Color(0xFF000000), Color(0xFFDD473D)];
  final bgColorConnected = [Color(0xFF000000), Color(0xFF37AC53)];
  final bgColorConnecting = [Color(0xFF000000), Color(0xFFCCAD00)];

  var state = FlutterVpnState.disconnected;
  List<Server> _allServers = new List<Server>();
  Server selectedSerever = null;
  bool flag = true;
  Stream<int> timerStream;
  StreamSubscription<int> timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  bool isLogged = false;
  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  Future<List<Connection>> _getServers() async {
    var response = await API.getServers();
    Iterable list = await json.decode(response.body);
    var connections = list.map((model) => Connection.fromJson(model)).toList();
    return connections;
  }

  BannerAd _bannerAd;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      size: AdSize.banner,
    );

    _bannerAd
      ..load()
      ..show(anchorType: AnchorType.bottom);
  }

  InterstitialAd myInterstitial;

  InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: AdManager.interstitialAdUnitId,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.failedToLoad) {
          myInterstitial..load();
        } else if (event == MobileAdEvent.closed) {
          myInterstitial = buildInterstitialAd()..load();
        }
        print(event);
      },
    );
  }

  void showInterstitialAd() {
    myInterstitial..show();
  }

  @override
  void initState() {
    setState(() {
      data = _getAccount();
    });

    FlutterVpn.prepare();
    FlutterVpn.onStateChanged.listen((s) {
      if (s == FlutterVpnState.connected) {
        // Device Connected
      }
      if (s == FlutterVpnState.disconnected) {
        // Device Disconnected
      }
      setState(() {
        state = s;
      });
    });

    // selectedSerever = _allServers.first;

    myInterstitial = buildInterstitialAd()..load();
    super.initState();
  }

  Future<dynamic> _getAccount() async {
    AuthService appAuth = new AuthService();
    String token = await AuthService.getToken();
    dynamic _res = await appAuth.login(token);

    if (_res == false) {
      _loadBannerAd();

      buildInterstitialAd();

      setState(() {
        isLogged = false;
      });
    } else {
      if (_bannerAd != null) {
        _bannerAd?.dispose();
      }
      setState(() {
        isLogged = true;
      });
    }
    setState(() {
      loading = false;
    });

    return _res;
  }

  @override
  void dispose() async {
    _bannerAd?.dispose();
    myInterstitial.dispose();
    super.dispose();
  }

  void connectVpn() {
    if (state == FlutterVpnState.connected) {
      if (isLogged == false) {
        showInterstitialAd();
      }
      FlutterVpn.disconnect();
      timerSubscription.cancel();
      timerStream = null;
      setState(() {
        hoursStr = '00';
        minutesStr = '00';
        secondsStr = '00';
      });
    } else {
      if (isLogged == false) {
        showInterstitialAd();
      }
      // RewardedVideoAd.instance.show();
      timerStream = stopWatchStream();
      timerSubscription = timerStream.listen((int newTick) {
        setState(() {
          hoursStr =
              ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
          minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
          secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
        });
      });
      FlutterVpn.simpleConnect("vpn.nessom.ir", "behzad", "1234@qwerB");
    }
  }

  void changeServer() {}

  void _showModalBottomSheet(BuildContext context) {
    gotoLogin();
  }

  Widget serverConnection(context) {
    return new GestureDetector(
      onTap: () {
        _showModalBottomSheet(context);
      },
      child: new Row(
        children: <Widget>[
          new Container(
            width: screenAwareSize(30.0, context),
            height: screenAwareSize(30.0, context),
            decoration: new BoxDecoration(
              // Circle shape
              // shape: BoxShape.circle,
              color: Colors.transparent,
              // The border you want
              // border: new Border.all(
              //   width: screenAwareSize(2.0, context),
              //   color: Colors.white,
              // ),
              // The shadow you want
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: (selectedSerever != null)
                      ? NetworkImage(selectedSerever.flag)
                      : AssetImage('assets/performance.png'),
                  // ...
                ),
                // ...
              ),
            ),
          ),
          SizedBox(width: screenAwareSize(10.0, context)),
          Text(
            (selectedSerever != null) ? selectedSerever.country : "AutoSelect",
            style: TextStyle(
                color: Colors.white, fontFamily: "Montserrat-SemiBold"),
          ),
          SizedBox(width: screenAwareSize(5.0, context)),
          Icon(Icons.arrow_drop_up, color: Colors.white)
        ],
      ),
    );
  }

  Widget buildUi(BuildContext context) {
    if (state == FlutterVpnState.connected) {
      //bağlı
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (loading == true) ? CircularProgressIndicator() : topArea(),
              SizedBox(
                height: 35,
              ),
              Text(
                "TAP TO\nTURN OFF VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.green,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  "$hoursStr:$minutesStr:$secondsStr",
                  style: TextStyle(fontSize: 25.0, color: Colors.white),
                ),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else if (state == FlutterVpnState.connecting) {
      // bağlanıyor
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Animator(
                duration: Duration(seconds: 2),
                repeats: 0,
                builder: (anim) => FadeTransition(
                  opacity: anim,
                  child: Text(
                    "CONNECTING",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Montserrat-SemiBold",
                        fontSize: 20.0),
                  ),
                ),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SpinKitRipple(
                color: Colors.white,
                size: 190.0,
              ),
              SizedBox(height: screenAwareSize(50.0, context)),
              // serverConnection(context),
              SizedBox(height: screenAwareSize(30.0, context)),
              Text(
                "CONNECTING VPN SERVER",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 12.0),
              ),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    } else {
      // bağlı değil
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (loading == true) ? CircularProgressIndicator() : topArea(),
              SizedBox(
                height: 35,
              ),
              Text(
                "TAP TO\nTURN ON VPN",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Montserrat-SemiBold",
                    fontSize: 16.0),
              ),
              SizedBox(height: screenAwareSize(15.0, context)),
              SizedBox(
                width: screenAwareSize(130.0, context),
                height: screenAwareSize(130.0, context),
                child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onPressed: connectVpn,
                  child: new Icon(Icons.power_settings_new,
                      color: Colors.green,
                      size: screenAwareSize(100.0, context)),
                ),
              ),
              SizedBox(height: screenAwareSize(40.0, context)),
              serverConnection(context),
              // RaisedButton(
              //     onPressed: () {
              //       _displayDialog(context);
              //     },
              //     child: (selectedSerever.id == 0)
              //         ? defaultServer(context)
              //         : otherServer(context, selectedSerever)),
              SizedBox(height: screenAwareSize(30.0, context)),
            ],
          ))
        ],
      );
    }
  }

  Widget LoginPage() {
    return new Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        // image: new DecorationImage(
        //   image: new AssetImage("assets/map-pattern.png"),
        //   fit: BoxFit.contain,
        // ),
      ),
      child: FutureBuilder(
        future: _getServers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return new Text('loading...');
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else
                return createListView(context, snapshot);
          }
        },
      ),
    );
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List<Connection> values = snapshot.data;
    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        Connection connection = values[index];
        List<Server> servers = connection.servers;
        return new Column(
          children: <Widget>[
            Container(
                child: Column(
              children: [
                (index == 0)
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSerever = null;
                            gotoMain();
                          });
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            margin: EdgeInsets.symmetric(vertical: 2),
                            // decoration: BoxDecoration(
                            //     border: Border.all(
                            //   color: Colors.grey[200],
                            // )),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/performance.png',
                                  width: 35,
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(child: Text("AutoSelect")),
                                SizedBox(
                                  width: 15,
                                )
                              ],
                            )))
                    : SizedBox(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Center(child: Text(connection.region)),
                ),
                serverList(servers)
              ],
            )),
            new Divider(
              height: 2.0,
            ),
          ],
        );
      },
    );
  }

  Widget serverList(List<Server> servers) {
    return new Column(
        children: servers
            .map((item) => new GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSerever = item;
                    gotoMain();
                  });
                },
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    margin: EdgeInsets.symmetric(vertical: 2),
                    // decoration: BoxDecoration(
                    //     border: Border.all(
                    //   color: Colors.grey[200],
                    // )),
                    child: Row(
                      children: [
                        Image.network(
                          item.flag,
                          width: 35,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(child: Text(item.country)),
                        Row(children: [
                          Image.asset(
                            "assets/connection.png",
                            width: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("121"),
                        ]),
                        SizedBox(
                          width: 15,
                        )
                      ],
                    ))))
            .toList());
  }

  gotoLogin() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(
      1,
      duration: Duration(milliseconds: 400),
      curve: Curves.bounceOut,
    );
  }

  gotoMain() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 400),
      curve: Curves.bounceOut,
    );
  }

  PageController _controller =
      new PageController(initialPage: 0, viewportFraction: 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/map-pattern.png"),
            fit: BoxFit.contain,
          ),
          gradient: LinearGradient(
              colors: state == FlutterVpnState.connected
                  ? bgColorConnected
                  : (state == FlutterVpnState.connecting
                      ? bgColorConnecting
                      : bgColorDisconnected),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              tileMode: TileMode.clamp)),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          // drawer: MainDrawer(),
          appBar: AppBar(
            iconTheme: new IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  final result = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AccountPage()));

                  setState(() {
                    data = _getAccount();
                  });
                },
              )
            ],
            elevation: 0.0,
            title: Text("MyVPN",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: screenAwareSize(18.0, context),
                    fontFamily: "Montserrat-Bold")),
            centerTitle: true,
          ),
          body: PageView(
            controller: _controller,
            physics: new AlwaysScrollableScrollPhysics(),
            children: <Widget>[buildUi(context), LoginPage()],
            scrollDirection: Axis.horizontal,
          )),
    );
  }

  FutureBuilder topArea() => FutureBuilder<dynamic>(
        future: data,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == false) {
              return Container(
                  padding: EdgeInsets.all(5.0),
                  // color: Color(0xFF015FFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Text("Trial Account",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Montserrat-SemiBold",
                              fontSize: 12.0)),
                    ],
                  ));
            } else {
              Data acc = snapshot.data;
              return Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  // color: Color(0xFF015FFF),
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          Text("Welcome Back ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Montserrat-SemiBold",
                                  fontSize: 12.0)),
                          Text(acc.customer,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Montserrat-SemiBold",
                                  fontSize: 14.0)),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      )));
            }
          } else {
            return Container(
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
      );
}
