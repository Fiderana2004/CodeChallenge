import 'package:flutter/material.dart';
import '../../models/defi.dart';
import 'code_editor_screen.dart';

class DefiDetailScreen extends StatelessWidget {
  final Defi defi;

  const DefiDetailScreen({
    super.key,
    required this.defi,
  });

  // Palette cohérente "Code Challenge"
  static const Color blueAccent   = Color(0xFF2563EB);
  static const Color cyanAccent   = Color(0xFF06B6D4);
  static const Color yellowAccent = Color(0xFFFBBF24);
  static const Color textDark     = Color(0xFF0F172A);
  static const Color textSlate    = Color(0xFF475569);
  static const Color bgGlobal      = Color(0xFFF8FAFC);
  static const Color lineBorder   = Color(0xFFE2E8F0);

  // Couleurs dynamiques selon la difficulté (Style LeetCode)
  Color _getDiffColor(String diff) => switch (diff.toLowerCase()) {
        'expert'        => const Color(0xFFDC2626), // Rouge
        'intermediaire' => const Color(0xFFD97706), // Orange / Ambre
        _               => const Color(0xFF059669), // Vert
      };

  Color _getDiffBg(String diff) => switch (diff.toLowerCase()) {
        'expert'        => const Color(0xFFFEF2F2),
        'intermediaire' => const Color(0xFFFFFBEB),
        _               => const Color(0xFFECFDF5),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGlobal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: lineBorder),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: textDark),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "DÉTAILS DU DÉFI",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textSlate, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), // padding bottom pour le bouton fixe
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CARTE EN-TÊTE DU DÉFI (TITRE + ICONE TERMINAL) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: lineBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [blueAccent, cyanAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.terminal_rounded, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  defi.titre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text("Catégorie : ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text(
                                      "Algorithme", // Tu pourras lier ceci à une vraie variable si dispo
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: blueAccent.withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- GRILLE D'INFORMATIONS / STATS (Style GitHub / LeetCode) ---
                Row(
                  children: [
                    // Difficulté Card
                    Expanded(
                      child: _buildInfoCard(
                        title: "DIFFICULTÉ",
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDiffBg(defi.difficulte),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            defi.difficulte.toUpperCase(),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _getDiffColor(defi.difficulte)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Récompense Card
                    Expanded(
                      child: _buildInfoCard(
                        title: "RÉCOMPENSE",
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙 ', style: TextStyle(fontSize: 14)),
                            Text(
                              "+${defi.points} PTS",
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: yellowAccent, letterSpacing: -0.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    // Temps estimé Card
                    Expanded(
                      child: _buildInfoCard(
                        title: "TEMPS MOYEN",
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 16, color: blueAccent),
                            SizedBox(width: 6),
                            Text("15 min", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Taux de réussite Card
                    Expanded(
                      child: _buildInfoCard(
                        title: "RÉUSSITE",
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.gpp_good_outlined, size: 16),
                            SizedBox(width: 6),
                            Text("84%", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // --- SECTION INSTRUCTIONS ---
                const Row(
                  children: [
                    Icon(Icons.description_outlined, size: 18, color: textSlate),
                    SizedBox(width: 8),
                    Text(
                      "ÉNONCÉ ET INSTRUCTIONS",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: textSlate, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: lineBorder),
                  ),
                  child: Text(
                    defi.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF334155),
                      height: 1.6, // Lecture ultra confortable pour les énoncés longs
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- BOUTON FIXE EN BAS AVEC EFFET FLOU / GRADIENT ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bgGlobal.withOpacity(0.0), bgGlobal, bgGlobal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CodeEditorScreen(defi: defi),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [blueAccent, cyanAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blueAccent.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Démarrer le défi",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper pour générer des cartes d'informations stylisées
  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lineBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}