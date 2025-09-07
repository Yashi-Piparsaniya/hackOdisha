import 'package:flutter/material.dart';
import 'package:hack_odisha/app/auth/screens/assistant.dart';
import 'package:hack_odisha/app/auth/screens/profile.dart';
import '../../common/themes/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage=0;
  List<Widget> pages = const [Assistant(), Profile()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPage,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: AppColors.primary,
          currentIndex: currentPage,
          onTap: (value){
            setState(() {
              currentPage=value;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.assistant , size: 30,),
              label: "",
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.person , size: 30),
              label: "",
            ),
          ]
      ),
    );
  }
}

