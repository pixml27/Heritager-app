import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:camera/camera.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:Heritager/gemini_model_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class PreviewPage extends StatefulWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile picture;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String? _aiResponse;
  late GeminiModelService _geminiService;
  bool _isLoading = true;  // Add loading state

  @override
  void initState() {
    super.initState();
    // Ensure the API key is loaded from the environment
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      // Handle the missing API key appropriately
      print('API key is missing');
      return;
    }

    _geminiService = GeminiModelService(GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
    ));
    
    _askGeminiModel();
  }

  void _askGeminiModel() async {
    setState(() {
      _isLoading = true;  // Show loading spinner
    });
    
    final response = await _geminiService.askGeminiModel(widget.picture);
    
    setState(() {
      _aiResponse = response;
      _isLoading = false;  // Hide loading spinner
    });
  }



 List<Widget> _buildMarkdownSections() {
  final List<Widget> sections = [];

  if (_aiResponse != null) {
    final lines = _aiResponse!.split('\n');
    StringBuffer currentContent = StringBuffer();
    String? mainCardHeader;
    List<Widget> innerCards = [];

    final List<Color> innerCardColors = [
      const Color(0xFFF6F4EB), const Color(0xFFF6F4EB), const Color(0xFFF6F4EB), const Color(0xFFF6F4EB)
    ];
    int colorIndex = 0;

    for (var line in lines) {
      if (line.trim().isEmpty) continue; // Skip empty lines
      if (line.startsWith('0 - ##')) {
        mainCardHeader = line.substring(6).trim();  // Remove "0 - ##" and trim
      } else if (line.startsWith(RegExp(r'[1-4] - '))) {
        // If there's already content for the previous section, add it to the inner cards
        if (currentContent.isNotEmpty) {
          innerCards.add(_buildInnerCard(
            currentContent.toString().trim(),
            innerCardColors[colorIndex % innerCardColors.length],
            colorIndex % 2 == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            colorIndex + 1 // Pass the index to control the positioning
          ));
          colorIndex++;
        }
        // Start a new section
        currentContent.clear();
        currentContent.writeln(line.substring(4).trim());  // Remove "1 - " etc. and trim
      } else {
        // Continue adding content to the current section
        if (mainCardHeader != null) {
          currentContent.writeln(line);
        }
      }
    }

    // Add the last section if it exists
    if (currentContent.isNotEmpty) {
      innerCards.add(_buildInnerCard(
        currentContent.toString().trim(),
        innerCardColors[colorIndex % innerCardColors.length],
        colorIndex % 2 == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        colorIndex + 1 // Pass the index
      ));
    }

    // If we have a main header and inner cards, create the main card
    if (mainCardHeader != null && innerCards.isNotEmpty) {
      sections.add(
        Center(
          child: Card(
            color: const Color(0xFFF6F4EB), // Main card background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainCardHeader,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B3B38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...innerCards,
                ],
              ),
            ),
          ),
        ),
      );
    } else if (_aiResponse!.isNotEmpty) {
      // If the response doesn't start with "0", show everything in one card
      sections.add(
        Center(
          child: Card(
            color: const Color(0xFFF6F4EB), // Main card background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              padding: const EdgeInsets.all(16.0),
              child: MarkdownBody(
                data: _aiResponse!,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 16.0,
                    color: Color(0xFF3B3B38),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  return sections;
}
Widget _buildInnerCard(String content, Color backgroundColor, CrossAxisAlignment alignment, int index) {
  return Align(
    alignment: alignment == CrossAxisAlignment.start ? Alignment.centerLeft : Alignment.centerRight,
    child: Stack(
      clipBehavior: Clip.none, // Allows the orange card to extend outside the stack's bounds
      children: [
        // Orange background card with offset and invisible text
        Positioned(
          top: 16, // Move it 10 pixels down
          left: index % 2 == 0 ? 10 : null, // Move it 10 pixels to the right if index is 1 or 3
          right: index % 2 != 0 ? 10 : null, // Move it 10 pixels to the left if index is 2 or 4
          child: Card(
            color: const Color(0xFFF4C128), // Orange color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, // Same width as the inner card
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: alignment,
                children: [
                  // Adding invisible text
                  MarkdownBody(
                    data: content,
                    styleSheet: MarkdownStyleSheet(
                      h3: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF4C128), // Make text invisible on orange background
                      ),
                      p: const TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFFF4C128), // Make text invisible on orange background
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Main content card
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                MarkdownBody(
                  data: content,
                  styleSheet: MarkdownStyleSheet(
                    h3: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B3B38),
                    ),
                    p: const TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF3B3B38),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}





@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EB), // Background color for the screen
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4EB), // AppBar color matching the background
        elevation: 0, // Remove shadow
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Right padding for logo
            child: Image.asset(
              'assets/logo.png', // Logo image on the right of AppBar
              width: 100,
              height: 75,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4C128)), // Orange spinner
              ),
            ) // Show orange spinner while loading
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4EB), // Background color to match the rest of the app
                          borderRadius: BorderRadius.circular(20.0), // Rounded corners
                          border: Border.all(
                            color: const Color(0xFF252525), // Dark border color
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(2, 4), // Shadow position
                            ),
                          ],
                        ),
                        clipBehavior: Clip.hardEdge, // Ensures the image respects the rounded corners
                        child: AspectRatio(
                          aspectRatio: 1, // Aspect ratio 1:1 to maintain the square shape
                          child: Image.file(
                            File(widget.picture.path),
                            fit: BoxFit.contain, // Preserve aspect ratio
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildMarkdownSections(),
                  ],
                ),
              ),
            ),
    );
  }
}