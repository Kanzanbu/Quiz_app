import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = false;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  bool _quizStarted = false;
  String _selectedFormat = 'multiple';
  String _selectedDifficulty = 'easy';

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
    });
    try {
      final questions = await ApiService.fetchQuestions(
        format: _selectedFormat,
        difficulty: _selectedDifficulty,
      );
      setState(() {
        _questions = questions;
        _loading = false;
        _quizStarted = true;
      });
    } catch (e) {
      debugPrint('Error loading questions: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _submitAnswer(String selectedAnswer) {
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;

      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;
      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _answered = false;
        _selectedAnswer = "";
        _feedbackText = "";
        _currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          score: _score,
          totalQuestions: _questions.length,
          onRestart: _restartQuiz,
        ),
      ),
      (route) => false,
    );
  }

  void _restartQuiz() {
    setState(() {
      _quizStarted = false;
      _questions = [];
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = "";
      _feedbackText = "";
    });
  }

  Widget _buildOptionButton(String option) {
    Color backgroundColor = Colors.grey[200]!;
    Color textColor = Colors.black;

    if (_answered) {
      if (option == _selectedAnswer && option == _questions[_currentQuestionIndex].correctAnswer) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
      } else if (option == _selectedAnswer && option != _questions[_currentQuestionIndex].correctAnswer) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
      } else if (option == _questions[_currentQuestionIndex].correctAnswer) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
      }
    }

    return ElevatedButton(
      onPressed: _answered ? null : () => _submitAnswer(option),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        option,
        style: TextStyle(color: textColor, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFormatOption(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFormat = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedFormat == value ? Colors.blue : Colors.grey[300]!,
              width: _selectedFormat == value ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(label),
            leading: Opacity(
              opacity: _selectedFormat == value ? 1.0 : 0.5,
              child: Icon(
                _selectedFormat == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDifficulty = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedDifficulty == value ? Colors.blue : Colors.grey[300]!,
              width: _selectedDifficulty == value ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(label),
            leading: Opacity(
              opacity: _selectedDifficulty == value ? 1.0 : 0.5,
              child: Icon(
                _selectedDifficulty == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_quizStarted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Settings'),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Select Question Format',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildFormatOption('multiple', 'Multiple Choice'),
                      _buildFormatOption('boolean', 'True or False'),
                      const SizedBox(height: 32),
                      const Text(
                        'Select Difficulty Level',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildDifficultyOption('easy', 'Easy'),
                      _buildDifficultyOption('medium', 'Medium'),
                      _buildDifficultyOption('hard', 'Hard'),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: _loadQuestions,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Start Quiz',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz App')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Question ${_currentQuestionIndex + 1}/${_questions.length}'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                minHeight: 8,
              ),
              const SizedBox(height: 24),
              Text(
                question.question,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ...question.options.map((option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildOptionButton(option),
              )),
              const SizedBox(height: 20),
              if (_answered) ...[
                Text(
                  _feedbackText,
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedAnswer == question.correctAnswer
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestionIndex == _questions.length - 1
                        ? 'See Results'
                        : 'Next Question',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
  });

  String get _feedback {
    final percentage = (score / totalQuestions) * 100;

    if (percentage == 100) {
      return 'Perfect! You are a trivia master!';
    } else if (percentage >= 80) {
      return 'Excellent! You really know your stuff!';
    } else if (percentage >= 60) {
      return 'Good job! You did well!';
    } else if (percentage >= 40) {
      return 'Not bad! Keep practicing!';
    } else {
      return 'Better luck next time!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions) * 100;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Quiz Complete!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your Score',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$score / $totalQuestions',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _feedback,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRestart();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
