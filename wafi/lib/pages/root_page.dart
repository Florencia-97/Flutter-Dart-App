import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/login/login_signuo_page.dart';
import 'package:wafi/model/requested_order.dart';
import 'package:wafi/pages/main_menu.dart';

import 'chat_page.dart';
import 'my_orders_page.dart';

class RootPage extends StatefulWidget {
  RootPage();

  final BaseAuth auth = new Auth();
  final DataBaseController db = FirebaseController();
  final FirebaseMessaging fM = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin fLNP = new FlutterLocalNotificationsPlugin();

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

// |||| get auta here
class UserStatus {
  static final UserStatus _singleton = UserStatus._internal();

  static String __userId;

  static String getUserId() {
    return __userId;
  }

  static void setUserId(String uid) {
    __userId = uid;
  }

  static void unSetUserId() {
    __userId = null;
  }


  factory UserStatus() {
    return _singleton;
  }

  UserStatus._internal();
}


class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED; // !!!! pass to UserStatus
  // |||| remove this from here
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.fM.configure(onLaunch: (Map<String, dynamic> msg) {
      print(" onLaunch called ${msg}");
      showNotification(msg);
      
    }, onResume: (Map<String, dynamic> msg) {
      print( " onResume called ${msg}");
      showNotification(msg);
      
    }, onMessage: (Map<String, dynamic> msg) {
      print( " onMessage called ${msg}");
      showNotification(msg);
    });
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
      widget.fM.getToken().then((token) {
        update(user?.uid,token);
      });
    });
    initLocalNotifications();
  }

  update(String userId, String token) {
    widget.db.setToken(userId, token);
  }

  initLocalNotifications() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher'); 
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    widget.fLNP.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    Map<String, dynamic> data = jsonDecode(payload);
    print(data);

    switch(data["type"]){
      case "ORDER_TAKEN_NOTIFICATION":
        {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrders(_userId, selectedTab:1)));
        }
        break;
    
      case "ORDER_FINISHED_NOTIFICATION":
        {
          //TODO: Add finished orders tab in my orders page
          //await Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrders(_userId)));
        }
        break;
      
      case "CHAT_NOTIFICATION":
        {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(_userId, RequestedOrder.fromMap(data["id"], data["requestedUserId"], data))));
        }
      
    }
}

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'Dont know 1',
      "Dont know 2",
      "Dont know 3",
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker'
    );
    print('msg es');
    print(msg);
    String payload = jsonEncode(msg["data"]);
    print(payload);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await widget.fLNP.show(
        0, msg["notification"]["title"], msg["notification"]["body"], platform, payload: payload);
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user){
      setState(() {
        _userId = user.uid.toString();
      });
      widget.fM.getToken().then((token) {
        update(user.uid.toString()
        ,token);
      });
    });
    setState(() {
      UserStatus.setUserId(_userId);
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onLoggedOut() {
    widget.fM.getToken().then((token) {
        widget.db.removeToken(_userId, token);
      });
    setState(() {
      Future<void> signedOutF = widget.auth.signOut();
      signedOutF.then((aVoid) {
        UserStatus.unSetUserId();
        authStatus = AuthStatus.NOT_LOGGED_IN;
        _userId = "";
      });
    });
    
    
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return MainMenuPage(
            auth: widget.auth,
            onLoggedOut: _onLoggedOut
          );
        } else return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}