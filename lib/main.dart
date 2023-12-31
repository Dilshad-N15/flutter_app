import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mentor_mind/auth/user_check.dart';
import 'package:mentor_mind/screens/splash.dart';
import 'package:mentor_mind/.env';
import 'package:wiredash/wiredash.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Stripe.publishableKey = pk;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      secret: 'RjKaEx8hRbFBbXr-M7Jz5CUg2KYs2sOA',
      projectId: 'medical-5b2ykyx',
      child: MaterialApp(
        routes: {
          'usercheck': (context) => UserCheck(),
          '/': (context) => SplashScreen(),
        },
        debugShowCheckedModeBanner: false,
        title: 'Mentor Mind',
        theme: ThemeData.dark(
          useMaterial3: true,
        ),
        // home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UserCheck(),
    );
  }
}
