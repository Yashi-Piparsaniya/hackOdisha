import 'package:flutter/material.dart';
import '../../common/themes/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" "),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30) ,bottomRight: Radius.circular(30)),
              ),
              child: Center(
                  child: Column(
                    children: [
                      Text("Hello! How are you feeling today?",
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(color: AppColors.text),
                      ),
                      const SizedBox(height: 16),
                      Text("Get instant advice from the AI assistant!",
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(color: AppColors.text),
                      ),
                    ],
                  )
              ),
            ),
            const SizedBox(height: 75),

          ],
        ),
      ),
    );
  }
}

