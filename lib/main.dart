import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notifications_service.dart';
import 'services/stories_service.dart';
import 'screens/feed_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_outfits_screen.dart';
import 'screens/splash_screen.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
abstract class AppColors {
  // Paleta principal: lila / violeta bonito
  static const primary      = Color(0xFF7C3AED); // violet-600 – lila intenso
  static const primaryMed   = Color(0xFF9A5CF5); // violet-500 – lila medio
  static const primaryLight = Color(0xFFBB8AF9); // violet-400 – lavanda
  static const accentBg     = Color(0xFFF3E8FF); // violet-100 – fondo accent
  static const bgPage       = Color(0xFFF8F5FF); // violeta casi blanco
  static const bgCard       = Color(0xFFFFFFFF); // blanco
  static const textPrimary  = Color(0xFF1A0A3E); // oscuro con tinte morado
  static const textSec      = Color(0xFF5B3E9F); // morado medio
  static const textHint     = Color(0xFF9E8BC2); // morado apagado
  static const border       = Color(0xFFE4D5FF); // borde lila muy suave

  // Colores modo oscuro
  static const darkBgPage   = Color(0xFF0D0918);
  static const darkBgCard   = Color(0xFF1C1040);
  static const darkAccentBg = Color(0xFF251A4A);
  static const darkBorder   = Color(0xFF2D1F5E);
  static const darkText     = Color(0xFFF0E8FF);
  static const darkTextSec  = Color(0xFFBBA5E8);
  static const darkTextHint = Color(0xFF7B6FA8);
}

// Helper para obtener colores según el tema actual
extension AppColorsExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get colBgPage    => isDark ? AppColors.darkBgPage   : AppColors.bgPage;
  Color get colBgCard    => isDark ? AppColors.darkBgCard   : AppColors.bgCard;
  Color get colAccentBg  => isDark ? AppColors.darkAccentBg : AppColors.accentBg;
  Color get colBorder    => isDark ? AppColors.darkBorder   : AppColors.border;
  Color get colText      => isDark ? AppColors.darkText     : AppColors.textPrimary;
  Color get colTextSec   => isDark ? AppColors.darkTextSec  : AppColors.textSec;
  Color get colTextHint  => isDark ? AppColors.darkTextHint : AppColors.textHint;
}

// ─── App ───────────────────────────────────────────────────────────────────────
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try { await dotenv.load(fileName: '.env'); } catch (_) {}

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    runApp(_ErrorApp('Firebase no inicializado: $e'));
    return;
  }

  try { await NotificationsService.instance.init(scaffoldMessengerKey); } catch (_) {}
  try { await StoriesService.instance.deleteExpiredStories(); } catch (_) {}
  try { await initializeDateFormatting('es', null); } catch (_) {}

  if (!kIsWeb) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const OutfyApp(),
    ),
  );
}

class OutfyApp extends StatelessWidget {
  const OutfyApp({super.key});

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = GoogleFonts.dmSansTextTheme();

    final bgPage  = isDark ? AppColors.darkBgPage  : AppColors.bgPage;
    final bgCard  = isDark ? AppColors.darkBgCard  : AppColors.bgCard;
    final text    = isDark ? AppColors.darkText     : AppColors.textPrimary;
    final textSec = isDark ? AppColors.darkTextSec  : AppColors.textSec;
    final textHint= isDark ? AppColors.darkTextHint : AppColors.textHint;
    final border  = isDark ? AppColors.darkBorder   : AppColors.border;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      textTheme: base.copyWith(
        displayLarge:   base.displayLarge?.copyWith(color: text, fontWeight: FontWeight.w800),
        headlineMedium: base.headlineMedium?.copyWith(color: text, fontWeight: FontWeight.w700),
        titleLarge:     base.titleLarge?.copyWith(color: text, fontWeight: FontWeight.w700, fontSize: 17),
        titleMedium:    base.titleMedium?.copyWith(color: text, fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge:      base.bodyLarge?.copyWith(color: text, fontSize: 14, height: 1.5),
        bodyMedium:     base.bodyMedium?.copyWith(color: textSec, fontSize: 13, height: 1.5),
        labelSmall:     base.labelSmall?.copyWith(color: textHint, fontSize: 10, letterSpacing: 0),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ).copyWith(
        primary:   AppColors.primary,
        secondary: AppColors.primaryMed,
        surface:   bgCard,
      ),
      scaffoldBackgroundColor: bgPage,
      appBarTheme: AppBarTheme(
        backgroundColor: bgCard,
        elevation: 0,
        scrolledUnderElevation: 0.4,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: text, size: 22),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: text, letterSpacing: -0.3,
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
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgPage,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.dmSans(color: textHint, fontSize: 14),
        labelStyle: GoogleFonts.dmSans(color: textSec, fontSize: 14),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: textHint,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: border,
        labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgPage,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: border),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
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
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: text,
        iconColor: textSec,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : textHint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      title: 'OUTFY',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      themeMode: themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.1),
          ),
          child: child!,
        );
      },
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
    final bgCard = context.colBgCard;
    final border = context.colBorder;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        border: Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
              _navItem(context, 0, Icons.home_outlined, Icons.home_rounded, 'Inicio'),
              _navItem(context, 1, Icons.checkroom_outlined, Icons.checkroom_rounded, 'Armario'),
              _centerButton(),
              _navItem(context, 3, Icons.forum_outlined, Icons.forum_rounded, 'Foro'),
              _navItem(context, 4, Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
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
                color: on ? AppColors.accentBg.withValues(alpha: context.isDark ? 0.3 : 1.0) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                on ? activeIcon : icon,
                size: 21,
                color: on ? AppColors.primary : context.colTextHint,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                color: on ? AppColors.primary : context.colTextHint,
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
                    ? [const Color(0xFF4A0E9E), AppColors.primary]
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

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp(this.message);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A0A3E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white70, size: 56),
                const SizedBox(height: 16),
                const Text('Error al iniciar OUTFY',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
