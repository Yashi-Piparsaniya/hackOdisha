import 'package:flutter/material.dart';
import '../../common/themes/colors.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  // List of FAQs
  final List<Map<String, String>> faqs = const [
    {
      "question": "What are the common symptoms of a cold?",
      "answer": "Sneezing, runny nose, sore throat, mild fever, and fatigue are common symptoms."
    },
    {
      "question": "When should I see a doctor for a fever?",
      "answer": "If the fever lasts more than 3 days, is very high (above 102°F / 38.9°C), or is accompanied by severe symptoms, consult a doctor."
    },
    {
      "question": "How can I prevent infections?",
      "answer": "Wash hands regularly, avoid close contact with sick people, maintain hygiene, and stay vaccinated."
    },
    {
      "question": "What are the warning signs of high blood pressure?",
      "answer": "Severe headaches, dizziness, chest pain, shortness of breath, and nosebleeds can be warning signs."
    },
    {
      "question": "How often should I get a general health checkup?",
      "answer": "Adults should have a checkup at least once a year or as advised by their doctor."
    },
    {
      "question": "How should I take my medicines?",
      "answer": "Follow the prescription, take at the recommended time, and do not skip doses."
    },
    {
      "question": "What are the common side effects of medicines?",
      "answer": "Side effects vary by medicine but may include nausea, dizziness, allergic reactions, or stomach upset."
    },
    {
      "question": "Can I take two medicines together safely?",
      "answer": "Only if your doctor or pharmacist approves. Some medicines may interact and cause side effects."
    },
    {
      "question": "How should I store my medicines?",
      "answer": "Keep medicines in a cool, dry place away from direct sunlight and out of reach of children."
    },
    {
      "question": "How do I know if a medicine is expired?",
      "answer": "Check the expiry date on the packaging. Do not consume medicines past their expiry date."
    },
    {
      "question": "What are the symptoms of COVID-19?",
      "answer": "Fever, dry cough, fatigue, loss of taste or smell, sore throat, and difficulty breathing."
    },
    {
      "question": "Should I self-isolate if I have mild symptoms?",
      "answer": "Yes, stay home, avoid contact with others, and monitor your symptoms."
    },
    {
      "question": "Which vaccines are recommended for adults?",
      "answer": "Flu vaccine, COVID-19 booster, Tdap, and other vaccines as advised by your doctor."
    },
    {
      "question": "What should I do in case of a severe allergic reaction?",
      "answer": "Call emergency services immediately and use an epinephrine auto-injector if available."
    },
    {
      "question": "How do I treat minor cuts or burns at home?",
      "answer": "Clean with water, apply antiseptic, and cover with a sterile bandage. Seek medical attention if severe."
    },
    {
      "question": "How much water should I drink daily?",
      "answer": "Around 8–10 glasses (2–2.5 liters) daily, more if you are active or in a hot climate."
    },
    {
      "question": "What is a balanced diet?",
      "answer": "A mix of fruits, vegetables, whole grains, proteins, and healthy fats in appropriate portions."
    },
    {
      "question": "How much exercise is recommended per week?",
      "answer": "At least 150 minutes of moderate-intensity exercise or 75 minutes of vigorous exercise."
    },
    {
      "question": "Do pharmacies deliver medicines at home?",
      "answer": "Many pharmacies offer delivery; check with your local pharmacy or online service."
    },
    {
      "question": "Are generic medicines as effective as branded ones?",
      "answer": "Yes, generic medicines contain the same active ingredients and are equally effective."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("FAQs"),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          final tileColor = index % 2 == 0
              ? AppColors.accent
              : Colors.white;

          return Card(
            color: tileColor,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                faq["question"]!,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    faq["answer"]!,
                    style: TextStyle(color: AppColors.text),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
