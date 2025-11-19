import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static Future<List<Question>> fetchQuestions({
    String format = 'multiple',
    String difficulty = 'easy',
  }) async {
    final response = await http.get(
      Uri.parse(
          'https://opentdb.com/api.php?amount=10&type=$format&difficulty=$difficulty'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Question> questions = (data['results'] as List)
          .map((questionData) => Question.fromJson(questionData as Map<String, dynamic>))
          .toList();
      return questions;
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
