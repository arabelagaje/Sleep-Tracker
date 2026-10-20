# Sleep Tracker — UI Spec

Folder structure and widget list (props and states) for the UI. Visual reference: `prototypes/index.html`.

"Session" in prop types means one sleep session from the app's own model.

## Folder structure

```
lib/
├── screens/
│   ├── shell/
│   │   ├── app_shell.dart
│   │   ├── app_header.dart
│   │   ├── app_bottom_nav.dart
│   │   └── overflow_menu.dart
│   ├── tonight/
│   │   ├── tonight_screen.dart
│   │   └── widgets/
│   │       ├── sleep_orb.dart
│   │       ├── live_timer_text.dart
│   │       ├── usual_bedtime_line.dart
│   │       ├── bed_wake_cards.dart
│   │       ├── last_night_card.dart
│   │       └── week_bars_card.dart
│   ├── log/
│   │   ├── log_screen.dart
│   │   └── widgets/
│   │       ├── log_view_toggle.dart
│   │       ├── log_filter_chips.dart
│   │       ├── timeline_axis.dart
│   │       ├── week_group_header.dart
│   │       ├── timeline_row.dart
│   │       ├── timeline_lane.dart
│   │       ├── month_calendar.dart
│   │       ├── calendar_day_cell.dart
│   │       └── calendar_legend.dart
│   ├── insights/
│   │   ├── insights_screen.dart
│   │   └── widgets/
│   │       ├── summary_card.dart
│   │       ├── period_selector.dart
│   │       ├── stat_tile.dart
│   │       └── bed_wake_chart.dart
│   ├── settings/
│   │   ├── settings_screen.dart
│   │   └── widgets/
│   │       ├── settings_group.dart
│   │       ├── sleep_goal_stepper.dart
│   │       ├── settings_switch_tile.dart
│   │       ├── settings_action_tile.dart
│   │       └── theme_mode_selector.dart
│   └── about/
│       └── about_screen.dart
└── widgets/
    ├── session_editor_sheet.dart
    ├── star_rating.dart
    ├── section_card.dart
    ├── segmented_control.dart
    ├── empty_note.dart
    ├── session_context_menu.dart
    ├── rate_prompt_dialog.dart
    └── undo_snackbar.dart
```

## Widgets

### Shell

**AppShell**
- Props: none
- States: loading · ready (selected tab: Tonight / Log / Insights)

**AppHeader**
| Prop | Type | Meaning |
|---|---|---|
| `now` | `DateTime` | Date line and greeting |
| `onOpenMenu` | `VoidCallback` | Opens the ⋮ menu |
- States: greeting is morning / afternoon / evening

**OverflowMenu**
| Prop | Type | Meaning |
|---|---|---|
| `onSettings` | `VoidCallback` | Opens Settings |
| `onAbout` | `VoidCallback` | Opens About |
- States: closed · open

**AppBottomNav**
| Prop | Type | Meaning |
|---|---|---|
| `index` | `int` | Selected tab |
| `onChanged` | `ValueChanged<int>` | Tab tapped |
- States: Tonight / Log / Insights selected

### Tonight

**TonightScreen**
- Props: none
- States: no nights · early (fewer than 3 nights) · normal · sleeping

**SleepOrb**
| Prop | Type | Meaning |
|---|---|---|
| `isSleeping` | `bool` | Which face to show |
| `startedAt` | `DateTime?` | Start of the running session |
| `onPressed` | `VoidCallback` | Start or stop |
| `onLongPress` | `VoidCallback?` | Sleeping only: cancel the session (asks to confirm) |
- States: awake ("Start sleep") · sleeping (live timer, "Tap when you wake", "Hold to cancel")

**LiveTimerText**
| Prop | Type | Meaning |
|---|---|---|
| `startedAt` | `DateTime` | Counts up from here |
| `style` | `TextStyle?` | Text style |
- States: running

**UsualBedtimeLine**
| Prop | Type | Meaning |
|---|---|---|
| `usualBedtime` | `TimeOfDay?` | Null when there isn't enough data |
| `nightsUsed` | `int` | Shown as "last N nights" |
| `isSleeping` | `bool` | Swaps in the sleeping message |
- States: not enough data ("shows up after 3 nights") · normal · sleeping

**BedWakeCards**
| Prop | Type | Meaning |
|---|---|---|
| `bedTime` | `DateTime?` | Latest or current bed time |
| `wakeTime` | `DateTime?` | Latest wake time |
| `isSleeping` | `bool` | Changes the labels |
| `onTap` | `VoidCallback?` | Opens the editor |
- States: no data (`—`, not tappable) · last session · sleeping ("In bed since", "Sleeping…")

**LastNightCard**
| Prop | Type | Meaning |
|---|---|---|
| `session` | Session? | Latest finished session |
| `deltaVsAverage` | `Duration?` | Null hides the comparison |
| `onEdit` | `VoidCallback` | Opens the editor |
| `onRate` | `ValueChanged<int?>` | Rate or clear |
- States: empty (first-night message) · normal · no comparison yet · rated / unrated · with / without note

**WeekBarsCard**
| Prop | Type | Meaning |
|---|---|---|
| `days` | list of 7 (date + Session?) | Oldest to today |
| `goal` | `Duration` | Goal line and bar style |
| `onTapSession` | `ValueChanged<Session>` | Opens the editor |
| `onLongPressSession` | (Session, Offset) | Opens the context menu |
| `onLongPressEmptyDay` | (DateTime, Offset) | "Add a night for …" menu |
- States: no nights · early ("N of 7 nights logged") · normal ("avg … · x/y met goal")
- Bar states: met goal · under goal · empty day

### Log

**LogScreen**
- Props: none
- States:
  - view: timeline / calendar
  - filter: all / unrated / with notes / under goal
  - visible month
  - no nights · no filter results · normal

**LogViewToggle**
| Prop | Type | Meaning |
|---|---|---|
| `value` | timeline / month | Current view |
| `onChanged` | callback | View switched |
- States: Timeline · Calendar

**LogFilterChips**
| Prop | Type | Meaning |
|---|---|---|
| `value` | all / unrated / withNotes / underGoal | Current filter |
| `onChanged` | callback | Filter switched |
- States: one chip selected

**TimelineAxis**
- Props: none
- States: static (6p … 12p)

**WeekGroupHeader**
| Prop | Type | Meaning |
|---|---|---|
| `label` | `String` | "This week", "Last week", … |
| `average` | `Duration?` | Week average |
- States: with / without average

**TimelineRow**
| Prop | Type | Meaning |
|---|---|---|
| `session` | Session | The night shown |
| `goal` | `Duration` | Met / under styling |
| `onTap` | `VoidCallback` | Opens the editor |
| `onRate` | `ValueChanged<int?>` | Inline rating |
| `onLongPress` | `ValueChanged<Offset>` | Context menu (anywhere on the row) |
- States: met / under goal · rated / unrated · with / without note

**TimelineLane**
| Prop | Type | Meaning |
|---|---|---|
| `bedTime` | `DateTime` | Bar start |
| `wakeTime` | `DateTime` | Bar end |
| `underGoal` | `bool` | Faded bar |
| `hasNote` | `bool` | Note icon |
- States: met / under goal · with / without note

**MonthCalendar**
| Prop | Type | Meaning |
|---|---|---|
| `month` | `DateTime` | Month shown |
| `sessionsByDate` | map of date → Session | Logged nights |
| `today` | `DateTime` | Today outline, future days |
| `goal` | `Duration` | Shading |
| `onTapSession` | `ValueChanged<Session>` | Opens the editor |
| `onTapEmptyDay` | `ValueChanged<DateTime>` | Add a night for that day |
| `onLongPressSession` | (Session, Offset) | Context menu |
| `onLongPressEmptyDay` | (DateTime, Offset) | "Add a night for …" menu |
| `onPrevMonth` | `VoidCallback` | Previous month |
| `onNextMonth` | `VoidCallback?` | Null = disabled |
- States: current month (next disabled) · past month

**CalendarDayCell**
| Prop | Type | Meaning |
|---|---|---|
| `date` | `DateTime` | Day number |
| `session` | Session? | Logged night |
| `shade` | `double?` (0–1) | Time ÷ goal clamped to ½×…1½×, blended across the heat colours; null = nothing logged |
| `isToday` | `bool` | Outline |
| `isFuture` | `bool` | Dimmed, inert |
| `onTap` | `VoidCallback?` | Edit or add |
| `onLongPress` | `ValueChanged<Offset>?` | Context menu or "Add a night" menu |
- States: logged (shaded) · empty past · future · today

**CalendarLegend**
- Props: none
- States: static (gradient: ½× goal · Goal · 1½× goal)

### Insights

**InsightsScreen**
- Props: none
- States: period 7 days / 30 days / all time

**SummaryCard**
| Prop | Type | Meaning |
|---|---|---|
| `period` | 7 days / 30 days / all time | Selected period |
| `onPeriodChanged` | callback | Period switched |
| `rangeLabel` | `String` | Dates covered |
| `tiles` | list of StatTile data | The 8 tiles |
- States: no nights in period · early (averages show `—`) · normal

**PeriodSelector**
| Prop | Type | Meaning |
|---|---|---|
| `value` | period | Selected |
| `onChanged` | callback | Switched |
- States: one option selected

**StatTile**
| Prop | Type | Meaning |
|---|---|---|
| `label` | `String` | e.g. "Avg bedtime" |
| `value` | `String` | e.g. "11:43 PM" or "—" |
| `caption` | `Widget?` | Text, delta arrow or stars |
- States: value · not available (`—` + reason)

**BedWakeChart**
| Prop | Type | Meaning |
|---|---|---|
| `sessions` | list of Session (up to 14) | Oldest to newest |
| `usualBedtime` | `TimeOfDay?` | Dashed line |
| `usualWake` | `TimeOfDay?` | Dashed line |
| `goal` | `Duration` | Met / under bars |
| `onTapSession` | `ValueChanged<Session>` | Opens the editor |
| `onLongPressSession` | (Session, Offset) | Context menu |
- States: not enough data (fewer than 3) · partial (3–13, right-aligned) · full (14)

### Settings

**SettingsScreen**
- Props: none
- States: normal
- Groups:
  - Sleep: goal, rate prompt
  - Appearance: theme
  - Data: export, import (whole SQLite file; import replaces everything)

**SettingsGroup**
| Prop | Type | Meaning |
|---|---|---|
| `title` | `String` | Group heading |
| `children` | `List<Widget>` | Rows |
- States: static

**SleepGoalStepper**
| Prop | Type | Meaning |
|---|---|---|
| `value` | `Duration` | Current goal |
| `onChanged` | `ValueChanged<Duration>` | New goal |
| `min` / `max` / `step` | `Duration` | 4h / 12h / 30m |
- States: normal · at min (− disabled) · at max (+ disabled)

**SettingsSwitchTile**
| Prop | Type | Meaning |
|---|---|---|
| `title` | `String` | Row title |
| `subtitle` | `String?` | Row description |
| `value` | `bool` | On / off |
| `onChanged` | `ValueChanged<bool>` | Toggled |
- States: on · off

**SettingsActionTile**
| Prop | Type | Meaning |
|---|---|---|
| `title` | `String` | Row title |
| `subtitle` | `String?` | Row description |
| `actionLabel` | `String` | Button text |
| `onPressed` | `VoidCallback` | Action |
- States: idle · busy

**ThemeModeSelector**
| Prop | Type | Meaning |
|---|---|---|
| `value` | `ThemeMode` | System / Light / Dark |
| `onChanged` | `ValueChanged<ThemeMode>` | Switched |
- States: one option selected

### About

**AboutScreen**
- Props: none
- States: static
- Contents:
  - App name and version
  - Short description
  - Your data
  - Send feedback
  - Open-source licenses

### Shared

**SessionEditorSheet**
| Prop | Type | Meaning |
|---|---|---|
| `mode` | create / editNight / editActive | Which flow |
| `session` | Session? | Night or active session being edited |
| `initialDate` | `DateTime?` | Pre-fill when adding from a calendar day |
- States: create (no Delete) · edit night · edit active (empty wake = still sleeping) · error (wake not after bed, Save disabled)

**StarRating**
| Prop | Type | Meaning |
|---|---|---|
| `value` | `int?` | 1–5, null = unrated |
| `onChanged` | `ValueChanged<int?>?` | Null = read-only; tapping the current star clears it |
| `size` | `double` | Icon size |
- States: unrated · rated 1–5 · read-only

**SectionCard**
| Prop | Type | Meaning |
|---|---|---|
| `title` | `String` | Card heading |
| `trailing` | `Widget?` | Subtitle or link |
| `child` | `Widget` | Content |
- States: static

**SegmentedControl\<T\>**
| Prop | Type | Meaning |
|---|---|---|
| `options` | list of (T, label) | Choices |
| `value` | `T` | Selected |
| `onChanged` | `ValueChanged<T>` | Switched |
- States: one option selected

**EmptyNote**
| Prop | Type | Meaning |
|---|---|---|
| `message` | `String` | Text shown |
- States: static

**SessionContextMenu**
| Prop | Type | Meaning |
|---|---|---|
| `session` | Session | The night |
| `onRate` | `ValueChanged<int?>` | Rate from the menu |
- Opened next to the finger on long-press (with a haptic tap)
- Header: date, bed → wake · duration, stars; items: Edit, Delete (Undo toast)
- Variant: "Add a night for …" for empty days
- States: open · closed

**RatePromptDialog**
| Prop | Type | Meaning |
|---|---|---|
| `length` | `Duration` | Shown as "7h 45m logged" |
- Shown after Stop when "Ask me to rate in the morning" is on; Skip closes it
- States: unrated · picked (closes)

**UndoSnackbar**
| Prop | Type | Meaning |
|---|---|---|
| `message` | `String` | "Session saved", "Session deleted" |
| `onUndo` | `VoidCallback` | Undo action |
- States: shown · dismissed

## Outside the app

**Quick Settings tile (Android)**
- Start / stop sleep from the notification shade, also on the lock screen
- Label "Start sleep" / "Sleeping", subtitle "Last 7h 45m" / "Since 11:02 PM"
- Logic and wording live in Dart (`lib/services/quick_tile.dart`); Android only draws the pushed state and forwards taps
