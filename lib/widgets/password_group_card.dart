import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/password_entry.dart';

class PasswordGroupCard extends StatefulWidget {
  final String username;
  final List<PasswordEntry> entries;
  final Function(PasswordEntry) onEdit;
  final Function(PasswordEntry) onDelete;
  final int index;

  const PasswordGroupCard({
    super.key,
    required this.username,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
    required this.index,
  });

  @override
  State<PasswordGroupCard> createState() => _PasswordGroupCardState();
}

class _PasswordGroupCardState extends State<PasswordGroupCard> {
  bool _expanded = true;
  final Map<String, bool> _visiblePasswords = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Group header
          _buildGroupHeader(),

          // Entries
          if (_expanded)
            ...widget.entries.asMap().entries.map(
              (e) => _buildEntryRow(e.value, e.key, widget.entries.length),
            ),
        ],
      ),
    ).animate(delay: (widget.index * 60).ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildGroupHeader() {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedRotation(
              turns: _expanded ? 0 : -0.25,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFFFB300),
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            _AccountCountBadge(count: widget.entries.length),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.username,
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${widget.entries.length} ${widget.entries.length == 1 ? 'حساب' : 'حسابات'}',
                  style: GoogleFonts.tajawal(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.username.isNotEmpty
                      ? widget.username[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.tajawal(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryRow(PasswordEntry entry, int i, int total) {
    final isLast = i == total - 1;
    final isVisible = _visiblePasswords[entry.id] == true;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : BorderRadius.zero,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Actions
          Row(
            children: [
              _ActionIcon(
                icon: Icons.delete_outline,
                color: Colors.red.withOpacity(0.7),
                onTap: () => widget.onDelete(entry),
              ),
              const SizedBox(width: 4),
              _ActionIcon(
                icon: Icons.edit_outlined,
                color: Colors.white38,
                onTap: () => widget.onEdit(entry),
              ),
            ],
          ),

          const Spacer(),

          // Entry info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.accountName,
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 6),
                // Password row
                GestureDetector(
                  onTap: () => setState(() {
                    _visiblePasswords[entry.id] = !isVisible;
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: entry.password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ كلمة السر'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy_rounded,
                          color: Color(0xFFFFB300),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(
                          isVisible ? entry.password : '••••••••',
                          style: GoogleFonts.robotoMono(
                            color: isVisible
                                ? const Color(0xFFFFD54F)
                                : Colors.white38,
                            fontSize: 13,
                            letterSpacing: isVisible ? 1 : 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (entry.website != null && entry.website!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.website!,
                    style: GoogleFonts.tajawal(
                      color: Colors.white24,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

class _AccountCountBadge extends StatelessWidget {
  final int count;
  const _AccountCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB300).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '+${count - 1}',
        style: GoogleFonts.tajawal(
          color: const Color(0xFFFFB300),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
