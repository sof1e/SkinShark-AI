import 'package:skinshark_ai_fixed/utils/imports.dart';

class StartPage extends StatelessWidget {
  StartPage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;

  Future<void> _signOut(BuildContext context) async {
    try {
      await Auth().signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error signing out: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SkinShark-AI"),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${user?.email ?? 'Guest'}!",
              style: TextStyle(color: buttonColor, fontSize: 24),
            ),
            const SizedBox(height: 20),
            if (user == null)
              Text(
                "You need to log in or register to continue. \n        Please click the button below.",
                style: TextStyle(color: buttonColor, fontSize: 12),
              ),
            if (user == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text("Sign In or Register"),
              ),
            if (user != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text("Go to Profile"),
              ),
          ],
        ),
      ),
    );
  }
}
