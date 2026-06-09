import 'package:flutter/material.dart';
import '../models/defi.dart';

class DefiCard extends StatelessWidget {

  final Defi defi;
  final VoidCallback onTap;

  const DefiCard({
    super.key,
    required this.defi,
    required this.onTap,
  });

  Color getDifficultyColor() {

    switch (defi.difficulte.toLowerCase()) {

      case "facile":
        return Colors.green;

      case "moyen":
        return Colors.orange;

      case "difficile":
        return Colors.red;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Expanded(
                  child: Text(
                    defi.titre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: getDifficultyColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    defi.difficulte,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 10),

            Text(
              defi.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 15),

            Row(
              children: [

                const Icon(Icons.star, color: Colors.amber),

                const SizedBox(width: 5),

                Text("${defi.points} points"),

                const Spacer(),

                const Icon(Icons.code),

                const SizedBox(width: 5),

                Text(defi.langage),
              ],
            )
          ],
        ),
      ),
    );
  }
}