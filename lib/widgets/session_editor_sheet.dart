import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sleep_session.dart';
import '../providers/sleep_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/sleep_stats.dart';
import 'star_rating.dart';
import 'undo_snackbar.dart';

enum EditorMode { create, editNight, editActive }

// What the sheet did, so the caller can show the right toast.
typedef _Outcome = ({String message, SleepSession? deleted});

class SessionEditorSheet extends StatefulWidget {
  const SessionEditorSheet({super.key, required this.mode, this.session, this.initialDate});

  final EditorMode mode;
  final SleepSession? session;
  final DateTime? initialDate; // pre-fill when adding from a calendar day

  static Future<void> show(
    BuildContext context, {
    required EditorMode mode,
    SleepSession? session,
    DateTime? initialDate,
  }) async {
    final sleep = context.read<SleepProvider>();
    final outcome = await showModalBottomSheet<_Outcome>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SessionEditorSheet(mode: mode, session: session, initialDate: initialDate),
    );
    if (outcome == null || !context.mounted) return;
    final deleted = outcome.deleted;
    UndoSnackbar.show(
      context,
      message: outcome.message,
      onUndo: deleted == null ? null : () => sleep.restore(deleted),
    );
  }

  @override
  State<SessionEditorSheet> createState() => _SessionEditorSheetState();
}

class _SessionEditorSheetState extends State<SessionEditorSheet> {
  late DateTime _bed;
  DateTime? _wake;
  int? _quality;
  late final TextEditingController _notes;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    if (s != null) {
      _bed = s.bedTime;
      _wake = s.wakeTime;
      _quality = s.quality;
    } else {
      // A night is named by its wake date: bed the evening before, up at 7.
      final day = dateOnly(widget.initialDate ?? DateTime.now());
      _bed = addDays(day, -1).add(const Duration(hours: 23));
      _wake = day.add(const Duration(hours: 7));
    }
    _notes = TextEditingController(text: s?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  bool get _wakeOk => _wake == null ? widget.mode == EditorMode.editActive : _wake!.isAfter(_bed);

  String get _title => switch (widget.mode) {
    EditorMode.create => 'Add a past night',
    EditorMode.editActive => 'Current session',
    EditorMode.editNight => fmtLong(widget.session!.nightDate),
  };

  Future<DateTime?> _pick(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final notes = _notes.text.trim();
    final base = widget.session ?? SleepSession(bedTime: _bed, createdAt: DateTime.now());
    final session = base.copyWith(
      bedTime: _bed,
      wakeTime: _wake,
      clearWakeTime: _wake == null,
      quality: _quality,
      clearQuality: _quality == null,
      notes: notes,
      clearNotes: notes.isEmpty,
    );
    await context.read<SleepProvider>().save(session);
    if (!mounted) return;
    Navigator.pop<_Outcome>(context, (
      message: switch (widget.mode) {
        EditorMode.create => 'Night added',
        EditorMode.editActive when _wake != null => 'Session saved',
        _ => 'Changes saved',
      },
      deleted: null,
    ));
  }

  Future<void> _delete() async {
    setState(() => _busy = true);
    final s = widget.session!;
    await context.read<SleepProvider>().delete(s);
    if (!mounted) return;
    Navigator.pop<_Outcome>(context, (message: 'Session deleted', deleted: s));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dur = _wake == null ? 'In progress' : (_wakeOk ? fmtDur(_wake!.difference(_bed)) : '—');
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _title,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: Icon(Icons.close, color: c.ink2),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _TimeField(
                          label: 'Went to bed',
                          value: _bed,
                          onTap: () async {
                            final d = await _pick(_bed);
                            if (d != null) setState(() => _bed = d);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeField(
                          label: 'Woke up',
                          value: _wake,
                          placeholder: 'Still sleeping',
                          onClear: widget.mode == EditorMode.editActive && _wake != null
                              ? () => setState(() => _wake = null)
                              : null,
                          onTap: () async {
                            final d = await _pick(_wake ?? DateTime.now());
                            if (d != null) setState(() => _wake = d);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Duration', style: TextStyle(color: c.ink2, fontSize: 14)),
                        Text(
                          dur,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (!_wakeOk) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Wake time needs to be after bed time.',
                      style: TextStyle(color: c.danger, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const _FieldLabel('How did you sleep?'),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StarRating(
                        value: _quality,
                        size: 28,
                        gap: 8,
                        onChanged: (v) => setState(() => _quality = v),
                      ),
                      TextButton(
                        onPressed: _quality == null ? null : () => setState(() => _quality = null),
                        child: Text(_quality == null ? 'Not rated' : 'Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _FieldLabel('Notes'),
                  TextField(
                    controller: _notes,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Dreams, wake-ups, how you feel…',
                      filled: true,
                      fillColor: c.surface2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: c.line),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule, size: 16, color: c.ink2),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Times, rating and notes stay editable forever — come back any time.',
                          style: TextStyle(fontSize: 12.5, color: c.ink2, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.line)),
            ),
            child: Row(
              children: [
                if (widget.mode != EditorMode.create)
                  TextButton.icon(
                    onPressed: _busy ? null : _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: c.danger,
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                const Spacer(),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: FilledButton(
                    onPressed: _busy || !_wakeOk ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: c.accent,
                      foregroundColor: c.onAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: context.colors.ink2,
      ),
    ),
  );
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder = '',
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String placeholder;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label),
        Material(
          color: c.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: c.line),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: value == null
                        ? Text(placeholder, style: TextStyle(color: c.ink2, fontSize: 14))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fmtDay(value!), style: TextStyle(color: c.ink2, fontSize: 12)),
                              Text(
                                fmtClock(value!),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                  if (onClear != null)
                    GestureDetector(
                      onTap: onClear,
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: c.ink2,
                        semanticLabel: 'Clear wake time',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
