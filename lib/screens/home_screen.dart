import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/password_entry.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../widgets/developer_badge.dart';
import '../widgets/password_group_card.dart';
import 'auth_screen.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<PasswordEntry> _allEntries = [];
  List<PasswordEntry> _filtered   = [];
  final _searchController = TextEditingController();
  bool _isLoading    = true;
  bool _isSearching  = false;
  String? _ownerName;
  AppLifecycleState? _lastState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_lastState == AppLifecycleState.paused && state == AppLifecycleState.resumed) {
      _lockAndAuthenticate();
    }
    _lastState = state;
  }

  Future<void> _lockAndAuthenticate() async {
    final biometricAvailable = await AuthService.instance.isBiometricAvailable();
    if (!biometricAvailable) return;
    final result = await AuthService.instance.authenticateWithBiometrics();
    if (result != BiometricResult.success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final entries = await DatabaseService.instance.getAllEntries();
    final name    = await AuthService.instance.getOwnerName();
    setState(() {
      _allEntries = entries;
      _filtered   = entries;
      _ownerName  = name;
      _isLoading  = false;
    });
  }

  void _onSearch(String query) {
    if (query.isEmpty) { setState(() => _filtered = _allEntries); return; }
    final q = query.toLowerCase();
    setState(() {
      _filtered = _allEntries.where((e) =>
        e.username.toLowerCase().contains(q) ||
        e.accountName.toLowerCase().contains(q) ||
        (e.website?.toLowerCase().contains(q) ?? false)
      ).toList();
    });
  }

  Future<void> _addEntry() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditScreen()),
    );
    if (result == true) _loadData();
  }

  Future<void> _editEntry(PasswordEntry entry) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditScreen(entry: entry)),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteEntry(PasswordEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('حذف الحساب',
            style: GoogleFonts.tajawal(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right),
        content: Text('هل تريد حذف "${entry.accountName}"؟',
            style: GoogleFonts.tajawal(color: Colors.white70),
            textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.tajawal(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteEntry(entry.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الحذف')),
        );
      }
    }
  }

  Map<String, List<PasswordEntry>> get _grouped =>
      DatabaseService.instance.groupByUsername(_filtered);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final grouped    = _grouped;
    final sortedKeys = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textAlign: TextAlign.right,
                style: GoogleFonts.tajawal(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'بحث...',
                  hintStyle: GoogleFonts.tajawal(color: Colors.white38),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: _onSearch,
              )
            : const Text('SecretPass'),
        leading: IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) { _searchController.clear(); _filtered = _allEntries; }
            });
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _StatsChip(count: _allEntries.length),
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome banner — shows owner name from AuthService
          _WelcomeBanner(ownerName: _ownerName),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB300)))
                : _allEntries.isEmpty
                    ? _buildEmptyState()
                    : _filtered.isEmpty
                        ? _buildNoResults()
                        : _buildList(sortedKeys, grouped),
          ),

          // Shared developer badge
          const DeveloperBadge(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        backgroundColor: const Color(0xFFFFB300),
        foregroundColor: Colors.black,
        elevation: 8,
        child: const Icon(Icons.add_rounded, size: 28),
      ).animate().scale(delay: 300.ms),
    );
  }

  Widget _buildList(List<String> keys, Map<String, List<PasswordEntry>> grouped) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: keys.length,
      itemBuilder: (ctx, i) {
        final username = keys[i];
        final entries  = grouped[username]!;
        return PasswordGroupCard(
          username: username,
          entries: entries,
          onEdit: _editEntry,
          onDelete: _deleteEntry,
          index: i,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFB300).withOpacity(0.1),
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
            ),
            child: const Icon(Icons.lock_open_rounded, color: Color(0xFFFFB300), size: 36),
          ),
          const SizedBox(height: 24),
          Text('خزنتك فارغة',
              style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('اضغط + لإضافة أول كلمة سر',
              style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 14)),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildNoResults() => Center(
    child: Text('لا توجد نتائج',
        style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 16)),
  );
}

// ── Stats chip ────────────────────────────────────────────────────
class _StatsChip extends StatelessWidget {
  final int count;
  const _StatsChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
      ),
      child: Text(
        '$count حساب',
        style: GoogleFonts.tajawal(
            color: const Color(0xFFFFB300), fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Welcome banner — dynamic owner name ───────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final String? ownerName;
  const _WelcomeBanner({this.ownerName});

  @override
  Widget build(BuildContext context) {
    final name    = ownerName ?? 'Eng. Abdullah Esh';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : 'AE';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFB300).withOpacity(0.08),
            const Color(0xFF1C1A10).withOpacity(0.6),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('أهلاً وسهلاً 👋',
                    style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFFFB300),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.3),
                  blurRadius: 12, spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}
