import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recepies_app/firebase_options.dart';
import 'package:recepies_app/pages/landing_page.dart';
import 'package:recepies_app/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recip Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white, // Seed for consistency
          primary: const Color(0xFFFF5722), // Appetizing Orange
          secondary: const Color(0xFF4CAF50), // Fresh Green
          tertiary: const Color(0xFFFFC107), // Lemon Yellow
          background: const Color(0xFFFAF3E0), // Soft Warm Beige
          surface: Colors.white, // Card surfaces
          error: Colors.redAccent,
          onPrimary: Colors.white, // Text on primary color
          onSecondary: Colors.white, // Text on secondary color
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LandingPage(),
      routes: {LoginPage.routeName: (context) => const LoginPage()},
    );
  }
}
