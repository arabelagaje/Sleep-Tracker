import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/sleep_session.dart';
import '../providers/sleep_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'session_editor_sheet.dart';
import 'star_rating.dart';
import 'undo_snackbar.dart';

enum _MenuAction { edit, delete, add }

// Long-press callback for a night, with the finger's global position.
typedef SessionLongPress = void Function(SleepSession session, Offset position);

// Long-press menu for a night: its value, quick rating, Edit and Delete.
class SessionContextMenu extends StatefulWidget {
  const SessionContextMenu({super.key, required this.session, required this.onRate});

  final SleepSession session;
  final ValueChanged<int?> onRate;

  // Opens the menu next to [position] (global, usually the finger).
  static Future<void> show(
    BuildContext context, {
    required Offset position,
    required SleepSession session,
  }) async {
    final sleep = context.read<SleepProvider>();
    var current = session;
    final action = await _showAt<_MenuAction>(
      context,
      position,
      SessionContextMenu(
        session: session,
        onRate: (q) async {
          await sleep.rate(current, q);
          current = sleep.nights.firstWhere((s) => s.id == session.id, orElse: () => current);
        },
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case _MenuAction.edit:
        SessionEditorSheet.show(context, mode: EditorMode.editNight, session: current);
      case _MenuAction.delete:
        await sleep.delete(current);
        if (!context.mounted) return;
        UndoSnackbar.show(
          context,
          message: 'Session deleted',
          onUndo: () => sleep.restore(current),
        );
      case _MenuAction.add:
      case null:
        break;
    }
  }

  // Long-press on a day with nothing logged: offer to add that night.
  static Future<void> showAddNight(
    BuildContext context, {
    required Offset position,
    required DateTime date,
  }) async {
    final action = await _showAt<_MenuAction>(
      context,
      position,
      _MenuPanel(
        children: [_MenuItem(Icons.add, 'Add a night for ${fmtDay(date)}', _MenuAction.add)],
      ),
    );
    if (action == _MenuAction.add && context.mounted) {
      SessionEditorSheet.show(context, mode: EditorMode.create, initialDate: date);
    }
  }

  static Future<T?> _showAt<T>(BuildContext context, Offset position, Widget menu) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close menu',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (ctx, _, _) => CustomSingleChildLayout(
        delegate: _NearPointDelegate(position, MediaQuery.paddingOf(ctx)),
        child: menu,
      ),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(anim), child: child),
      ),
    );
  }

  @override
  State<SessionContextMenu> createState() => _SessionContextMenuState();
}

class _SessionContextMenuState extends State<SessionContextMenu> {
  late int? _quality = widget.session.quality;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = widget.session;
    return _MenuPanel(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fmtDay(s.nightDate),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${fmtClock(s.bedTime)} → ${fmtClock(s.wakeTime!)} · ${fmtDur(s.length)}',
                style: TextStyle(fontSize: 13, color: c.ink2),
              ),
              const SizedBox(height: 4),
              StarRating(
                value: _quality,
                size: 24,
                gap: 4,
                onChanged: (q) {
                  setState(() => _quality = q);
                  widget.onRate(q);
                },
              ),
            ],
          ),
        ),
        Divider(height: 9, color: c.line),
        const _MenuItem(Icons.edit_outlined, 'Edit', _MenuAction.edit),
        _MenuItem(Icons.delete_outline, 'Delete', _MenuAction.delete, color: c.danger),
      ],
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      elevation: 12,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
      child: SizedBox(
        width: 260,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(this.icon, this.label, this.action, {this.color});

  final IconData icon;
  final String label;
  final _MenuAction action;
  final Color? color;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () => Navigator.pop(context, action),
    child: SizedBox(
      height: 46,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, size: 18, color: color ?? context.colors.ink2),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    ),
  );
}

// Places the menu below-right of the finger, kept inside the safe area.
class _NearPointDelegate extends SingleChildLayoutDelegate {
  _NearPointDelegate(this.point, this.padding);

  final Offset point;
  final EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size child) {
    const margin = 12.0;
    var x = point.dx - child.width / 2;
    var y = point.dy + 8;
    // Not enough room below: open above the finger instead.
    if (y + child.height > size.height - padding.bottom - margin) y = point.dy - child.height - 8;
    x = x.clamp(margin, size.width - child.width - margin);
    y = y.clamp(padding.top + margin, size.height - child.height - padding.bottom - margin);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_NearPointDelegate old) => old.point != point || old.padding != padding;
}
