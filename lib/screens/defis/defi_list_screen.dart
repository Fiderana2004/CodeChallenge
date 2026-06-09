import 'package:flutter/material.dart';
import 'package:mon_app/screens/classement/classement_screen.dart';
import 'package:mon_app/screens/profil/profil_screen.dart';

import '../../models/defi.dart';
import '../../services/defi_service.dart';

import '../../widgets/defi_card.dart';

import 'defi_detail_screen.dart';
import '../../widgets/app_bottom_nav.dart';

class DefisListScreen extends StatefulWidget {

  const DefisListScreen({super.key});

  @override
  State<DefisListScreen> createState() => _DefisListScreenState();
}

class _DefisListScreenState extends State<DefisListScreen> {

  late Future<List<Defi>> futureDefis;

  @override
  void initState() {
    super.initState();
    futureDefis = DefiService.getDefis();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      bottomNavigationBar: AppBottomNav(

  currentIndex: 0,

  onTap: (index) {

    // 🔥 Défis
    if (index == 0) return;

    // 🔥 Classement
    if (index == 1) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (_) => ClassementScreen(),
        ),
      );
    }

    // 🔥 Profil
    if (index == 2) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) => ProfilScreen(

            
          ),
        ),
      );
    }
  },
),
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("CodeChallenge"),
        centerTitle: true,
        elevation: 0,
      ),

      body: FutureBuilder<List<Defi>>(

        future: futureDefis,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {

            return const Center(
              child: Text("Aucun défi disponible"),
            );
          }

          final defis = snapshot.data!;

          return ListView.builder(

            itemCount: defis.length,

            itemBuilder: (context, index) {

              final defi = defis[index];

              return DefiCard(

                defi: defi,

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => DefiDetailScreen(defi: defi),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}