import 'package:skinshark_ai_fixed/utils/imports.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void register() async {
    try {
      await authservice.value.createUserWithEmailandPassword(
        emailController.text,
        passwordController.text,
      );
      popPage();
    } on FirebaseAuthException catch (e) {
      print(e.message);
      setState(() {
        errorMessage = e.message ?? 'An error occurred';
      });
    }
  }

  void popPage() {
    Navigator.pop(context);
  }

  Future<void> signInWithEmailandPassword() async {
    try {
      final user = await Auth().signInWithEmailandPassword(
        emailController.text,
        passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailandPassword() async {
    try {
      await Auth().createUserWithEmailandPassword(
        emailController.text,
        passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text(
      'Welcome to SkinShark-AI!',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: title),
      obscureText: title == 'Password' ? true : false,
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : '$errorMessage!',
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        isLogin
            ? signInWithEmailandPassword()
            : createUserWithEmailandPassword();
      },
      child: Text(isLogin ? 'Login' : 'Register'),
    );
  }

  Widget _loginRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Create an account' : 'Have an account? Login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('SkinShark—AI'),
        backgroundColor: backgroundColor,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _title(),
            const SizedBox(height: 20),
            _entryField('Email', emailController),
            const SizedBox(height: 20),
            _entryField('Password', passwordController),
            const SizedBox(height: 20),
            _errorMessage(),
            const SizedBox(height: 20),
            _submitButton(),
            _loginRegisterButton(),
          ],
        ),
      ),
    );
  }
}
