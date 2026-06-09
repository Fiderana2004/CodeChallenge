import 'package:flutter/material.dart';

import '../../models/defi.dart';
import '../../services/soumission_service.dart';
import '../../widgets/result_bottom_sheet.dart';

class CodeEditorScreen extends StatefulWidget {

  final Defi defi;

  const CodeEditorScreen({
    super.key,
    required this.defi,
  });

  @override
  State<CodeEditorScreen> createState() =>
      _CodeEditorScreenState();
}

class _CodeEditorScreenState
    extends State<CodeEditorScreen> {

  final TextEditingController codeController =
      TextEditingController();

  bool isLoading = false;

  void runCode() async {

    // 🔥 vérifier si code vide
    if (codeController.text.trim().isEmpty) {

      ResultBottomSheet.show(
        context,
        "⚠️ Veuillez écrire du code",
        false,
      );

      return;
    }

    setState(() => isLoading = true);

    final result =
        await SoumissionService.runCode(

      widget.defi.langage,
      codeController.text,
      widget.defi.id,
    );

    setState(() => isLoading = false);

    // 🔥 vérifier correct ou wrong
    bool isCorrect =
        result["resultat"] == "correct";

    // 🔥 message affiché
    String message = isCorrect

        ? "✅ Réponse correcte\n\n"
          "Output :\n${result["output"]}\n\n"
          "Points gagnés : ${result["points"]}"

        : "❌ Mauvaise réponse\n\n"
          "Output :\n${result["output"]}\n\n"
          "Erreur : ${result["error"] ?? ""}\n\n"
          "Points gagnés : ${result["points"] ?? 0}";

    // 🔥 afficher résultat
    ResultBottomSheet.show(

      context,

      message,

      isCorrect,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(widget.defi.titre),

        centerTitle: true,
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // 🔥 infos défi
            Card(

              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Padding(

                padding: const EdgeInsets.all(16),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      widget.defi.titre,

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.defi.description,
                    ),

                    const SizedBox(height: 10),

                    Row(

                      children: [

                        Chip(
                          label: Text(
                            widget.defi.langage,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Chip(
                          label: Text(
                            widget.defi.difficulte,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 éditeur code
            Expanded(

              child: Container(

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: Colors.black,

                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: TextField(

                  controller: codeController,

                  maxLines: null,

                  expands: true,

                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "monospace",
                    fontSize: 15,
                  ),

                  decoration: const InputDecoration(

                    border: InputBorder.none,

                    hintText:
                        "Écris ton code ici...",

                    hintStyle: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 bouton exécuter
            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(

                onPressed:
                    isLoading ? null : runCode,

                icon: isLoading

                    ? const SizedBox(

                        height: 20,
                        width: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )

                    : const Icon(
                        Icons.play_arrow,
                      ),

                label: Text(

                  isLoading
                      ? "Exécution..."
                      : "Exécuter",

                  style: const TextStyle(
                    fontSize: 16,
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