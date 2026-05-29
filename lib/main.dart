import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'services/seed_service.dart';
import 'app.dart';

void main() async {
  // Keep the native splash visible until initialisation is complete.
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Force HTTP long polling — avoids QUIC protocol crashes on web.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    webExperimentalForceLongPolling: true,
  );

  // Dismiss the native splash — Flutter is ready.
  FlutterNativeSplash.remove();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const DrapeApp());

  // Seed Firestore in the background after the app is running.
  // Does not block startup — products load from Firestore immediately;
  // seeding only patches changed imageUrls and writes genuinely new docs.
  SeedService.run();
}
