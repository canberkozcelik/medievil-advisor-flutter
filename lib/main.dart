import 'package:flutter/material.dart';
import 'core/di/di.dart';
import 'features/interaction/presentation/main_interaction_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await initializeDependencies();
  
  runApp(const MediEvilAdvisorApp());
}

class MediEvilAdvisorApp extends StatelessWidget {
  const MediEvilAdvisorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediEvil Advisor (PoC)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainInteractionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 