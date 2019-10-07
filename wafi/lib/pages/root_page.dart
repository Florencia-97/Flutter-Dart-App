import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/login/login_signuo_page.dart';
import 'package:wafi/pages/main_menu.dart';

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

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.fM.configure(onLaunch: (Map<String, dynamic> msg) {
      print(" onLaunch called ${msg}");
    }, onResume: (Map<String, dynamic> msg) {
      print( " onResume called ${msg}");
    }, onMessage: (Map<String, dynamic> msg) {
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
        widget.fLNP.initialize(initializationSettings);
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'Dont know 1',
      "Dont know 2",
      "Dont know 3",
    );
    print('msg es');
    print(msg);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await widget.fLNP.show(
        0, "Tu pedido fue tomado!", "info sobre que pedido", platform);
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
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onLoggedOut() {
    setState(() {
      Future<void> signedOutF = widget.auth.signOut();
      signedOutF.then((aVoid) {
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