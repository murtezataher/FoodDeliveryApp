import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Firestore
import 'package:foodapp/navbar_screen.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'splashscreen.dart';
import 'homescreen.dart'; // Replace with your actual HomePage implementation.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is logged in, determine role
          return RoleBasedNavigation();
        } else {
          // User is not logged in, navigate to SplashScreen
          return SplashScreen();
        }
      },
    );
  }
}

class RoleBasedNavigation extends StatelessWidget {
  const RoleBasedNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return  SplashScreen(); // Fallback in case no user is logged in
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('chefs').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          // Chef document exists, navigate to BottomNavBarScreen
          return const BottomNavBarScreen();
        } else {
          // Chef document does not exist, check customers collection
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('customers').doc(user.uid).get(),
            builder: (context, customerSnapshot) {
              if (customerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (customerSnapshot.hasData && customerSnapshot.data!.exists) {
                // Customer document exists, navigate to HomePage
                return HomePage();
              } else {
                // User is neither in chefs nor customers collection, log out
                FirebaseAuth.instance.signOut();
                return SplashScreen();
              }
            },
          );
        }
      },
    );
  }
}
