import 'package:skinshark_ai_fixed/main.dart';
import 'package:skinshark_ai_fixed/utils/imports.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(SkinSharkAIApp());
}

class SkinHomeScreen extends StatefulWidget {
  const SkinHomeScreen({super.key});

  @override
  _SkinHomeScreenState createState() => _SkinHomeScreenState();
}

class _SkinHomeScreenState extends State<SkinHomeScreen> {
  int _currentIndex = 0; // Розмір вхідного зображення для моделі

  final List<Widget> _screens = [
    HomeScreen(),
    CameraScreen(),
    ProfileScreen(),
    EducationScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: primaryColor,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Education',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  bool _imageUploaded = false;
  String _diseaseName = "";
  double _confidence = 0.0;
  String _recommendations = "";
  StorageUtil _storageUtil = StorageUtil();
  Key _historyKey = UniqueKey();
  final List<String> _labels = [
    DiagnoseLabels.df,
    DiagnoseLabels.bcc,
    DiagnoseLabels.bkl,
    DiagnoseLabels.mel,
    DiagnoseLabels.nv,
    DiagnoseLabels.ackiec,
    DiagnoseLabels.vasc,
  ];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  late Interpreter _interpreter;
  final int inputSize = 224;
  final int numLabels = 7;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }

  Future<List<double>> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw Exception("Decoding failed for image: ${imageFile.path}");
    }

    // Змінюємо розмір до 224x224
    final resizedImage = img.copyResize(
      decodedImage,
      width: inputSize,
      height: inputSize,
    );

    // Створюємо плоский список із RGB, нормалізуємо в 0..1
    List<double> input = [];
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input.add(img.getRed(pixel) / 255.0);
        input.add(img.getGreen(pixel) / 255.0);
        input.add(img.getBlue(pixel) / 255.0);
      }
    }

    return input;
  }

  List<List<List<List<double>>>> formatInput(List<double> flatInput, int size) {
    var result = List.generate(
      1,
      (_) => List.generate(
        size,
        (y) => List.generate(
          size,
          (x) => List.generate(
            3,
            (c) => flatInput[(y * size + x) * 3 + c].toDouble(),
          ),
        ),
      ),
    );
    return result;
  }

  Future<void> predict(File imageFile) async {
    try {
      final input = await preprocessImage(imageFile);
      var inputTensor = formatInput(input, inputSize);

      var output = List.filled(numLabels, 0.0).reshape([1, numLabels]);
      _interpreter.run(inputTensor, output);

      final prediction = output[0];
      int maxIndex = 0;
      double maxProb = prediction[0];

      for (int i = 1; i < prediction.length; i++) {
        if (prediction[i] > maxProb) {
          maxProb = prediction[i];
          maxIndex = i;
        }
      }

      final predictedLabel = _labels.isNotEmpty ? _labels[maxIndex] : "Unknown";

      setState(() {
        _imageFile = imageFile;
        _imageUploaded = true;
        _diseaseName = predictedLabel;
        _confidence = maxProb;
        _recommendations = getRecommendationFor(predictedLabel);
      });
    } catch (e) {
      print("Помилка при передбаченні: $e");
    }
  }

  String getRecommendationFor(String label) {
    switch (label.trim()) {
      case DiagnoseLabels.ackiec:
        return "Avoid sun exposure; consult a dermatologist for treatment options.";
      case DiagnoseLabels.bcc:
        return "Requires medical examination and treatment by a specialist.";
      case DiagnoseLabels.bkl:
        return "Usually harmless but monitor any changes.";
      case DiagnoseLabels.df:
        return "Generally benign; see a doctor if it grows or changes.";
      case DiagnoseLabels.mel:
        return "Urgent medical consultation is required.";
      case DiagnoseLabels.nv:
        return "Common moles; monitor for any irregularities.";
      case DiagnoseLabels.vasc:
        return "May require dermatological evaluation.";
      default:
        return "Consult a dermatologist for accurate diagnosis and advice.";
    }
  }

  void _navigateToCamera(BuildContext context) async {
    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    if (capturedImage != null) {
      // Use your predict method instead of Tflite.runModelOnImage
      await predict(capturedImage);

      if (_imageUploaded && _diseaseName.isNotEmpty) {
        StorageUtil.saveHistoryEntry(
          HistoryEntry(
            userId: Auth().currentUser?.uid.toString() ?? "",
            image: capturedImage.path,
            diseaseName: _diseaseName,
            confidence: _confidence,
            recommendations: _recommendations,
            date: DateTime.now(),
          ),
        );

        setState(() {
          _historyKey = UniqueKey();
        });
      }
    }
  }

  Future<List<HistoryEntry>> showHistory() async {
    return await StorageUtil.getHistoryEntries(
      Auth().currentUser?.uid.toString() ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkinShark-AI'),
        backgroundColor: backgroundColor,
        shadowColor: secondaryColor,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: PhotoCard(
                imageFile: _imageFile,
                imageUploaded: _imageUploaded,
                onPressed: () => _navigateToCamera(context),
              ),
            ),
            const SizedBox(height: 16),
            if (_imageUploaded)
              SkinConditionResults(
                diseaseName: _diseaseName,
                confidence: _confidence,
                recommendations: _recommendations,
              ),
            const SizedBox(height: 10),
            if (_imageUploaded &&
                _diseaseName.isNotEmpty &&
                _confidence > 0.0 &&
                _recommendations.isNotEmpty)
              TryAgainButton(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _imageUploaded = false;
                    _diseaseName = "";
                    _confidence = 0.0;
                    _recommendations = "";
                  });
                },
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: const Text("Test your skin type"),
              ),
            ),
            if (!_imageUploaded) const EducationSection(),
          ],
        ),
      ),
    );
  }

  Widget _styledCard({required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
