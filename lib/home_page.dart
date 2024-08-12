import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:Heritager/camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EB), // Background color
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top text in the center horizontally, but same distance vertically
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 0), // Keep vertical padding as it was
                  child: Text(
                    "LET'S GO SIGHTSEEING!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40, // Reduced font size by 8
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Horizontally centered
                  ),
                ),
              ),
              const Spacer(),
              // Circle in the middle with images in the corners
              SizedBox(
                width: 300, // Increased size
                height: 300, // Increased size
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        color: const Color(0xFFF6F4EB), // Same as background color inside the circle
                      ),
                    ),
                    Positioned(
                      top: 90,
                      left: 5,
                      child: Image.asset(
                        'assets/image_left.png', // Image in the left corner
                        width: 120,
                        height: 120,
                      ),
                    ),
                    Positioned(
                      bottom: 90,
                      right: 5,
                      child: Image.asset(
                        'assets/image_right.png', // Image in the right corner
                        width: 120,
                        height: 120,
                      ),
                    ),
                    Positioned(
                      top: 5, // Adjusted position
                      left: 100, // Adjusted position
                      child: Image.asset(
                        'assets/Ellipse_1.png', // Ellipse image on top of the circle
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Positioned(
                      top: 110, // Adjusted position, just below Ellipse
                      left: 110, // Adjusted position, centered below Ellipse
                      child: Image.asset(
                        'assets/Rectangle_1.png', // Rectangle image below Ellipse
                        width: 80,
                        height: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Bottom text lowered closer to the button
              const Text(
                "Find legends, little known stories \nand facts about the landmarks\naround you!",
                style: TextStyle(
                  color: Color(0xFF3B3B38),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 16.0), // Adjust padding to lower the text
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: const Color(0xFFFDB853), // Button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded button
                      side: const BorderSide(color: Colors.black, width: 2), // Black outline for the button
                    ),
                  ),
                  onPressed: () async {
                    await availableCameras().then((value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CameraPage(cameras: value))));
                  },
                  child: const Text(
                    "Take a Picture",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF121212), // Button text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
