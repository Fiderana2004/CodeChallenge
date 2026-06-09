import 'package:flutter/material.dart';

class ResultBottomSheet {

  static void show(
      BuildContext context,
      String output,
      bool success
  ) {

    showModalBottomSheet(
      context: context,

      builder: (_) {

        return Container(
          padding: EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                success
                    ? Icons.check_circle
                    : Icons.error,

                color: success
                    ? Colors.green
                    : Colors.red,

                size: 50,
              ),

              SizedBox(height: 15),

              Text(
                success
                    ? "Succès"
                    : "Erreur",

                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 15),

              Text(output),
            ],
          ),
        );
      },
    );
  }
}