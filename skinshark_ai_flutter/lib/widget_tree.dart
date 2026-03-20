import 'package:skinshark_ai_fixed/home.dart';
import 'package:skinshark_ai_fixed/utils/imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  bool _hasSeenWelcome = false;
  bool _checkingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadWelcomeStatus();
  }

  Future<void> _loadWelcomeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenWelcome') ?? false;
    setState(() {
      _hasSeenWelcome = seen;
      _checkingPrefs = false;
    });
  }

  Future<void> _setWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (!_hasSeenWelcome) {
            // First time opening app
            _setWelcomeSeen();
            return const WelcomeScreen();
          }

          return user == null ? RegisterPage() : StartPage();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
