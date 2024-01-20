import 'dart:async';

import 'package:ecommerce/core/store.dart';
import 'package:ecommerce/pages/home_page.dart';
import 'package:ecommerce/firebase_options.dart';
import 'package:ecommerce/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:velocity_x/velocity_x.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_live_51NK5L9SJJNLsE9Oi6201Z1XPTXjfrDvjDdEXySUbTlpJfFFIgnGJvDbLbB9dsjSfDvTyUQaEnLFH6HRSE0T6kqLG00Q1kmrwFp";

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(VxState(store: MyStore(), child: const MyApp()));
}

Future<void> initPaymentSheet() async {
  try {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: const SetupPaymentSheetParameters(
        customFlow: true,
        merchantDisplayName: 'Flutter Stripe Demo',
        paymentIntentClientSecret: "",
        customerEphemeralKeySecret: "",
        customerId: "",
        setupIntentClientSecret: "",
        style: ThemeMode.light,
      ),
    );
  } catch (e) {
    // ScaffoldMessenger.of().showSnackBar(
    //   SnackBar(content: Text('Error: $e')),
    // );
    print(e);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3), // Set the duration of the splash screen
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your custom splash screen content, e.g., logo, text, etc.
            Image.asset(
              './assets/images/logo.png',
              width: 150.0,
              height: 150.0,
            ),
            
          ],
        ),
      ),
    );
  }
}
