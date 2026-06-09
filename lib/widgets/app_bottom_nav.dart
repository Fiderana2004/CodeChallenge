import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(

      currentIndex: currentIndex,

      onTap: onTap,

      selectedItemColor: Colors.blue,

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.code),
          label: "Défis",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: "Classement",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}