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
        title: const Text(" "),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top header
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hello! How are you feeling today?",
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: AppColors.text, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Get instant advice from the AI assistant!",
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: AppColors.text, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Grid View for Buttons
            Padding(
              padding: const EdgeInsets.all(50.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6, // makes buttons smaller & wider
                children: [
                  _buildGridItem(
                    context,
                    icon: Icons.chat_outlined,
                    label: "Chat",
                    onTap: () => Navigator.pushNamed(context, "/chat"),
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.history,
                    label: "History",
                    onTap: () => Navigator.pushNamed(context, "/history"),
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.question_answer_outlined,
                    label: "FAQs",
                    onTap: () => Navigator.pushNamed(context, "/faq"),
                  ),
                  _buildGridItem(
                    context,
                    icon: Icons.maps_home_work_sharp,
                    label: "Hospitals/Pharmacies",
                    onTap: () => Navigator.pushNamed(context, "/nhnp"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable method for grid items
  Widget _buildGridItem(BuildContext context,
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12), // smaller padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.text, size: 28), // smaller icon
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
                fontSize: 12, // smaller font
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
