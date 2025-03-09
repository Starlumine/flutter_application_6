import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TitlePage(),
    );
  }
}

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Scavenger Hunt of PFT",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScavengerHuntPage()),
                );
              },
              child: const Text(
                "START",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScavengerHuntPage extends StatefulWidget {
  const ScavengerHuntPage({super.key});

  @override
  _ScavengerHuntPageState createState() => _ScavengerHuntPageState();
}

class _ScavengerHuntPageState extends State<ScavengerHuntPage> {
  int score = 0;
  final int totalQuestions = 14;
  
  // List of questions and correct answers
  final List<Map<String, String>> questions = [
    {"question": "What is the maximum occupancy of Panera Bread?", "answer": "88"},
    {"question": "What is written on the outlet underneath the room 1100 sign? (Type without spaces)", "answer": "6P1B4"},
    {"question": "Located near room 1126. How many pounds does the AgBot 2G weigh? (Enter a whole number)", "answer": "25"},
    {"question": "What snack is on number 160 at the vending machine?", "answer": "Poptarts"},
    {"question": "How many outlets are on the large stairs next to the Chevron Center?", "answer": "14"},
    {"question": "On the purple banners right above the large stairs, what is the word that starts with the letter T on the banner?", "answer": "Teammate"},
  ];

  final Map<int, TextEditingController> controllers = {};
  final Map<int, bool> correctAnswers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < questions.length; i++) {
      controllers[i] = TextEditingController();
      correctAnswers[i] = false;
    }
  }

  void checkAnswer(int index) {
    String userAnswer = controllers[index]!.text.trim();
    String correctAnswer = questions[index]["answer"]!.trim();

    if (userAnswer.toLowerCase() == correctAnswer.toLowerCase() && !correctAnswers[index]!) {
      setState(() {
        correctAnswers[index] = true;
        score++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PFT First Floor Questions"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                "$score / $totalQuestions",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questions[index]["question"]!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controllers[index],
                      onSubmitted: (_) => checkAnswer(index),
                      decoration: InputDecoration(
                        hintText: "Enter your answer",
                        suffixIcon: correctAnswers[index] == true
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
