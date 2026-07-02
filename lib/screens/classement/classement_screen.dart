import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mon_app/screens/defis/defi_list_screen.dart';
import 'package:mon_app/screens/profil/profil_screen.dart';
import 'package:mon_app/widgets/app_bottom_nav.dart';
import '../../config/api_config.dart';

class ClassementScreen extends StatefulWidget {
  const ClassementScreen({super.key});

  @override
  State<ClassementScreen> createState() => _ClassementScreenState();
}

class _ClassementScreenState extends State<ClassementScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;
  int? _currentUserId;

  // Animation Controller pour l'apparition du podium
  late AnimationController _animController;
  late Animation<double> _podiumScaleAnimation;

  // Palette Harmonisée "Code Challenge"
  static const Color _blueAccent  = Color(0xFF2563EB); // Bleu principal
  static const Color _cyanAccent  = Color(0xFF06B6D4); // Cyan
  static const Color _yellowAccent= Color(0xFFFBBF24); // Jaune Or
  static const Color _slateText   = Color(0xFF1E293B); // Texte principal sombre
  static const Color _blueBgLight = Color(0xFFEFF6FF); // Fond "Moi"
  static const Color _bgGlobal    = Color(0xFFF8FAFC); // Fond global M3 très clair
  static const Color _lineBorder  = Color(0xFFE2E8F0); // Bordures légères

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _podiumScaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _init();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('id_user');
    await _loadClassement();
  }

  Future<void> _loadClassement() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/classement'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
        _animController.forward(from: 0.0); // Déclenche l'animation du podium
      } else {
        setState(() {
          _error = "Erreur serveur";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Impossible de joindre le serveur";
        _loading = false;
      });
    }
  }

  // Initiales pour l'avatar
  String _initiales(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (nom.isNotEmpty) return nom[0].toUpperCase();
    return '?';
  }

  // Styles des Badges de Niveau
  Color _niveauColor(String niveau) => switch (niveau.toLowerCase()) {
        'expert'        => const Color(0xFFDC2626),
        'intermediaire' => const Color(0xFFD97706),
        _               => const Color(0xFF059669),
      };

  Color _niveauBg(String niveau) => switch (niveau.toLowerCase()) {
        'expert'        => const Color(0xFFFEF2F2),
        'intermediaire' => const Color(0xFFFFFBEB),
        _               => const Color(0xFFECFDF5),
      };

  @override
  Widget build(BuildContext context) {
    final myRank = _users.indexWhere((u) => u['id_user'] == _currentUserId);
    final top3 = _users.take(3).toList();
    final restOfUsers = _users.skip(3).toList();

    return Scaffold(
      backgroundColor: _bgGlobal,
      body: _loading
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(color: _blueAccent, strokeWidth: 3),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadClassement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.replay_rounded, size: 16),
                        label: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: _blueAccent,
                  onRefresh: _loadClassement,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // --- HEADER AVEC DÉGRADÉ & EFFET VAGUE + STYLISÉ ---
                      SliverAppBar(
                        expandedHeight: 380,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        pinned: true,
                        scrolledUnderElevation: 2,
                        automaticallyImplyLeading: false,
                        title: const Text(
                          'Leaderboard Ranks',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                            onPressed: _loadClassement,
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            children: [
                              // Dégradé de fond dynamique
                              ClipPath(
                                clipper: HeaderWaveClipper(),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_blueAccent, _cyanAccent, _yellowAccent],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              ),
                              // Rendu du Podium (Top 3)
                              Positioned(
                                bottom: 20,
                                left: 16,
                                right: 16,
                                child: ScaleTransition(
                                  scale: _podiumScaleAnimation,
                                  child: _buildPodium(top3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --- BANNIÈRE STATISTIQUE POSITION ACTUELLE "MOI" ---
                      if (myRank > 2 || (myRank == -1 && _currentUserId != null))
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _blueBgLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _blueAccent.withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: _blueAccent.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: _blueAccent,
                                  radius: 18,
                                  child: Icon(Icons.bolt_rounded, color: _yellowAccent, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        myRank >= 0 ? 'Votre position : Rang #${myRank + 1}' : 'Non classé',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _blueAccent),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        myRank >= 0 ? 'Continuez ainsi pour atteindre le podium ! 🔥' : 'Relevez des défis pour apparaître ici',
                                        style: TextStyle(fontSize: 12, color: _blueAccent.withOpacity(0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (myRank >= 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      '${_users[myRank]['points']} pts',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _slateText),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),

                      // --- LISTE DES AUTRES JOUEURS (RANG 4+) ---
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = restOfUsers[index];
                              final actualIndex = index + 3; // Réaligne l'index réel par rapport au Top 3 retiré
                              final isMe = user['id_user'] == _currentUserId;
                              final nom = user['nom'] as String? ?? '';
                              final pts = user['points'] as int? ?? 0;
                              final niv = user['niveau'] as String? ?? 'debutant';
                              final streak = user['streak'] as int? ?? 0; // Ajout d'une gestion de série (streak) dynamique

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? _blueBgLight : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isMe ? _blueAccent.withOpacity(0.4) : _lineBorder,
                                    width: isMe ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Indicateur de rang numérique épuré
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${actualIndex + 1}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Avatar d'initiales
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: isMe ? _blueAccent : const Color(0xFFF1F5F9),
                                        child: Text(
                                          _initiales(nom),
                                          style: TextStyle(
                                            color: isMe ? Colors.white : const Color(0xFF475569),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isMe ? 'Moi' : nom,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isMe ? _blueAccent : _slateText,
                                          ),
                                        ),
                                      ),
                                      // Indicateur de Série / Streak si présent (> 0)
                                      if (streak > 0)
                                        Row(
                                          children: [
                                            const Text('🔥', style: TextStyle(fontSize: 12)),
                                            Text('$streak', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                                            const SizedBox(width: 4),
                                          ],
                                        ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _niveauBg(niv),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            niv[0].toUpperCase() + niv.substring(1),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _niveauColor(niv)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$pts',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isMe ? _blueAccent : _slateText),
                                      ),
                                      const Text('pts', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: restOfUsers.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: _lineBorder, width: 1)),
        ),
        child: AppBottomNav(
          currentIndex: 1,
          onTap: (index) {
            if (index == 1) return;
            if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DefisListScreen()));
            if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilScreen()));
          },
        ),
      ),
    );
  }

  // --- COMPOSANT PODIUM VISUEL DYNAMIQUE ---
  Widget _buildPodium(List<Map<String, dynamic>> topUsers) {
    if (topUsers.isEmpty) return const SizedBox.shrink();

    final has1 = topUsers.isNotEmpty;
    final has2 = topUsers.length > 1;
    final has3 = topUsers.length > 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // RANG 2 (Gauche)
        if (has2) Expanded(child: _buildPodiumColumn(topUsers[1], 2, 110, _cyanAccent)),
        const SizedBox(width: 8),

        // RANG 1 (Centre - Plus haut)
        if (has1) Expanded(child: _buildPodiumColumn(topUsers[0], 1, 145, _yellowAccent)),
        const SizedBox(width: 8),

        // RANG 3 (Droite)
        if (has3) Expanded(child: _buildPodiumColumn(topUsers[2], 3, 90, Colors.orangeAccent)),
      ],
    );
  }

  // Widget interne pour chaque pilier du podium
  Widget _buildPodiumColumn(Map<String, dynamic> user, int rank, double height, Color accentColor) {
    final nom = user['nom'] as String? ?? '';
    final pts = user['points'] as int? ?? 0;
    final isMe = user['id_user'] == _currentUserId;

    String medalEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bulle profil joueur
        CircleAvatar(
          radius: rank == 1 ? 28 : 24,
          backgroundColor: isMe ? Colors.white : Colors.white.withOpacity(0.9),
          child: CircleAvatar(
            radius: rank == 1 ? 25 : 21,
            backgroundColor: isMe ? _blueAccent : const Color(0xFFF1F5F9),
            child: Text(
              _initiales(nom),
              style: TextStyle(color: isMe ? Colors.white : _slateText, fontSize: rank == 1 ? 14 : 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isMe ? 'Moi' : nom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        Text(
          '$pts pts',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9)),
        ),
        const SizedBox(height: 8),
        // Le bloc pilier physique du podium
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isMe ? 0.25 : 0.15),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  medalEmoji,
                  style: TextStyle(fontSize: rank == 1 ? 32 : 26),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

// --- CLIPPER POUR RECRÉER LA VAGUE DU DÉGRADÉ DU TOP BAR ---
class HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstStart = Offset(size.width / 4, size.height - 10);
    var firstEnd = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart = Offset(size.width * 3 / 4, size.height - 50);
    var secondEnd = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}