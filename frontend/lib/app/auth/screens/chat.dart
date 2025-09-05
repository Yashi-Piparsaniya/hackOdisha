import 'package:flutter/material.dart';
import '../../common/themes/colors.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Assistant"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
