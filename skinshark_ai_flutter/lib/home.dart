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
        leading: Image.asset(
          'assets/images/skin1.png',
          height: 40,
          width: 40,
          fit: BoxFit.cover,
        ),
        title: const Text("SkinShark-AI"),
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
            Text("Welcome, ${user?.email ?? 'Guest'}!"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/welcome');
              },
              child: const Text("Go to Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
