import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mon_app/screens/classement/classement_screen.dart';
import 'package:mon_app/screens/defis/defi_list_screen.dart';
import 'package:mon_app/widgets/app_bottom_nav.dart';
import '../../services/user_service.dart';

import 'package:mon_app/screens/auth/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
    with TickerProviderStateMixin {
  File? imageFile;
  String nom = "";
  String email = "";
  int points = 0;
  String niveau = "";
  bool _loading = true;
  bool _darkMode = false;

  final picker = ImagePicker();

  // Animations
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _statsController;
  late Animation<double> _pulseAnim;
  late Animation<double> _progressAnim;
  late Animation<double> _statsAnim;

  // ── Design tokens ──────────────────────────────────────
  static const _cyan = Color(0xFF00E5FF);
  static const _amber = Color(0xFFFFC107);
  static const _night = Color(0xFF0A0E17);
  static const _card = Color(0xFF1E293B);
  static const _cardLight = Color(0xFFF8FAFC);
  static const _borderDark = Color(0xFF2C3A4A);
  static const _borderLight = Color(0xFFE2E8F0);
  static const _muted = Color(0xFF64748B);
  static const _mutedLight = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _statsAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutBack),
    );

    _loadUser();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      setState(() {
        nom = prefs.getString("nom") ?? "";
        email = prefs.getString("email") ?? "";
        points = prefs.getInt("points") ?? 0;
        niveau = prefs.getString("niveau") ?? "debutant";
        _darkMode = prefs.getBool("dark_mode") ?? false;
      });

      final idUser = prefs.getInt("id_user") ?? 0;
      final savedPhotoPath = prefs.getString("photo_path_$idUser");

      if (savedPhotoPath != null) {
        final file = File(savedPhotoPath);
        if (await file.exists()) {
          setState(() => imageFile = file);
        }
      }
    } catch (e) {
      debugPrint("Erreur loadUser: $e");
    } finally {
      setState(() => _loading = false);
      // Lancer les animations après chargement
      Future.delayed(const Duration(milliseconds: 200), () {
        _progressController.forward(from: 0);
        _statsController.forward(from: 0);
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 85,
    );
    if (picked == null) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getInt("id_user") ?? 0;
      final fileName = 'photo_profil_$idUser.jpg';
      final permanentPath = path.join(appDir.path, fileName);
      await File(picked.path).copy(permanentPath);
      setState(() => imageFile = File(permanentPath));
      await prefs.setString("photo_path_$idUser", permanentPath);
    } catch (e) {
      debugPrint("ERREUR : $e");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getInt("id_user") ?? 0;
    final photoPath = prefs.getString("photo_path_$idUser");
    await prefs.clear();
    if (photoPath != null) {
      await prefs.setString("photo_path_$idUser", photoPath);
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }

  double get _progression => switch (niveau.toLowerCase()) {
        'expert' => 1.0,
        'intermediaire' => (points - 300) / (1000 - 300),
        _ => points / 300,
      }.clamp(0.0, 1.0);

  String get _prochainNiveau => switch (niveau.toLowerCase()) {
        'expert' => 'Niveau maximum atteint',
        'intermediaire' => '${1000 - points} pts restants → Expert',
        _ => '${300 - points} pts restants → Intermédiaire',
      };

  String get _initiales {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (nom.isNotEmpty) return nom[0].toUpperCase();
    return '?';
  }

  // Badge couleur selon niveau
  Color get _niveauColor => switch (niveau.toLowerCase()) {
        'expert' => const Color(0xFFFF6B35),
        'intermediaire' => _cyan,
        _ => const Color(0xFF22C55E),
      };

  IconData get _niveauIcon => switch (niveau.toLowerCase()) {
        'expert' => Icons.local_fire_department_rounded,
        'intermediaire' => Icons.bolt_rounded,
        _ => Icons.eco_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final avatarSize = isTablet ? 140.0 : size.width * 0.30;

    // Thème dynamique
    final bg = _darkMode ? _night : const Color(0xFFF1F5F9);
    final surface = _darkMode ? _card : Colors.white;
    final textPrimary = _darkMode ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = _darkMode ? _mutedLight : _muted;
    final border = _darkMode ? _borderDark : _borderLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        bottomNavigationBar: AppBottomNav(
          currentIndex: 2,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const DefisListScreen()));
            }
            if (index == 1) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => ClassementScreen()));
            }
          },
        ),
        body: _loading
            ? _buildLoader()
            : RefreshIndicator(
                color: _cyan,
                backgroundColor: surface,
                onRefresh: _loadUser,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ── Header avec vague ──
                      _buildHeader(avatarSize, size.width),

                      // ── Infos utilisateur ──
                      _buildUserInfo(textPrimary, textSecondary),

                      const SizedBox(height: 28),

                      // ── Cartes statistiques ──
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 40 : 20),
                        child: AnimatedBuilder(
                          animation: _statsAnim,
                          builder: (_, __) => Transform.translate(
                            offset:
                                Offset(0, 30 * (1 - _statsAnim.value)),
                            child: Opacity(
                              opacity: _statsAnim.value.clamp(0.0, 1.0),
                              child: _buildStatsRow(surface, border,
                                  textPrimary, textSecondary),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Barre de progression ──
                      if (niveau.toLowerCase() != 'expert')
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 40 : 20),
                          child: _buildProgressCard(
                              surface, border, textPrimary, textSecondary),
                        ),

                      const SizedBox(height: 20),

                      // ── Paramètres ──
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 40 : 20),
                        child: _buildSettingsSection(
                            surface, border, textPrimary),
                      ),

                      const SizedBox(height: 20),

                      // ── Bouton Logout ──
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 40 : 20),
                        child: _buildLogoutButton(),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // WIDGETS COMPOSANTS
  // ─────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset(
            'assets/images/logo_code_challenge.png',
            height: 36,
            width: 36,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: _cyan,
              strokeWidth: 3,
              backgroundColor: _cyan.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement du profil…',
            style: TextStyle(color: _muted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double avatarSize, double screenWidth) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Fond avec vague
        CustomPaint(
          size: Size(screenWidth, 260),
          painter: _WavePainter(darkMode: _darkMode),
        ),

        // Avatar centré
        Positioned(
          top: 80,
          child: _buildAvatar(avatarSize),
        ),

        // Espace pour le contenu en-dessous
        SizedBox(height: 260 + avatarSize / 2 + 10),
      ],
    );
  }

  Widget _buildAvatar(double size) {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) {
          return Container(
            width: size + 24,
            height: size + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _cyan.withOpacity(0.35 * _pulseAnim.value),
                  blurRadius: 30 * _pulseAnim.value,
                  spreadRadius: 6 * _pulseAnim.value,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anneau extérieur animé
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                width: size + 16,
                height: size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _cyan.withOpacity(0.6 * _pulseAnim.value),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Avatar principal
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _darkMode ? _card : Colors.white,
                border: Border.all(
                  color: _cyan,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: imageFile != null
                    ? Image.file(imageFile!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF0F172A),
                        child: Center(
                          child: Text(
                            _initiales,
                            style: TextStyle(
                              color: _cyan,
                              fontSize: size * 0.35,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // Bouton caméra
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _amber,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _darkMode ? _night : Colors.white,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _amber.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Color(0xFF0A0E17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(Color textPrimary, Color textSecondary) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          nom.isNotEmpty ? nom : '—',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 14),

        // Badge de niveau premium
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _niveauColor.withOpacity(0.2),
                _niveauColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _niveauColor.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_niveauIcon, size: 15, color: _niveauColor),
              const SizedBox(width: 6),
              Text(
                niveau.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _niveauColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(Color surface, Color border, Color textPrimary,
      Color textSecondary) {
    final stats = [
      _StatItem(
        icon: Icons.bolt_rounded,
        iconColor: _amber,
        label: 'Points',
        value: '$points',
      ),
      _StatItem(
        icon: Icons.emoji_events_rounded,
        iconColor: _cyan,
        label: 'Classement',
        value: '#—',
      ),
      _StatItem(
        icon: Icons.flag_rounded,
        iconColor: const Color(0xFF22C55E),
        label: 'Défis',
        value: '—',
      ),
    ];

    return Row(
      children: stats
          .map((s) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: s != stats.last ? 12 : 0,
                  ),
                  child: _buildStatCard(
                      s, surface, border, textPrimary, textSecondary),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildStatCard(_StatItem stat, Color surface, Color border,
      Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_darkMode ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: stat.iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: stat.iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: 11,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(Color surface, Color border, Color textPrimary,
      Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_darkMode ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: _amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      _prochainNiveau,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(_progression * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) {
              final val = _progression * _progressAnim.value;
              return Column(
                children: [
                  Stack(
                    children: [
                      // Fond de la barre
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      // Barre remplie avec dégradé
                      FractionallySizedBox(
                        widthFactor: val,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_amber, Color(0xFFFFD54F)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: _amber.withOpacity(0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(Color surface, Color border, Color textPrimary) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_darkMode ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingRow(
            icon: Icons.dark_mode_rounded,
            iconColor: _cyan,
            label: 'Mode sombre',
            trailing: Switch.adaptive(
              value: _darkMode,
              onChanged: (value) async {
                HapticFeedback.lightImpact();
                setState(() => _darkMode = value);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool("dark_mode", value);
              },
              activeColor: _amber,
              activeTrackColor: _amber.withOpacity(0.3),
            ),
            textColor: textPrimary,
            isLast: false,
            border: border,
          ),
          _buildSettingRow(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFF22C55E),
            label: 'Notifications',
            trailing: Icon(Icons.chevron_right_rounded,
                color: _muted, size: 20),
            textColor: textPrimary,
            isLast: false,
            border: border,
          ),
          _buildSettingRow(
            icon: Icons.shield_outlined,
            iconColor: _amber,
            label: 'Confidentialité',
            trailing: Icon(Icons.chevron_right_rounded,
                color: _muted, size: 20),
            textColor: textPrimary,
            isLast: true,
            border: border,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget trailing,
    required Color textColor,
    required bool isLast,
    required Color border,
  }) {
    return Container(
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: border, width: 0.8)),
            ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _logout();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFEF4444),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFFEF4444),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, size: 20, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────

class _StatItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });
}

// ─────────────────────────────────────────────────────────
// CUSTOM PAINTER — Vague header
// ─────────────────────────────────────────────────────────

class _WavePainter extends CustomPainter {
  final bool darkMode;
  _WavePainter({required this.darkMode});

  @override
  void paint(Canvas canvas, Size size) {
    // Dégradé principal
    final gradientPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          Color(0xFF00B8D9),
          Color(0xFF0A0E17),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final bgPath = Path()
      ..lineTo(0, size.height - 80)
      ..cubicTo(
        size.width * 0.25, size.height + 20,
        size.width * 0.75, size.height - 60,
        size.width, size.height - 30,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(bgPath, gradientPaint);

    // Ligne de vague lumineuse
    final wavePaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final wavePath = Path()
      ..moveTo(0, size.height - 80)
      ..cubicTo(
        size.width * 0.25, size.height + 20,
        size.width * 0.75, size.height - 60,
        size.width, size.height - 30,
      );

    canvas.drawPath(wavePath, wavePaint);

    // Points décoratifs (constellation)
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final dots = [
      Offset(size.width * 0.1, size.height * 0.25),
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.3, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.5),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.darkMode != darkMode;
}