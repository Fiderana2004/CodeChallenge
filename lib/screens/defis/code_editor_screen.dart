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
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  void runCode() async {
    if (codeController.text.trim().isEmpty) {
      ResultBottomSheet.show(
        context,
        "⚠️ Veuillez écrire du code",
        false,
      );
      return;
    }

    setState(() => isLoading = true);

// Récupère la réponse de l'API de manière sécurisée
final result = await SoumissionService.runCode(
  widget.defi.langage,
  codeController.text,
  widget.defi.id,
);

setState(() => isLoading = false);

// Ajout d'un log pour débugger et voir ce que contient vraiment 'result'
print("DEBUG API RESULT: $result");

// Sécurisation de la comparaison (gère le null, les majuscules et les espaces)
bool isCorrect = result != null && 
    result["resultat"].toString().trim().toLowerCase() == "correct";

String message = isCorrect
    ? "✅ Réponse correcte\n\n"
      "Output :\n${result["output"]}\n\n"
      "Points gagnés : ${result["points"]}"
    : "❌ Mauvaise réponse\n\n"
      "Output :\n${result["output"] ?? "Aucun"}\n\n"
      "Erreur : ${result["error"] ?? "Aucune"}\n\n"
      "Points gagnés : ${result["points"] ?? 0}";

    ResultBottomSheet.show(
      context,
      message,
      isCorrect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Fond clair UI global
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "editor::${widget.defi.langage.toLowerCase()}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Infos du défi (Style carte épurée sans ombre lourde)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.defi.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      // Petit badge de langage typé Dev
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
                        ),
                        child: Text(
                          widget.defi.langage.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.defi.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // En-tête de la zone d'édition
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 6.0),
              child: Text(
                "SOURCE_CODE",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // 2. L'éditeur de Code (Style IDE sombre minimaliste)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A), // Bleu ardoise très foncé (style VS Code / TailWind)
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E293B), width: 1),
                ),
                child: TextField(
                  controller: codeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontFamily: "monospace",
                    fontSize: 14,
                    height: 1.5,
                  ),
                  cursorColor: const Color(0xFF2563EB), // Curseur bleu
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "// Écris ton script ici...",
                    hintStyle: TextStyle(
                      color: Color(0xFF475569),
                      fontFamily: "monospace",
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Bouton Exécuter moderne
            SizedBox(
              width: double.infinity,
              height: 52,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Bouton principal bleu
                  foregroundColor: const Color(0xFFFFFFFF), // Texte blanc
                  disabledBackgroundColor: const Color(0xFF93C5FD), // Bleu clair quand désactivé
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: isLoading ? null : runCode,
                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFFFFFF),
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text(
                  isLoading ? "Compilation en cours..." : "Exécuter le code",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
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