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

class _ClassementScreenState extends State<ClassementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;
  int? _currentUserId;

  // Palette
  static const _ink     = Color(0xFF1a1a18);
  static const _green   = Color(0xFF2d6a4f);
  static const _greenBg = Color(0xFFd8f3dc);
  static const _bg      = Color(0xFFF8F8F6);
  static const _line    = Color(0xFFEEECE6);

  @override
  void initState() {
    super.initState();
    _init();
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

    print(response.body);

    if (response.statusCode == 200) {

      final List data =
          jsonDecode(response.body);

      setState(() {

        _users =
            List<Map<String, dynamic>>
            .from(data);

        _loading = false;
      });

    } else {

      setState(() {

        _error = "Erreur serveur";

        _loading = false;
      });
    }

  } catch (e) {

    print(e);

    setState(() {

      _error =
          "Impossible de joindre le serveur";

      _loading = false;
    });
  }
}

  // Médailles pour le podium
  Widget _medal(int index) {
    if (index == 0) return const Text('🥇', style: TextStyle(fontSize: 22));
    if (index == 1) return const Text('🥈', style: TextStyle(fontSize: 22));
    if (index == 2) return const Text('🥉', style: TextStyle(fontSize: 22));
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(color: const Color(0xFFEEECE6), borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text('${index + 1}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink)),
      ),
    );
  }

  Color _niveauColor(String niveau) => switch (niveau.toLowerCase()) {
    'expert'        => const Color(0xFFc1121f),
    'intermediaire' => const Color(0xFF7d5a00),
    _               => _green,
  };

  Color _niveauBg(String niveau) => switch (niveau.toLowerCase()) {
    'expert'        => const Color(0xFFffe0e0),
    'intermediaire' => const Color(0xFFfff3cd),
    _               => _greenBg,
  };

  String _initiales(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (nom.isNotEmpty) return nom[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    // Rang de l'utilisateur connecté
    final myRank = _users.indexWhere((u) => u['id_user'] == _currentUserId);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
        title: const Text('Classement',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _ink, letterSpacing: -0.3)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _ink, size: 20),
            onPressed: _loadClassement,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DefisListScreen()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfilScreen()));
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green, strokeWidth: 2))
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_error!, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadClassement,
                      style: ElevatedButton.styleFrom(backgroundColor: _ink, foregroundColor: Colors.white, elevation: 0),
                      child: const Text('Réessayer'),
                    ),
                  ]),
                )
              : RefreshIndicator(
                  color: _green,
                  onRefresh: _loadClassement,
                  child: CustomScrollView(
                    slivers: [
                      // ── Ma position (si pas dans le top visible) ──
                      if (myRank > 10 || (myRank == -1 && _currentUserId != null))
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFd8f3dc),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _green.withOpacity(0.3)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.person_pin_rounded, color: _green, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                myRank >= 0 ? 'Votre rang : #${myRank + 1}' : 'Vous n\'apparaissez pas encore',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _green),
                              ),
                            ]),
                          ),
                        ),

                      // ── Liste ──────────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final user = _users[index];
                              final isMe = user['id_user'] == _currentUserId;
                              final nom  = user['nom'] as String? ?? '';
                              final pts  = user['points'] as int? ?? 0;
                              final niv  = user['niveau'] as String? ?? 'debutant';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isMe ? const Color(0xFFd8f3dc) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isMe ? _green.withOpacity(0.4) : _line,
                                    width: isMe ? 1.5 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      // Médaille / rang
                                      SizedBox(width: 36, child: _medal(index)),
                                      const SizedBox(width: 12),

                                      // Avatar initiales
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(
                                          color: isMe ? _green : _ink,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(_initiales(nom),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            )),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Nom + niveau
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Text(
                                                isMe ? 'Moi' : nom,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: isMe ? _green : _ink,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              if (isMe) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: _green,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text('vous',
                                                    style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                                                ),
                                              ],
                                            ]),
                                            const SizedBox(height: 3),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _niveauBg(niv),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                niv[0].toUpperCase() + niv.substring(1),
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _niveauColor(niv)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Points
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('$pts',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: isMe ? _green : _ink,
                                              letterSpacing: -0.5,
                                            )),
                                          const Text('pts',
                                            style: TextStyle(fontSize: 11, color: Color(0xFF9a9a90))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: _users.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}