import 'package:skinshark_ai_fixed/home.dart';
import 'package:skinshark_ai_fixed/utils/imports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Додано: уникнення дублювання ініціалізації
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  runApp(const SkinSharkAIApp());
}

class SkinSharkAIApp extends StatelessWidget {
  const SkinSharkAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinShark-AI',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.black)),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
            overlayColor: Colors.transparent,
          ),
        ),
      ),
      routes: {
        '/login': (context) => RegisterPage(),
        '/welcome': (context) => WelcomeScreen(),
        '/getStarted': (context) => StartPage(),
        '/home': (context) => SkinHomeScreen(),
      },
      home: const WidgetTree(),
      debugShowCheckedModeBanner: false,
    );
  }
}
