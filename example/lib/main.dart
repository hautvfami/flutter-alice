import 'dart:io';

import 'package:alice_example/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/alice.dart';

// Navigator key
final navigatorKey = GlobalKey<NavigatorState>();

final alice = Alice();
final dio = Dio(BaseOptions(followRedirects: false));
final httpClient = HttpClient();

void main() {
  // Set up Alice to use the navigator key
  // alice.setNavigatorKey(navigatorKey);
  // Alice Capture all HTTP requests and responses in debug mode
  // Attach alice into Dio (only onetime)
  // if (kDebugMode) dio.interceptors.add(alice.getDioInterceptor());

  // alice.clearLogs();
  alice.log("Alice is running!", color: Colors.yellow);
  alice.log(StackTrace.current.toString(), color: Colors.yellow);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AliceInspector(
      debug: true,
      dios: [dio],
      navigatorKey: navigatorKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
