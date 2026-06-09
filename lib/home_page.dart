import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Map user;

  HomePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Bienvenue ${user["nom"]}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 10),

            Text("Email: ${user["email"]}"),
            Text("Points: ${user["points"]}"),
            Text("Niveau: ${user["niveau"]}"),
          ],
        ),
      ),
    );
  }
}