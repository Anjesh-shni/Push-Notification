import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel=AndroidNotificationChannel(
  'High_importance_channel',//id
  'High Importance Notifications.',//title
  // 'This channel is used for important notification', //discription
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=
FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessegingBackgroundHanler(RemoteMessage message)async {
  await Firebase.initializeApp();
  debugPrint("messege:-${message.messageId}");
}

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessegingBackgroundHanler);

  await flutterLocalNotificationsPlugin
  .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'push notification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Push notification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) { 
      RemoteNotification? notification = message.notification;
      AndroidNotification? android =message.notification?.android;

      if(notification !=null && android !=null){
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, 
              channel.name,
              channelDescription:
                  "This messagae you getting bcz push notification is testing !",
              color:  Colors.blue,
              playSound: true,
              icon:'@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) { 
      RemoteNotification? notification = message.notification;
      AndroidNotification? android =message.notification?.android;

      if(notification !=null && android !=null){
        showDialog(context: context, builder: (_){
          return AlertDialog(
            title: Text(notification.title!),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body!),
              ],
            )),
          ); 
        });
      }
    });
  }

  void showNotifications() {
    setState(() {
      _counter++;
    });

    flutterLocalNotificationsPlugin.show(
    0,
    "TEsting notification $_counter",
    "How you doing ?",
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: "This messagae you getting bcz push notification is testing !",
        importance: Importance.high,
        color: Colors.teal,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      )
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showNotifications,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      
    );
  }
}
