import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'screens/home_screen.dart';
import 'services/audio_handler.dart'; // Import the handler
import 'widgets/root_layout.dart';

Future<void> main() async { // Make main async
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the audio handler
  await setupAudioHandler(); 
  
  runApp(const ScoreApp());
}

class ScoreApp extends StatelessWidget {
  const ScoreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Score Music',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFFFFDB4D)),
          titleTextStyle: TextStyle(
            color: Color(0xFFFFDB4D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFDB4D),
          brightness: Brightness.dark,
          primary: const Color(0xFFFFDB4D),
          secondary: const Color(0xFFFFDB4D),
          surface: Colors.black,
          background: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Color(0xFFFFDB4D)),
          titleMedium: TextStyle(color: Color(0xFFFFDB4D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFDB4D)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFDB4D),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const RootLayout(
        child: HomeScreen(),
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}