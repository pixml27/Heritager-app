import 'package:flutter/material.dart';
import 'package:Heritager/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Heritager',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
