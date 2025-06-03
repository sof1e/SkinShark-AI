import 'package:skinshark_ai_fixed/utils/imports.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:skinshark_ai_fixed/utils/diagnose_labels.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CameraScreen extends StatefulWidget {
  final Function(File)? onImageCaptured;

  const CameraScreen({Key? key, this.onImageCaptured}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;
  final int inputSize = 224;
  final int numLabels = 7;

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

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      await _handleImage(image);
    }
  }

  Future<List<double>> preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      throw Exception("Failed to decode image: ${imageFile.path}");
    }

    final resizedImage = img.copyResize(
      decodedImage,
      width: inputSize,
      height: inputSize,
    );

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

  List<List<List<List<double>>>> formatInput(List<double> flatInput) {
    return List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) =>
              List.generate(3, (c) => flatInput[(y * inputSize + x) * 3 + c]),
        ),
      ),
    );
  }

  Future<void> _handleImage(File imageFile) async {
    try {
      final input = await preprocessImage(imageFile);
      final inputTensor = formatInput(input);

      var output = List.filled(numLabels, 0.0).reshape([1, numLabels]);
      _interpreter?.run(inputTensor, output);

      final prediction = output[0];
      int maxIndex = 0;
      double maxProb = prediction[0];
      for (int i = 1; i < prediction.length; i++) {
        if (prediction[i] > maxProb) {
          maxProb = prediction[i];
          maxIndex = i;
        }
      }

      final label = _labels[maxIndex];
      final confidence = maxProb;
      final recommendation = _getRecommendation(label);

      // зберігаємо в історію
      StorageUtil.saveHistoryEntry(
        HistoryEntry(
          userId: Auth().currentUser?.uid.toString() ?? "",
          image: imageFile.path,
          diseaseName: label,
          confidence: confidence,
          recommendations: recommendation,
          date: DateTime.now(),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, imageFile); // повертаємо зображення
    } catch (e) {
      print("Prediction error: $e");
    }
  }

  String _getRecommendation(String label) {
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
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_camera),
              label: const Text("Take a photo"),
              onPressed: () => _pickImage(ImageSource.camera),
            ).animate().fade(duration: 500.ms).scale(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text("Upload one"),
              onPressed: () => _pickImage(ImageSource.gallery),
            ).animate().fade(delay: 300.ms, duration: 500.ms).scale(),
          ],
        ),
      ),
    );
  }
}
