import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'services/mode_provider.dart';
import 'services/medical_context_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_layout.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';
import 'services/gemma_offline_manager.dart';
import 'services/gemma_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize both AI managers early in the background
  GemmaOfflineManager().initialize();
  GemmaManager().initialize(); // New Hybrid AI manager
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Bypass: Running in Offline-Ready Mode. $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ModeProvider()),
        ChangeNotifierProvider(create: (_) => MedicalContextProvider()),
      ],
      child: const GemmaCareApp(),
    ),
  );
}

class GemmaCareApp extends StatefulWidget {
  const GemmaCareApp({super.key});

  @override
  State<GemmaCareApp> createState() => _GemmaCareAppState();
}

class _GemmaCareAppState extends State<GemmaCareApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<ModeProvider>(
      builder: (context, modeProvider, child) {
        return MaterialApp(
          title: 'GemmaCare',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          // Robust Home Configuration
          home: _showSplash 
            ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
            : const AuthWrapper(),
          builder: (context, child) {
            // Global Error Boundary to prevent white screen
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text('GemmaCare Recovery Mode Active', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(details.exceptionAsString().split('\n').first, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ElevatedButton(onPressed: () => main(), child: const Text('Reload System')),
                    ],
                  ),
                ),
              );
            };
            return child!;
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    if (auth.currentUser != null) {
      return const MainLayout();
    }
    return const LoginScreen();
  }
}
