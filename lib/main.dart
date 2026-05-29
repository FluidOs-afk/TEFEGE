import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'services/notifications_service.dart';
import 'screens/feed_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_outfits_screen.dart';
import 'screens/splash_screen.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
abstract class AppColors {
  static const primary     = Color(0xFF1B6B44);
  static const primaryMed  = Color(0xFF3CB87A);
  static const primaryLight= Color(0xFF6DD4A0);
  static const accentBg    = Color(0xFFE8F5EE);
  static const bgPage      = Color(0xFFF4F7F5);
  static const bgCard      = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0D1B12);
  static const textSec     = Color(0xFF5A7066);
  static const textHint    = Color(0xFF9BB5AA);
  static const border      = Color(0xFFE2EDE8);
}

// ─── App ───────────────────────────────────────────────────────────────────────
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  await NotificationsService.instance.init(scaffoldMessengerKey);
  await initializeDateFormatting('es', null);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const OutfyApp(),
    ),
  );
}

class OutfyApp extends StatelessWidget {
  const OutfyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.dmSansTextTheme();
    return MaterialApp(
      title: 'OUTFY',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: base.copyWith(
          displayLarge:  base.displayLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
          headlineMedium:base.headlineMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          titleLarge:    base.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
          titleMedium:   base.titleMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
          bodyLarge:     base.bodyLarge?.copyWith(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
          bodyMedium:    base.bodyMedium?.copyWith(color: AppColors.textSec, fontSize: 13, height: 1.5),
          labelSmall:    base.labelSmall?.copyWith(color: AppColors.textHint, fontSize: 10, letterSpacing: 0),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
          primary:   AppColors.primary,
          secondary: AppColors.primaryMed,
          surface:   AppColors.bgCard,
        ),
        scaffoldBackgroundColor: AppColors.bgPage,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.bgCard,
          elevation: 0,
          scrolledUnderElevation: 0.4,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
          titleTextStyle: GoogleFonts.dmSans(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, letterSpacing: -0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.bgCard,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgPage,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: GoogleFonts.dmSans(color: AppColors.textHint, fontSize: 14),
          labelStyle: GoogleFonts.dmSans(color: AppColors.textSec, fontSize: 14),
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.border,
          labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.bgPage,
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: AppColors.border),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: StadiumBorder(),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── Main Shell ────────────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const FeedScreen(),
      const WardrobeScreen(),
      const AiOutfitsScreen(),
      const ForumScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _OutfyNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─── Bottom Navigation ─────────────────────────────────────────────────────────
class _OutfyNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  const _OutfyNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Inicio'),
              _navItem(1, Icons.checkroom_outlined, Icons.checkroom_rounded, 'Armario'),
              _centerButton(),
              _navItem(3, Icons.forum_outlined, Icons.forum_rounded, 'Foro'),
              _navItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final on = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: 44, height: 32,
              decoration: BoxDecoration(
                color: on ? AppColors.accentBg : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                on ? activeIcon : icon,
                size: 21,
                color: on ? AppColors.primary : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                color: on ? AppColors.primary : AppColors.textHint,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerButton() {
    final on = selectedIndex == 2;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(2),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: on
                    ? [const Color(0xFF0F4229), AppColors.primary]
                    : [AppColors.primary, AppColors.primaryMed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: on ? 0.5 : 0.30),
                  blurRadius: on ? 16 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              on ? Icons.auto_awesome_rounded : Icons.auto_awesome_outlined,
              color: Colors.white, size: 23,
            ),
          ),
        ),
      ),
    );
  }
}
