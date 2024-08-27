import 'package:flutter/material.dart';
import 'package:job_hunter/home/desktop_home.dart';
import 'package:job_hunter/home/mobile_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Hunter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return const DesktopHomePage(title: 'Job Hunter App');
          } else {
            return const MobileHomePage(title: 'Job Hunter App');
          }
        },
      ),
    );
  }
}
