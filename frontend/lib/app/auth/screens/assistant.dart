import 'package:flutter/material.dart';
import '../../common/themes/colors.dart';

class Assistant extends StatefulWidget {
  const Assistant({super.key});

  @override
  State<Assistant> createState() => _AssistantState();
}

class _AssistantState extends State<Assistant> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" "),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30) ,bottomRight: Radius.circular(30)),
              ),
              child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                    ),
                  )
              ),
            ),
            const SizedBox(height: 75),
            GestureDetector(
              onTap: (){
                Navigator.pushNamed(context, "/chat");
              },
              child: Container(
                height: 175,
                width: 175,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_outlined , color: AppColors.text, size: 40,),
                      Text("Chat")
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap:(){
                Navigator.pushNamed(context, "/history");
              },
              child: Container(
                height: 175,
                width: 175,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history , color: AppColors.text, size: 40,),
                      Text("History")
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
