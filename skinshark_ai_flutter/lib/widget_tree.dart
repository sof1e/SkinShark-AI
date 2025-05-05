import 'package:skinshark_ai_fixed/home.dart';
import 'package:skinshark_ai_fixed/utils/imports.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? const RegisterPage() : StartPage();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
