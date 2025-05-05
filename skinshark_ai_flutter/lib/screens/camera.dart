import 'package:skinshark_ai_fixed/utils/imports.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      Navigator.pop(
        context,
        File(pickedFile.path),
      ); // This will return the image to HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text("Camera  "),
            Icon(Icons.camera_alt, color: secondaryColor),
          ],
        ),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        backgroundColor: backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context); // Close the camera screen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text("Take a photo"),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text("Upload one"),
            ),
            // Remove the "Continue" button and related SizedBox
          ],
        ),
      ),
    );
  }
}
