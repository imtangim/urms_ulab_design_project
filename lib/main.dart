import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/firebase_options.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope(child: const MyApp()),
  );
}

final scafoldKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late Future<dynamic> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = ref.read(sharedPrefProvider).authStateDecider(ref);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scafoldKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.white,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Appcolor.buttonBackgroundColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Column(
                  spacing: 40,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/ULAB-logo.webp"),
                    Center(
                      child: CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        color: Appcolor.buttonBackgroundColor,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              log(snapshot.error.toString());
            }
            return snapshot.data!;
          }),
    );
  }
}
