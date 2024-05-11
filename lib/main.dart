import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_attdence/Authentication/UserRegister.dart';
import 'package:student_attdence/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:
            RegisterPage() // Set the home property to the desired starting widget
        );
  }
}
