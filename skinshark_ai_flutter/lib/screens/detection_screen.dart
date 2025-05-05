import 'package:skinshark_ai_fixed/utils/imports.dart';

class DetectionResultScreen extends StatelessWidget {
  final String diseaseName;
  final double confidence;
  final String recommendations;

  const DetectionResultScreen({
    required this.diseaseName,
    required this.confidence,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detection Results"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Detected Condition:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              diseaseName,
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Confidence Level:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${(confidence * 100).toStringAsFixed(2)}%",
              style: TextStyle(fontSize: 20, color: Colors.teal.shade700),
            ),
            const SizedBox(height: 20),
            Text(
              "Recommended Treatment:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(recommendations, style: TextStyle(fontSize: 16)),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SkinHomeScreen(),
                    ),
                    (Route<dynamic> route) =>
                        false, // Removes all previous routes
                  );
                },
                child: const Text("Back to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
