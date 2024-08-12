import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class GeminiModelService {
  final GenerativeModel _model;

  GeminiModelService(this._model);

  Future<String?> askGeminiModel(XFile picture) async {
    try {
      final imageBytes = await File(picture.path).readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      final prompt = """The image shows a landmark. Imagine you're a tour guide and describe it by covering the following points:
0 - name of the landmark
1 - **Creation History and Historical Significance**: Provide a brief history of the landmark's creation and its significance through the ages in 5 sentences.
2 - **Interesting Facts**: Share 2-3 intriguing facts about the landmark that would captivate a visitor's attention.
3 - **Legend**: If there is a legend or myth associated with this landmark, please describe it. If you have an interesting story, tell it briefly. In extreme cases, if you don't know any legends or myths, old or funny facts about this place - find the most interesting fact (the one that can evoke some emotion in the user) and tell it in this section (mentioning that, unfortunately, there is no legend, but there is something else).
4 - **Current Use**: Explain how the landmark is used or preserved today.
Please organize your response into separate sections for each topic. Write your answer in the form (digits dash text) and in the markdown:
0 - name of the landmark (header h2); 1 - 4 (items indicated above) and header h3. (for example first line should be: 0 - ## Eiffel tower; second line like: 1 - ### Creation History )
If you don't recognize the landmark, return a formal response along the lines of 'sorry, I don't see the landmark here, please take a photo from a different angle.' """;

      await Future.delayed(const Duration(seconds: 1)); // Adjust the duration as needed

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), imagePart])
      ]);

      print('AI Response: ${response.text}');

      return response.text;
    } catch (e) {
      return 'Error: $e';
    }
  }
}
