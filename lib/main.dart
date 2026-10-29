import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management_application/providers/visitor_provider.dart';
import 'package:visitor_management_application/screens/splash_screen.dart';
import 'package:visitor_management_application/services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<VisitorService>(
          create: (_) => VisitorService(),
          dispose: (_, service) => service.dispose(),
        ),
        ChangeNotifierProvider<VisitorProvider>(
          create: (context) => VisitorProvider(
            context.read<VisitorService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  SplashScreen(),
    );
  }
}
