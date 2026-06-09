import 'package:flutter/material.dart';

import '../../models/defi.dart';

import 'code_editor_screen.dart';

class DefiDetailScreen extends StatelessWidget {

  final Defi defi;

  const DefiDetailScreen({
    super.key,
    required this.defi,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(defi.titre),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    defi.titre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    defi.description,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Chip(
                        label: Text(defi.difficulte),
                      ),

                      const SizedBox(width: 10),

                      Chip(
                        label: Text("${defi.points} pts"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),

                onPressed: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => CodeEditorScreen(defi: defi),
                    ),
                  );
                },

                icon: const Icon(Icons.code),

                label: const Text("Résoudre ce défi"),
              ),
            )
          ],
        ),
      ),
    );
  }
}