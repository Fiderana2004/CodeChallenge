import 'package:flutter/material.dart';
import 'package:mon_app/screens/classement/classement_screen.dart';
import 'package:mon_app/screens/profil/profil_screen.dart';

import '../../models/defi.dart';
import '../../services/defi_service.dart';
import 'defi_detail_screen.dart';
import '../../widgets/app_bottom_nav.dart';

class DefisListScreen extends StatefulWidget {
  const DefisListScreen({super.key});

  @override
  State<DefisListScreen> createState() => _DefisListScreenState();
}

class _DefisListScreenState extends State<DefisListScreen> {
  late Future<List<Defi>> futureDefis;

  List<Defi> _allDefis = [];
  List<Defi> _filteredDefis = [];

  String _searchQuery = "";
  String _selectedDifficulty = "tous";

  // STYLE
  static const Color blueAccent   = Color(0xFF2563EB);
  static const Color cyanAccent   = Color(0xFF06B6D4);
  static const Color yellowAccent = Color(0xFFFBBF24);
  static const Color textDark     = Color(0xFF0F172A);
  static const Color textSlate    = Color(0xFF64748B);
  static const Color bgGlobal     = Color(0xFFF8FAFC);
  static const Color lineBorder   = Color(0xFFE2E8F0);

  Color _getDiffColor(String diff) => switch (diff.toLowerCase()) {
        'expert'        => const Color(0xFFDC2626),
        'intermediaire' => const Color(0xFFD97706),
        _               => const Color(0xFF059669),
      };

  Color _getDiffBg(String diff) => switch (diff.toLowerCase()) {
        'expert'        => const Color(0xFFFEF2F2),
        'intermediaire' => const Color(0xFFFFFBEB),
        _               => const Color(0xFFECFDF5),
      };

  @override
  void initState() {
    super.initState();
    futureDefis = DefiService.getDefis();

    futureDefis.then((data) {
      setState(() {
        _allDefis = data;
        _filteredDefis = data;
      });
    });
  }

void _filterDefis(String query) {
  setState(() {
    _searchQuery = query;

    _filteredDefis = _allDefis.where((defi) {
      final matchTitle =
          defi.titre.toLowerCase().contains(query.toLowerCase());

      final matchDifficulty = _selectedDifficulty == "tous"
          ? true
          : defi.difficulte.toLowerCase() == _selectedDifficulty;

      return matchTitle && matchDifficulty;
    }).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGlobal,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Challenges",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
      ),

      body: Column(
        children: [

          // 🔍 SEARCH + FILTER
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              children: [
                TextField(
                  onChanged: _filterDefis,
                  decoration: InputDecoration(
                    hintText: "Rechercher un défi...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: lineBorder),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text("Niveau : "),
                    const SizedBox(width: 10),

                    DropdownButton<String>(
  value: _selectedDifficulty,
  items: const [
    DropdownMenuItem(
      value: "tous",
      child: Text("Tous"),
    ),
    DropdownMenuItem(
      value: "facile",
      child: Text("Facile"),
    ),
    DropdownMenuItem(
      value: "moyen",
      child: Text("Moyen"),
    ),
    DropdownMenuItem(
      value: "difficile",
      child: Text("Difficile"),
    ),
  ],
  onChanged: (value) {
    setState(() {
      _selectedDifficulty = value!;
      _filterDefis(_searchQuery);
    });
  },
),
                  ],
                ),
              ],
            ),
          ),

          // LISTE
          Expanded(
            child: _filteredDefis.isEmpty
                ? const Center(
                    child: Text("Aucun défi trouvé"),
                  )
                : ListView.builder(
                    itemCount: _filteredDefis.length,
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (context, index) {
                      final defi = _filteredDefis[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DefiDetailScreen(defi: defi),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: lineBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [blueAccent, cyanAccent],
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.code,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      defi.titre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getDiffBg(defi.difficulte),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            defi.difficulte,
                                            style: TextStyle(
                                              color: _getDiffColor(
                                                  defi.difficulte),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        Text("🪙 ${defi.points} pts"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ClassementScreen(),
              ),
            );
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}