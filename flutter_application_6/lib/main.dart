import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import to use LogicalKeyboardKey

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProgressTracker(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const TitlePage(),
      ),
    );
  }
}

// Tracks and stores the total scores
class ProgressTracker extends InheritedWidget {
  final int totalQuestions = 11;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final List<bool> answeredQuestions = List.generate(11, (_) => false); // List to track all answers
  final List<bool> incorrectAnswers = List.generate(11, (_) => false); // List to track incorrect answers

  ProgressTracker({super.key, required super.child});

  void checkForCompletion(BuildContext context) {
    if (scoreNotifier.value == totalQuestions) {
      // Ensure the widget rebuilds before navigating
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CongratsPage()),
        );
      });
    }
  }

  static ProgressTracker of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ProgressTracker>()!;
  }

  @override
  bool updateShouldNotify(covariant ProgressTracker oldWidget) {
    return answeredQuestions != oldWidget.answeredQuestions || incorrectAnswers != oldWidget.incorrectAnswers;
  }
}

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Scavenger Hunt of PFT",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FirstFloorPage()),
                    );
                  },
                  child: const Text("START", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20), // Space between button and map
                Image.asset(
                  'media/map.png',
                  width: 500, // Adjust width as needed
                ),
              ],
            ),
          ),

          // Girl image positioned at the bottom right
          Positioned(
            bottom: 20, // Distance from the bottom
            left: 100, // Distance from the right
            child: Image.asset(
              'media/girl.png',
              width: 180, // Adjust size as needed
            ),
          ),
        ],
      ),
    );
  }
}

class FirstFloorPage extends StatefulWidget {
  const FirstFloorPage({super.key});

  @override
  FirstFloorPageState createState() => FirstFloorPageState();
}

class FirstFloorPageState extends State<FirstFloorPage> {
  final List<Map<String, dynamic>> questions = [
    {"question": "What is the maximum occupancy of Panera Bread?", "answer": "88", "answered": false},
    {"question": "What is written on the outlet underneath the room 1100 sign? (Type without spaces)", "answer": "6P1B4", "answered": false},
    {"question": "Located near room 1126. How many pounds does the AgBot 2G weigh?", "answer": "25", "answered": false},
    {"question": "What snack is on number 160 at the vending machine?", "answer": "Poptarts", "answered": false},
    {"question": "How many outlets are on the large stairs next to the Chevron Center?", "answer": "14", "answered": false},
    {"question": "On the purple banners right above the large stairs, what is the word that starts with the letter T on the banner?", "answer": "Teammate", "answered": false},
  ];

  // Add FocusNode to listen for key events
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PFT First Floor Questions"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ValueListenableBuilder<int>(
              valueListenable: ProgressTracker.of(context).scoreNotifier,
              builder: (context, score, child) {
                return Text("$score / ${ProgressTracker.of(context).totalQuestions}");
              },
            ),
          ),
        ],
      ),
      body: RawKeyboardListener(
        focusNode: _focusNode, // Attach FocusNode here
        onKey: (RawKeyEvent event) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            // Navigate to the CongratsPage when up arrow is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CongratsPage()),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: _buildFirstFloorQuestionList(context),
            ),
            // Searching image at the bottom
            Image.asset(
              'media/searching.png',
              width: 300, // Adjust size as needed
            ),
            const SizedBox(height: 10), // Space between image and bottom
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondFloorPage()),
          );
        },
        label: const Text("Next: Second Floor"),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildFirstFloorQuestionList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return _buildQuestionCard(context, questions[index], index);
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, Map<String, dynamic> question, int index) {
    TextEditingController controller = TextEditingController();
    final progressTracker = ProgressTracker.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(question["question"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter your answer",
                  enabled: !progressTracker.answeredQuestions[index], // Disable if answered
                ),
                onSubmitted: (input) {
                  if (input.trim().toLowerCase() == question["answer"]!.toLowerCase() && !progressTracker.answeredQuestions[index]) {
                    setState(() {
                      progressTracker.answeredQuestions[index] = true; // Mark as answered
                      progressTracker.scoreNotifier.value++; // Increment score if correct
                      progressTracker.incorrectAnswers[index] = false; // Reset incorrect state if correct
                    });

                    // Check if all questions are answered
                    progressTracker.checkForCompletion(context); // Call this after answering
                  } else if (input.trim().isNotEmpty) {
                    setState(() {
                      progressTracker.incorrectAnswers[index] = true; // Mark as incorrect
                    });
                  }
                },
              ),
            ),
            if (progressTracker.answeredQuestions[index])
              const Icon(Icons.check_circle, color: Colors.green), // Display checkmark if answered correctly
            if (progressTracker.incorrectAnswers[index])
              const Icon(Icons.cancel, color: Colors.red), // Display X if answer is incorrect
          ],
        ),
      ),
    );
  }
}

class CongratsPage extends StatelessWidget {
  const CongratsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🎉 Congratulations! 🎉",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "You've answered all 11 questions correctly!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.asset('media/trophy.png', width: 200), // Add a trophy image
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Restart the game
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const TitlePage()),
                  (route) => false,
                );
              },
              child: const Text("Play Again", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondFloorPage extends StatefulWidget {
  const SecondFloorPage({super.key});

  @override
  SecondFloorPageState createState() => SecondFloorPageState();
}

class SecondFloorPageState extends State<SecondFloorPage> {
  final List<Map<String, dynamic>> questions = [
    {"question": "What is the company name on the top right of every thermostat in the building?", "answer": "Johnson Controls", "answered": false},
    {"question": "The student services office is named after a person. What is their last name?", "answer": "Brookshire", "answered": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PFT Second Floor Questions"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ValueListenableBuilder<int>(
              valueListenable: ProgressTracker.of(context).scoreNotifier,
              builder: (context, score, child) {
                return Text("$score / ${ProgressTracker.of(context).totalQuestions}");
              },
            ),
          ),
        ],
      ),
      body: _buildSecondFloorQuestionList(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThirdFloorPage()),
          );
        },
        label: const Text("Next: Third Floor"),
        icon: const Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildSecondFloorQuestionList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return _buildQuestionCard(context, questions[index], index + 6); // Adjust index for second floor
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, Map<String, dynamic> question, int index) {
    TextEditingController controller = TextEditingController();
    final progressTracker = ProgressTracker.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(question["question"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter your answer",
                  enabled: !progressTracker.answeredQuestions[index], // Disable if answered
                ),
                onSubmitted: (input) {
                  if (input.trim().toLowerCase() == question["answer"]!.toLowerCase() && !progressTracker.answeredQuestions[index]) {
                    setState(() {
                      progressTracker.answeredQuestions[index] = true; // Mark as answered
                      progressTracker.scoreNotifier.value++; // Increment score if correct
                      progressTracker.incorrectAnswers[index] = false; // Reset incorrect state if correct
                    });

                    // Check if all questions are answered
                    progressTracker.checkForCompletion(context); // Call this after answering
                  } else if (input.trim().isNotEmpty) {
                    setState(() {
                      progressTracker.incorrectAnswers[index] = true; // Mark as incorrect
                    });
                  }
                },
              ),
            ),
            if (progressTracker.answeredQuestions[index])
              const Icon(Icons.check_circle, color: Colors.green), // Display checkmark if answered correctly
            if (progressTracker.incorrectAnswers[index])
              const Icon(Icons.cancel, color: Colors.red), // Display X if answer is incorrect
          ],
        ),
      ),
    );
  }
}

class ThirdFloorPage extends StatefulWidget {
  const ThirdFloorPage({super.key});

  @override
  ThirdFloorPageState createState() => ThirdFloorPageState();
}

class ThirdFloorPageState extends State<ThirdFloorPage> {
  final List<Map<String, dynamic>> questions = [
    {"question": "On the third floor, there is an area you can walk outside of. What is this area called?", "answer": "West Terrace", "answered": false},
    {"question": "What room number is David Shepherd's room?", "answer": "3272W", "answered": false},
    {"question": "Next to room 3207, there are two checks in a display case. What number is on the check for the PetroBowl XVIII?", "answer": "5000", "answered": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PFT Third Floor Questions"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ValueListenableBuilder<int>(
              valueListenable: ProgressTracker.of(context).scoreNotifier,
              builder: (context, score, child) {
                return Text("$score / ${ProgressTracker.of(context).totalQuestions}");
              },
            ),
          ),
        ],
      ),
      body: _buildThirdFloorQuestionList(context),
    );
  }

  Widget _buildThirdFloorQuestionList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return _buildQuestionCard(context, questions[index], index + 8); // Adjust index for third floor
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, Map<String, dynamic> question, int index) {
    TextEditingController controller = TextEditingController();
    final progressTracker = ProgressTracker.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(question["question"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter your answer",
                  enabled: !progressTracker.answeredQuestions[index], // Disable if answered
                ),
                onSubmitted: (input) {
                  if (input.trim().toLowerCase() == question["answer"]!.toLowerCase() && !progressTracker.answeredQuestions[index]) {
                    setState(() {
                      progressTracker.answeredQuestions[index] = true; // Mark as answered
                      progressTracker.scoreNotifier.value++; // Increment score if correct
                      progressTracker.incorrectAnswers[index] = false; // Reset incorrect state if correct
                    });

                    // Check if all questions are answered
                    progressTracker.checkForCompletion(context); // Call this after answering
                  } else if (input.trim().isNotEmpty) {
                    setState(() {
                      progressTracker.incorrectAnswers[index] = true; // Mark as incorrect
                    });
                  }
                },
              ),
            ),
            if (progressTracker.answeredQuestions[index])
              const Icon(Icons.check_circle, color: Colors.green), // Display checkmark if answered correctly
            if (progressTracker.incorrectAnswers[index])
              const Icon(Icons.cancel, color: Colors.red), // Display X if answer is incorrect
          ],
        ),
      ),
    );
  }
}
