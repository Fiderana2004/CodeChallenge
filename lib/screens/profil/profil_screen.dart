import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mon_app/screens/classement/classement_screen.dart';
import 'package:mon_app/screens/defis/defi_list_screen.dart';
import 'package:mon_app/widgets/app_bottom_nav.dart';
import '../../services/user_service.dart';


class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  File? imageFile;
  String nom = "";
  String email = "";
  int points = 0;
  String niveau = "";
  bool _loading = true;

  final picker = ImagePicker();

  // Palette
  static const _ink     = Color(0xFF1a1a18);
  static const _green   = Color(0xFF2d6a4f);
  static const _greenBg = Color(0xFFd8f3dc);
  static const _bg      = Color(0xFFF8F8F6);
  static const _line    = Color(0xFFEEECE6);

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

Future<void> _loadUser() async {

  setState(() => _loading = true);

  try {

    final prefs = await SharedPreferences.getInstance();

    setState(() {

      nom = prefs.getString("nom") ?? "";

      email = prefs.getString("email") ?? "";

      points = prefs.getInt("points") ?? 0;

      niveau = prefs.getString("niveau") ?? "debutant";
    });

  } catch (e) {

    print(e);

  } finally {

    setState(() => _loading = false);
  }
}

Future<void> _pickImage() async {

  final picked =
  await picker.pickImage(

    source: ImageSource.gallery,
  );

  if (picked != null) {

    final file = File(picked.path);

    setState(() {
      imageFile = file;
    });

    final prefs =
    await SharedPreferences.getInstance();

    int? idUser =
    prefs.getInt("id_user");

    if (idUser != null) {

      await UserService.uploadPhoto(
        idUser,
        file,
      );
    }
  }
}

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  // Couleur et libellé selon niveau
  Color get _niveauColor => switch (niveau.toLowerCase()) {
    'expert'        => const Color(0xFFc1121f),
    'intermediaire' => const Color(0xFF7d5a00),
    _               => _green,
  };

  Color get _niveauBg => switch (niveau.toLowerCase()) {
    'expert'        => const Color(0xFFffe0e0),
    'intermediaire' => const Color(0xFFfff3cd),
    _               => _greenBg,
  };

  String get _niveauLabel => switch (niveau.toLowerCase()) {
    'expert'        => '🔥 Expert',
    'intermediaire' => '⚡ Intermédiaire',
    _               => '🌱 Débutant',
  };

  // Progression vers le niveau suivant
  double get _progression => switch (niveau.toLowerCase()) {
    'expert'        => 1.0,
    'intermediaire' => (points - 300) / (1000 - 300),
    _               => points / 300,
  }.clamp(0.0, 1.0);

  String get _prochainNiveau => switch (niveau.toLowerCase()) {
    'expert'        => 'Niveau max atteint',
    'intermediaire' => '${1000 - points} pts → Expert',
    _               => '${300 - points} pts → Intermédiaire',
  };

  // Initiales pour avatar fallback
  String get _initiales {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (nom.isNotEmpty) return nom[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
        title: const Text('Profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _ink, letterSpacing: -0.3)),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFc1121f)),
            label: const Text('Déconnexion',
              style: TextStyle(fontSize: 13, color: Color(0xFFc1121f), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DefisListScreen()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClassementScreen()));
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green, strokeWidth: 2))
          : RefreshIndicator(
              color: _green,
              onRefresh: _loadUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── Avatar ──────────────────────────────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _line, width: 3),
                          ),
                          child: ClipOval(
                            child: imageFile != null
                              ? Image.file(imageFile!, fit: BoxFit.cover)
                              : Container(
                                  color: _ink,
                                  child: Center(
                                    child: Text(_initiales,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -1,
                                      )),
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          bottom: 2, right: 2,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: _ink,
                                shape: BoxShape.circle,
                                border: Border.all(color: _bg, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded,
                                size: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Nom ─────────────────────────────────
                    Text(nom.isNotEmpty ? nom : '—',
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800,
                        color: _ink, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500])),

                    const SizedBox(height: 12),

                    // ── Badge niveau ────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _niveauBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_niveauLabel,
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: _niveauColor)),
                    ),

                    const SizedBox(height: 28),

                    // ── Stats ────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _line),
                      ),
                      child: Column(
                        children: [
                          _statRow(
                            icon: Icons.bolt_rounded,
                            iconColor: const Color(0xFF7d5a00),
                            iconBg: const Color(0xFFfff3cd),
                            label: 'Points accumulés',
                            value: '$points pts',
                            valueColor: _green,
                            divider: true,
                          ),
                          _statRow(
                            icon: Icons.emoji_events_rounded,
                            iconColor: _niveauColor,
                            iconBg: _niveauBg,
                            label: 'Niveau actuel',
                            value: niveau.isEmpty ? '—' : niveau[0].toUpperCase() + niveau.substring(1),
                            divider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Progression ──────────────────────────
                    if (niveau.toLowerCase() != 'expert')
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Progression',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink)),
                                Text(_prochainNiveau,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progression,
                                minHeight: 8,
                                backgroundColor: _line,
                                valueColor: const AlwaysStoppedAnimation<Color>(_green),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('${(_progression * 100).toStringAsFixed(0)}% vers le niveau suivant',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    Color? valueColor,
    required bool divider,
  }) =>
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF5a5a54), fontWeight: FontWeight.w500)),
              ),
              Text(value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? _ink,
                  letterSpacing: -0.3,
                )),
            ],
          ),
        ),
        if (divider) Divider(height: 1, color: _line, indent: 18, endIndent: 18),
      ],
    );
}