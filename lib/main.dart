import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DailyLineApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// THEMES
// ─────────────────────────────────────────────────────────────────────────────

enum AppTheme { ink, parchment, dusk, moss, ember }

extension AppThemeX on AppTheme {
  String get label {
    if (this == AppTheme.ink) return 'Ink';
    if (this == AppTheme.parchment) return 'Parchment';
    if (this == AppTheme.dusk) return 'Dusk';
    if (this == AppTheme.moss) return 'Moss';
    return 'Ember';
  }

  Color get bg {
    if (this == AppTheme.ink) return const Color(0xFF0D0D12);
    if (this == AppTheme.parchment) return const Color(0xFFF7F0E4);
    if (this == AppTheme.dusk) return const Color(0xFF0E0E1C);
    if (this == AppTheme.moss) return const Color(0xFF0C110E);
    return const Color(0xFF110B08);
  }

  Color get surface {
    if (this == AppTheme.ink) return const Color(0xFF15151E);
    if (this == AppTheme.parchment) return const Color(0xFFEDE4CF);
    if (this == AppTheme.dusk) return const Color(0xFF14142A);
    if (this == AppTheme.moss) return const Color(0xFF121A14);
    return const Color(0xFF1C1008);
  }

  Color get surfaceHigh {
    if (this == AppTheme.ink) return const Color(0xFF1E1E2A);
    if (this == AppTheme.parchment) return const Color(0xFFE5D9C0);
    if (this == AppTheme.dusk) return const Color(0xFF1C1C38);
    if (this == AppTheme.moss) return const Color(0xFF192118);
    return const Color(0xFF271508);
  }

  Color get text {
    if (this == AppTheme.ink) return const Color(0xFFF0EEE8);
    if (this == AppTheme.parchment) return const Color(0xFF1E1509);
    if (this == AppTheme.dusk) return const Color(0xFFECEAF8);
    if (this == AppTheme.moss) return const Color(0xFFE8F0E8);
    return const Color(0xFFF2EAE0);
  }

  Color get textMuted {
    if (this == AppTheme.ink) return const Color(0xFFF0EEE8).withOpacity(0.38);
    if (this == AppTheme.parchment) return const Color(0xFF1E1509).withOpacity(0.38);
    if (this == AppTheme.dusk) return const Color(0xFFECEAF8).withOpacity(0.38);
    if (this == AppTheme.moss) return const Color(0xFFE8F0E8).withOpacity(0.38);
    return const Color(0xFFF2EAE0).withOpacity(0.38);
  }

  Color get accent {
    if (this == AppTheme.ink) return const Color(0xFFD4AF6A);
    if (this == AppTheme.parchment) return const Color(0xFF8B5C1E);
    if (this == AppTheme.dusk) return const Color(0xFF9E87FF);
    if (this == AppTheme.moss) return const Color(0xFF6DBF82);
    return const Color(0xFFE8824A);
  }

  Color get onAccent {
    if (this == AppTheme.ink) return const Color(0xFF0D0D12);
    if (this == AppTheme.parchment) return const Color(0xFFF7F0E4);
    if (this == AppTheme.dusk) return const Color(0xFF0E0E1C);
    if (this == AppTheme.moss) return const Color(0xFF0C110E);
    return const Color(0xFF110B08);
  }

  Color get quoteMark {
    if (this == AppTheme.ink) return const Color(0xFFD4AF6A).withOpacity(0.22);
    if (this == AppTheme.parchment) return const Color(0xFF8B5C1E).withOpacity(0.22);
    if (this == AppTheme.dusk) return const Color(0xFF9E87FF).withOpacity(0.22);
    if (this == AppTheme.moss) return const Color(0xFF6DBF82).withOpacity(0.22);
    return const Color(0xFFE8824A).withOpacity(0.22);
  }

  Color get divider {
    if (this == AppTheme.ink) return const Color(0xFFF0EEE8).withOpacity(0.08);
    if (this == AppTheme.parchment) return const Color(0xFF1E1509).withOpacity(0.08);
    if (this == AppTheme.dusk) return const Color(0xFFECEAF8).withOpacity(0.08);
    if (this == AppTheme.moss) return const Color(0xFFE8F0E8).withOpacity(0.08);
    return const Color(0xFFF2EAE0).withOpacity(0.08);
  }

  Color get border {
    if (this == AppTheme.ink) return const Color(0xFFF0EEE8).withOpacity(0.09);
    if (this == AppTheme.parchment) return const Color(0xFF1E1509).withOpacity(0.09);
    if (this == AppTheme.dusk) return const Color(0xFFECEAF8).withOpacity(0.09);
    if (this == AppTheme.moss) return const Color(0xFFE8F0E8).withOpacity(0.09);
    return const Color(0xFFF2EAE0).withOpacity(0.09);
  }

  bool get isDark => this != AppTheme.parchment;

  ThemeData get themeData => ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: bg,
        colorScheme:
            (isDark ? const ColorScheme.dark() : const ColorScheme.light())
                .copyWith(primary: accent, surface: surface),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────

class Quote {
  Quote({
    required this.text,
    required this.author,
    required this.book,
    String? id,
  }) : id = id ?? UniqueKey().toString();

  final String id;
  String text;
  String author;
  String book;

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        id: j['id'] as String,
        text: j['text'] as String,
        author: j['author'] as String,
        book: (j['book'] ?? '') as String,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'author': author, 'book': book};
}

// ─────────────────────────────────────────────────────────────────────────────
// STORAGE
// ─────────────────────────────────────────────────────────────────────────────

class AppStorage {
  static const _qKey = 'dl_quotes';
  static const _iKey = 'dl_index';
  static const _dKey = 'dl_date';
  static const _tKey = 'dl_theme';

  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  static Future<List<Quote>> loadQuotes() async {
    final raw = (await _p).getString(_qKey);
    if (raw == null) return List.of(_seed);
    return (jsonDecode(raw) as List)
        .map((e) => Quote.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveQuotes(List<Quote> qs) async =>
      (await _p).setString(
          _qKey, jsonEncode(qs.map((q) => q.toJson()).toList()));

  static Future<int> loadIndex() async => (await _p).getInt(_iKey) ?? 0;
  static Future<void> saveIndex(int i) async =>
      (await _p).setInt(_iKey, i);

  static Future<String?> loadDate() async => (await _p).getString(_dKey);
  static Future<void> saveDate(String d) async =>
      (await _p).setString(_dKey, d);

  static Future<AppTheme> loadTheme() async {
    final name = (await _p).getString(_tKey);
    return AppTheme.values.firstWhere(
      (t) => t.name == name,
      orElse: () => AppTheme.ink,
    );
  }

  static Future<void> saveTheme(AppTheme t) async =>
      (await _p).setString(_tKey, t.name);

  static final _seed = [
    Quote(
        text: "You have power over your mind, not outside events.",
        author: "Marcus Aurelius",
        book: "Meditations"),
    Quote(
        text:
            "He who fears death will never do anything worthy of a living man.",
        author: "Seneca",
        book: "Letters from a Stoic"),
    Quote(
        text:
            "It is not that I'm so smart, it's just that I stay with problems longer.",
        author: "Albert Einstein",
        book: ""),
    Quote(
        text:
            "Make the best use of what is in your power, and take the rest as it happens.",
        author: "Epictetus",
        book: "Enchiridion"),
    Quote(
        text:
            "Begin at once to live, and count each separate day as a separate life.",
        author: "Seneca",
        book: "Letters from a Stoic"),
    Quote(
        text:
            "Waste no more time arguing what a good man should be. Be one.",
        author: "Marcus Aurelius",
        book: "Meditations"),
    Quote(
        text:
            "He suffers more than necessary, who suffers before it is necessary.",
        author: "Seneca",
        book: "Letters from a Stoic"),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────────────────────────────────────

class DailyLineApp extends StatefulWidget {
  const DailyLineApp({super.key});

  static _DailyLineAppState of(BuildContext ctx) =>
      ctx.findAncestorStateOfType<_DailyLineAppState>()!;

  @override
  State<DailyLineApp> createState() => _DailyLineAppState();
}

class _DailyLineAppState extends State<DailyLineApp> {
  AppTheme _theme = AppTheme.ink;

  @override
  void initState() {
    super.initState();
    AppStorage.loadTheme().then((t) => setState(() => _theme = t));
  }

  void setTheme(AppTheme t) {
    setState(() => _theme = t);
    AppStorage.saveTheme(t);
  }

  AppTheme get theme => _theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DailyLine',
      theme: _theme.themeData,
      home: QuoteScreen(appState: this),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key, required this.appState});
  final _DailyLineAppState appState;

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen>
    with TickerProviderStateMixin {
  List<Quote> _quotes = [];
  int _currentIndex = 0;
  bool _showAll = false;
  bool _loading = true;

  late AnimationController _entryCtrl;
  late AnimationController _quoteCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;
  late Animation<double> _quoteFade;
  late Animation<Offset> _quoteSlide;

  AppTheme get t => widget.appState.theme;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _quoteCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));

    _entryFade =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
            CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _quoteFade =
        CurvedAnimation(parent: _quoteCtrl, curve: Curves.easeOut);
    _quoteSlide =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
            CurvedAnimation(parent: _quoteCtrl, curve: Curves.easeOutCubic));

    _init();
  }

  Future<void> _init() async {
    final quotes = await AppStorage.loadQuotes();
    final saved = await AppStorage.loadIndex();
    final lastDate = await AppStorage.loadDate();
    final today = _today();

    int index =
        quotes.isEmpty ? 0 : saved.clamp(0, quotes.length - 1);
    if (lastDate != today && quotes.isNotEmpty) {
      index = (index + 1) % quotes.length;
      await AppStorage.saveDate(today);
      await AppStorage.saveIndex(index);
    } else if (lastDate == null) {
      await AppStorage.saveDate(today);
    }

    setState(() {
      _quotes = quotes;
      _currentIndex = index;
      _loading = false;
    });
    _entryCtrl.forward();
    _quoteCtrl.forward();
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String _formattedDate() {
    final parts = _today().split('-');
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[int.parse(parts[1]) - 1]} ${int.parse(parts[2])}';
  }

  Future<void> _persist() => AppStorage.saveQuotes(_quotes);

  // ── Skip: reverse fully → swap state while invisible → forward ──────────
  void _skip() {
    if (_quotes.isEmpty) return;
    _quoteCtrl
        .animateTo(0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn)
        .then((_) {
      final next = (_currentIndex + 1) % _quotes.length;
      setState(() => _currentIndex = next);
      AppStorage.saveIndex(next);
      AppStorage.saveDate(_today());
      // Wait one frame so the new widget is built at opacity=0 before fading in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _quoteCtrl.animateTo(1.0,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut);
      });
    });
  }

  void _openForm({Quote? existing}) async {
    final result = await showModalBottomSheet<Quote>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuoteFormSheet(existing: existing, theme: t),
    );
    if (result == null) return;
    setState(() {
      if (existing == null) {
        _quotes.add(result);
        _currentIndex = _quotes.length - 1;
      } else {
        final i = _quotes.indexWhere((q) => q.id == existing.id);
        if (i != -1) _quotes[i] = result;
      }
      _currentIndex =
          _currentIndex.clamp(0, (_quotes.length - 1).clamp(0, 9999));
    });
    await _persist();
  }

  void _delete(String id) async {
    setState(() {
      _quotes.removeWhere((q) => q.id == id);
      if (_quotes.isNotEmpty) {
        _currentIndex = _currentIndex.clamp(0, _quotes.length - 1);
      } else {
        _currentIndex = 0;
      }
    });
    await _persist();
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          size: 16,
          color: error ? Colors.red.shade300 : t.accent,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(msg,
              style: GoogleFonts.dmSans(
                  color: t.text.withOpacity(0.9), fontSize: 13)),
        ),
      ]),
      backgroundColor: t.surfaceHigh,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: t.border)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _export() async {
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(_quotes.map((q) => q.toJson()).toList())));
    if (!mounted) return;
    _toast('${_quotes.length} quotes copied to clipboard');
  }

  Future<void> _import() async {
    final raw = await showDialog<String>(
        context: context,
        builder: (_) => JsonImportDialog(theme: t));
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      final imported = list
          .map((e) => Quote.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _quotes = imported;
        _currentIndex = 0;
      });
      await _persist();
      if (!mounted) return;
      _toast('Imported ${imported.length} quotes');
    } catch (_) {
      if (!mounted) return;
      _toast('Invalid JSON — nothing imported', error: true);
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _quoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeQ = _quotes.isEmpty ? null : _quotes[_currentIndex];
    return Scaffold(
      backgroundColor: t.bg,
      body: _loading
          ? Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: t.accent, strokeWidth: 1.5)))
          : FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: SafeArea(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showAll
                        ? _AllQuotesPage(
                            key: const ValueKey('all'),
                            quotes: _quotes,
                            theme: t,
                            onBack: () => setState(() => _showAll = false),
                            onAdd: () => _openForm(),
                            onEdit: (q) => _openForm(existing: q),
                            onDelete: _delete,
                          )
                        : _MainPage(
                            key: const ValueKey('main'),
                            quote: safeQ,
                            theme: t,
                            date: _formattedDate(),
                            index: _currentIndex,
                            total: _quotes.length,
                            fadeAnim: _quoteFade,
                            slideAnim: _quoteSlide,
                            onSkip: _skip,
                            onAdd: () => _openForm(),
                            onViewAll: () =>
                                setState(() => _showAll = true),
                            onSettings: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => SettingsSheet(
                                theme: t,
                                onThemeChanged: widget.appState.setTheme,
                                onExport: _export,
                                onImport: _import,
                                onProfile: () =>
                                    _toast('Profile coming soon'),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────────────────────────────────────

class _MainPage extends StatelessWidget {
  const _MainPage({
    super.key,
    required this.quote,
    required this.theme,
    required this.date,
    required this.index,
    required this.total,
    required this.fadeAnim,
    required this.slideAnim,
    required this.onSkip,
    required this.onAdd,
    required this.onViewAll,
    required this.onSettings,
  });

  final Quote? quote;
  final AppTheme theme;
  final String date;
  final int index, total;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final VoidCallback onSkip, onAdd, onViewAll, onSettings;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(children: [
      // ── Header ──────────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 20, 0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DailyLine',
                style: GoogleFonts.cormorantGaramond(
                    color: t.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3)),
            Text(date,
                style: GoogleFonts.dmSans(
                    color: t.textMuted, fontSize: 12, letterSpacing: 0.2)),
          ]),
          const Spacer(),
          _HdrBtn(
              icon: Icons.format_list_bulleted_rounded,
              theme: t,
              onTap: onViewAll,
              badge: total > 0 ? '$total' : null),
          const SizedBox(width: 6),
          _HdrBtn(icon: Icons.add_rounded, theme: t, onTap: onAdd),
          const SizedBox(width: 6),
          _SettingsMenuBtn(theme: t, onSettings: onSettings),
        ]),
      ),

      // ── Quote ─────────────────────────────────────────────────────────
      Expanded(
        child: quote == null
            ? _EmptyState(theme: t, onAdd: onAdd)
            : FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                  position: slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Decorative quote mark
                        Text('\u201C',
                            style: GoogleFonts.cormorantGaramond(
                                color: t.quoteMark,
                                fontSize: 120,
                                height: 0.75)),
                        const SizedBox(height: 8),

                        // Quote body — no AnimatedSwitcher, parent handles transition
                        Text(
                          quote!.text,
                          style: GoogleFonts.cormorantGaramond(
                              color: t.text,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                              letterSpacing: -0.2),
                        ),

                        const SizedBox(height: 32),

                        // Attribution
                        Row(children: [
                          Container(
                              width: 24,
                              height: 1,
                              color: t.accent.withOpacity(0.5)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quote!.author,
                                  style: GoogleFonts.dmSans(
                                      color: t.accent,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3),
                                ),
                                if (quote!.book.isNotEmpty)
                                  Text(
                                    quote!.book,
                                    style: GoogleFonts.dmSans(
                                        color: t.textMuted, fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
      ),

      // ── Footer ──────────────────────────────────────────────────────────
      if (quote != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Row(children: [
            _ProgressDots(current: index, total: total, theme: t),
            const Spacer(),
            _SkipBtn(theme: t, onTap: onSkip),
          ]),
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _HdrBtn extends StatelessWidget {
  const _HdrBtn({
    required this.icon,
    required this.theme,
    required this.onTap,
    this.badge,
    this.active = false,
  });

  final IconData icon;
  final AppTheme theme;
  final VoidCallback onTap;
  final String? badge;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding:
            EdgeInsets.symmetric(horizontal: badge != null ? 12 : 11),
        decoration: BoxDecoration(
          color: active
              ? t.accent.withOpacity(0.15)
              : t.text.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active
                  ? t.accent.withOpacity(0.4)
                  : t.border,
              width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: t.text.withOpacity(0.7)),
          if (badge != null) ...[
            const SizedBox(width: 5),
            Text(badge!,
                style: GoogleFonts.dmSans(
                    color: t.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ]),
      ),
    );
  }
}

class _SettingsMenuBtn extends StatelessWidget {
  const _SettingsMenuBtn(
      {required this.theme, required this.onSettings});

  final AppTheme theme;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return PopupMenuButton<String>(
      offset: const Offset(0, 46),
      color: t.surfaceHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border)),
      onSelected: (v) {
        if (v == 'settings') onSettings();
      },
      itemBuilder: (_) => [
        _menuItem('profile', Icons.person_outline_rounded, 'Profile',
            '(coming soon)', t),
        _menuItem('settings', Icons.tune_rounded, 'Settings', null, t),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: t.text.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.border, width: 0.5),
        ),
        child: Icon(Icons.more_horiz_rounded,
            size: 18, color: t.text.withOpacity(0.7)),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String val, IconData ic, String lbl,
      String? sub, AppTheme t) =>
      PopupMenuItem(
        value: val,
        height: sub != null ? 52 : 44,
        child: Row(children: [
          Icon(ic, size: 16, color: t.textMuted),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lbl,
                    style: GoogleFonts.dmSans(
                        color: t.text.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                if (sub != null)
                  Text(sub,
                      style:
                          GoogleFonts.dmSans(color: t.textMuted, fontSize: 11)),
              ]),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTER COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots(
      {required this.current, required this.total, required this.theme});

  final int current, total;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final shown = total.clamp(0, 7);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(shown, (i) {
        final active = i == current % shown;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 5),
          width: active ? 18.0 : 5.0,
          height: 5,
          decoration: BoxDecoration(
            color: active ? t.accent : t.text.withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _SkipBtn extends StatefulWidget {
  const _SkipBtn({required this.theme, required this.onTap});

  final AppTheme theme;
  final VoidCallback onTap;

  @override
  State<_SkipBtn> createState() => _SkipBtnState();
}

class _SkipBtnState extends State<_SkipBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) {
        _c.reverse();
        widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: t.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Next',
                style: GoogleFonts.dmSans(
                    color: t.onAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1)),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 14, color: t.onAccent),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.onAdd});

  final AppTheme theme;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('\u201C',
              style: GoogleFonts.cormorantGaramond(
                  color: t.quoteMark, fontSize: 80, height: 0.8)),
          const SizedBox(height: 16),
          Text('Your collection is empty',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                  color: t.text.withOpacity(0.45),
                  fontSize: 22,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text('Add a quote to get started',
              style: GoogleFonts.dmSans(color: t.textMuted, fontSize: 13)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 13),
              decoration: BoxDecoration(
                  color: t.accent,
                  borderRadius: BorderRadius.circular(14)),
              child: Text('Add first quote',
                  style: GoogleFonts.dmSans(
                      color: t.onAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALL QUOTES PAGE
// ─────────────────────────────────────────────────────────────────────────────

class _AllQuotesPage extends StatelessWidget {
  const _AllQuotesPage({
    super.key,
    required this.quotes,
    required this.theme,
    required this.onBack,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Quote> quotes;
  final AppTheme theme;
  final VoidCallback onBack, onAdd;
  final void Function(Quote) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.text.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.border, width: 0.5),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: 17, color: t.text.withOpacity(0.7)),
            ),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('All Quotes',
                style: GoogleFonts.cormorantGaramond(
                    color: t.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w600)),
            Text(
                '${quotes.length} quote${quotes.length == 1 ? '' : 's'}',
                style:
                    GoogleFonts.dmSans(color: t.textMuted, fontSize: 11)),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 16, color: t.onAccent),
                const SizedBox(width: 5),
                Text('Add',
                    style: GoogleFonts.dmSans(
                        color: t.onAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),

      // List
      Expanded(
        child: quotes.isEmpty
            ? Center(
                child: Text('No quotes yet',
                    style: GoogleFonts.dmSans(
                        color: t.textMuted, fontSize: 14)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                itemCount: quotes.length,
                itemBuilder: (_, i) => _QuoteCard(
                  quote: quotes[i],
                  theme: t,
                  onEdit: () => onEdit(quotes[i]),
                  onDelete: () => onDelete(quotes[i].id),
                ),
              ),
      ),
    ]);
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({
    required this.quote,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  final Quote quote;
  final AppTheme theme;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Text('\u201C${quote.text}\u201D',
              style: GoogleFonts.cormorantGaramond(
                  color: t.text.withOpacity(0.88),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.55),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
        ),
        Container(height: 0.5, color: t.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
          child: Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(quote.author,
                      style: GoogleFonts.dmSans(
                          color: t.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2)),
                  if (quote.book.isNotEmpty)
                    Text(quote.book,
                        style: GoogleFonts.dmSans(
                            color: t.textMuted,
                            fontSize: 11,
                            letterSpacing: 0.1)),
                ])),
            _CardAction(
                icon: Icons.edit_outlined, theme: t, onTap: onEdit),
            const SizedBox(width: 6),
            _CardAction(
                icon: Icons.delete_outline_rounded,
                theme: t,
                onTap: onDelete,
                danger: true),
          ]),
        ),
      ]),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.theme,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final AppTheme theme;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: danger
              ? Colors.red.withOpacity(0.08)
              : t.text.withOpacity(0.05),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
              color: danger
                  ? Colors.red.withOpacity(0.18)
                  : t.border,
              width: 0.5),
        ),
        child: Icon(icon,
            size: 15,
            color: danger
                ? const Color(0xFFE57373)
                : t.text.withOpacity(0.4)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS SHEET
// ─────────────────────────────────────────────────────────────────────────────

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.theme,
    required this.onThemeChanged,
    required this.onExport,
    required this.onImport,
    required this.onProfile,
  });

  final AppTheme theme;
  final void Function(AppTheme) onThemeChanged;
  final VoidCallback onExport, onImport, onProfile;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: t.border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 28),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 32,
                height: 3.5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: t.text.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Profile tile
            _ProfileTile(
                theme: t,
                onTap: () {
                  Navigator.pop(context);
                  onProfile();
                }),
            const SizedBox(height: 24),

            _Label('Appearance', t),
            const SizedBox(height: 10),
            _ThemeSelector(current: theme, onChanged: onThemeChanged),

            const SizedBox(height: 24),

            _Label('Data', t),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _DataBtn(
                icon: Icons.ios_share_rounded,
                label: 'Export',
                theme: t,
                onTap: () {
                  Navigator.pop(context);
                  onExport();
                },
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _DataBtn(
                icon: Icons.download_rounded,
                label: 'Import',
                theme: t,
                onTap: () {
                  Navigator.pop(context);
                  onImport();
                },
              )),
            ]),
          ]),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.theme, required this.onTap});

  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: t.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.border, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.accent.withOpacity(0.15),
              border:
                  Border.all(color: t.accent.withOpacity(0.3), width: 0.5),
            ),
            child: Center(
                child: Text('D',
                    style: GoogleFonts.cormorantGaramond(
                        color: t.accent,
                        fontSize: 22,
                        fontWeight: FontWeight.w600))),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text('Profile',
                style: GoogleFonts.dmSans(
                    color: t.text.withOpacity(0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            Text('Personalization coming soon',
                style:
                    GoogleFonts.dmSans(color: t.textMuted, fontSize: 11)),
          ])),
          Icon(Icons.chevron_right_rounded, size: 18, color: t.textMuted),
        ]),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.theme);

  final String text;
  final AppTheme theme;

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: GoogleFonts.dmSans(
          color: theme.textMuted,
          fontSize: 10,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700));
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector(
      {required this.current, required this.onChanged});

  final AppTheme current;
  final void Function(AppTheme) onChanged;

  @override
  Widget build(BuildContext context) {
    final t = current;
    return Row(
      children: AppTheme.values.map((th) {
        final sel = th == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(th),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel
                      ? th.accent.withOpacity(0.15)
                      : t.text.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel
                        ? th.accent.withOpacity(0.6)
                        : t.border,
                    width: sel ? 1.5 : 0.5,
                  ),
                ),
                child: Column(children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: th.accent,
                      border: Border.all(
                          color: t.text.withOpacity(0.1), width: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(th.label,
                      style: GoogleFonts.dmSans(
                          color: sel ? th.accent : t.textMuted,
                          fontSize: 10,
                          fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w400)),
                ]),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DataBtn extends StatelessWidget {
  const _DataBtn({
    required this.icon,
    required this.label,
    required this.theme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AppTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: t.text.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border, width: 0.5),
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: t.accent),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.dmSans(
                  color: t.text.withOpacity(0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// JSON IMPORT DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class JsonImportDialog extends StatefulWidget {
  const JsonImportDialog({super.key, required this.theme});

  final AppTheme theme;

  @override
  State<JsonImportDialog> createState() => _JsonImportDialogState();
}

class _JsonImportDialogState extends State<JsonImportDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Dialog(
      backgroundColor: t.surfaceHigh,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: t.border)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Import JSON',
                  style: GoogleFonts.cormorantGaramond(
                      color: t.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text('Paste a JSON array to replace all quotes.',
                  style: GoogleFonts.dmSans(
                      color: t.textMuted, fontSize: 12, height: 1.5)),
              const SizedBox(height: 14),
              TextField(
                controller: _ctrl,
                maxLines: 7,
                style: GoogleFonts.robotoMono(
                    color: t.text.withOpacity(0.85), fontSize: 11.5),
                decoration: InputDecoration(
                  hintText:
                      '[{"id":"...","text":"...","author":"...","book":"..."}]',
                  hintStyle: GoogleFonts.robotoMono(
                      color: t.text.withOpacity(0.15), fontSize: 11),
                  filled: true,
                  fillColor: t.text.withOpacity(0.04),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: t.border, width: 0.5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: t.border, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: t.accent, width: 1)),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: GoogleFonts.dmSans(
                          color: t.textMuted, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context, _ctrl.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                    decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('Import',
                        style: GoogleFonts.dmSans(
                            color: t.onAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUOTE FORM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class QuoteFormSheet extends StatefulWidget {
  const QuoteFormSheet({super.key, this.existing, required this.theme});

  final Quote? existing;
  final AppTheme theme;

  @override
  State<QuoteFormSheet> createState() => _QuoteFormSheetState();
}

class _QuoteFormSheetState extends State<QuoteFormSheet> {
  late final TextEditingController _text, _author, _book;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.existing?.text ?? '');
    _author = TextEditingController(text: widget.existing?.author ?? '');
    _book = TextEditingController(text: widget.existing?.book ?? '');
  }

  @override
  void dispose() {
    _text.dispose();
    _author.dispose();
    _book.dispose();
    super.dispose();
  }

  void _submit() {
    if (_text.text.trim().isEmpty || _author.text.trim().isEmpty) return;
    Navigator.pop(
        context,
        Quote(
          id: widget.existing?.id,
          text: _text.text.trim(),
          author: _author.text.trim(),
          book: _book.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: t.border, width: 0.5)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 14, 24, MediaQuery.of(context).padding.bottom + 28),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                width: 32,
                height: 3.5,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                    color: t.text.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2)),
              )),
              Text(_editing ? 'Edit quote' : 'New quote',
                  style: GoogleFonts.cormorantGaramond(
                      color: t.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 22),
              _Field(
                  ctrl: _text,
                  label: 'Quote',
                  hint: 'Enter the quote…',
                  maxLines: 4,
                  theme: t),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: _Field(
                        ctrl: _author,
                        label: 'Author',
                        hint: 'Author name',
                        theme: t)),
                const SizedBox(width: 10),
                Expanded(
                    child: _Field(
                        ctrl: _book,
                        label: 'Book',
                        hint: 'Book (optional)',
                        theme: t)),
              ]),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                        color: t.accent,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(
                        _editing ? 'Save changes' : 'Add quote',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                            color: t.onAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.theme,
    this.maxLines = 1,
  });

  final TextEditingController ctrl;
  final String label, hint;
  final AppTheme theme;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: GoogleFonts.dmSans(
              color: t.textMuted,
              fontSize: 10,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700)),
      const SizedBox(height: 7),
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        style:
            GoogleFonts.dmSans(color: t.text.withOpacity(0.9), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.dmSans(color: t.text.withOpacity(0.2), fontSize: 15),
          filled: true,
          fillColor: t.text.withOpacity(0.04),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.border, width: 0.5)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.border, width: 0.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: t.accent, width: 1.5)),
        ),
      ),
    ]);
  }
} 