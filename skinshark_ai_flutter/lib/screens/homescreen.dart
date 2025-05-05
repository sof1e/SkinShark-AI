import 'package:intl/intl.dart';
import 'package:skinshark_ai_fixed/main.dart';
import 'package:skinshark_ai_fixed/utils/diagnose_labels.dart';
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
  int _currentIndex = 0; // размер входного изображения для модели

  final List<Widget> _screens = [
    HomeScreen(),
    CameraScreen(),
    ProfileScreen(),
    MenuScreen(),
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
  final int inputSize = 224; // размер входного изображения для модели
  final int numLabels = 7; // количество классов (замени на своё)

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }

  Future<List<double>> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw Exception("Decoding failed for image: ${imageFile.path}");
    }

    // Изменяем размер до 224x224
    final resizedImage = img.copyResize(
      decodedImage,
      width: inputSize,
      height: inputSize,
    );

    // Создаём плоский список из RGB, нормализуем в 0..1
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
      print("Ошибка при предсказании: $e");
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
    return Container(
      color: backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        alignment: Alignment.center,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _imageUploaded
                            ? "Your Skin Analysis Results:"
                            : "Your Personal Skin Analysis!",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          textBaseline: TextBaseline.alphabetic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Center(
                child: Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  padding: const EdgeInsets.all(16), // internal padding
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // external padding from corners
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
                  child: Column(
                    children: [
                      _imageFile != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              height: 240,
                              fit: BoxFit.cover,
                            ),
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/skinfront.jpg',
                              height: 240,
                            ),
                          ),
                      const SizedBox(height: 12),
                      const Text(
                        "Analyze your skin now!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _navigateToCamera(context),
                        child: Text(
                          _imageUploaded
                              ? "Photo Uploaded"
                              : "Snap a photo or upload one",
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Skin Conditions Detected Section
              if (_imageUploaded)
                Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  padding: const EdgeInsets.all(16), // internal padding
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // external padding from corners
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Skin Conditions Detected:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Condition: $_diseaseName",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Confidence: ${(_confidence * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              // Treatment and Preventive Plan Section with ExpansionTile
              if (_imageUploaded)
                Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.9, // 90% of screen width
                  padding: const EdgeInsets.all(16), // internal padding
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // external padding from corners
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
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.medical_services,
                      color: primaryColor,
                    ),
                    title: const Text(
                      "Treatment and Preventive Plan:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        _recommendations,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              // Button to go back to HomeScreen and try again
              if (_imageUploaded &&
                  _diseaseName.isNotEmpty &&
                  _confidence > 0.0 &&
                  _recommendations.isNotEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Reset state to allow new image capture
                        _imageFile = null;
                        _imageUploaded = false;
                        _diseaseName = "";
                        _confidence = 0.0;
                        _recommendations = "";
                      });
                    },
                    child: const Text("Try Again"),
                  ),
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
              if (!_imageUploaded) ...[
                const SizedBox(height: 24),
                const Text(
                  "Education: Common conditions",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Learn about common skin conditions and how to treat them.\nThis section provides articles and resources to help you understand your skin better.\n",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ArticleCard(
                        title: "Guide to Skin Cancer",
                        imageUrl:
                            "https://miiskin.com/wp-content/uploads/2019/08/types-of-skin-cancer.jpg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MenuScreen(),
                            ),
                          );
                        },
                      ),
                      ArticleCard(
                        title: "How to Prevent Acne",
                        imageUrl:
                            "https://thenakedchemist.com/wp-content/uploads/2022/07/20_YWNuZQ-1024x932.jpg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MenuScreen(),
                            ),
                          );
                        },
                      ),
                      ArticleCard(
                        title: "Best Skincare Routines",
                        imageUrl:
                            "https://hips.hearstapps.com/hmg-prod/images/skincare-steps-677e840842f99.jpg?crop=1.00xw:0.750xh;0,0.0944xh&resize=1200:*",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MenuScreen(),
                            ),
                          );
                        },
                      ),
                      ArticleCard(
                        title: "Understanding Eczema",
                        imageUrl:
                            "https://www.eczemaexposed.com/-/media/ems/conditions/dermatology/brands/dupi-unbranded/eczema/understanding-eczema/eczema-example-2.jpg",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MenuScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const HistoryList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
