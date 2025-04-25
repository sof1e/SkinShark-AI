import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> questions = [
    "How often does your skin feel oily?",
    "How often does your skin feel dry?",
    "Do you experience acne frequently?",
    "Does your skin feel tight after washing?",
    "How often do you use moisturizer?",
    "Do you have visible pores on your skin?",
    "Does your skin get red or irritated easily?",
    "How does your skin react to the sun?",
    "Do you experience flaky skin?",
    "Does your skin look shiny by midday?",
    "Do you have uneven skin tone?",
    "How often do you experience breakouts?",
    "Does your skin feel sensitive to new products?",
    "How does your skin feel in humid weather?",
  ];

  int currentQuestionIndex = 0;
  Map<String, int> skinTypeScores = {
    "Oily": 0,
    "Dry": 0,
    "Sensitive": 0,
    "Combination": 0,
  };

  void answerQuestion(String skinType) {
    setState(() {
      skinTypeScores[skinType] = skinTypeScores[skinType]! + 1;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    String result =
        skinTypeScores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Your Skin Type"),
            content: Text("Based on your answers, your skin type is: $result."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    currentQuestionIndex = 0;
                    skinTypeScores = {
                      "Oily": 0,
                      "Dry": 0,
                      "Sensitive": 0,
                      "Combination": 0,
                    };
                  });
                },
                child: Text("Restart"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Skin Type Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questions[currentQuestionIndex],
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => answerQuestion("Oily"),
              child: Text("Oily"),
            ),
            ElevatedButton(
              onPressed: () => answerQuestion("Dry"),
              child: Text("Dry"),
            ),
            ElevatedButton(
              onPressed: () => answerQuestion("Sensitive"),
              child: Text("Sensitive"),
            ),
            ElevatedButton(
              onPressed: () => answerQuestion("Combination"),
              child: Text("Combination"),
            ),
          ],
        ),
      ),
    );
  }
}
