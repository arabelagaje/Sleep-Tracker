import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/sleep_session.dart';
import '../providers/sleep_provider.dart';
import '../utils/formatters.dart';

// Bridge to the Android Quick Settings tile.
//
// Android only draws what Dart sends ({active, label, subtitle}) and forwards
// taps to [quickTileMain]. All sleep logic and wording lives here, so DB or
// behaviour changes stay on the Dart side.
class QuickTile {
  static const channel = MethodChannel('sleep_tracker/quick_tile');

  static Map<String, Object?> stateFor(SleepSession? active, SleepSession? last) {
    if (active != null) {
      return {'active': true, 'label': 'Sleeping', 'subtitle': 'Since ${fmtClock(active.bedTime)}'};
    }
    return {
      'active': false,
      'label': 'Start sleep',
      'subtitle': last == null ? null : 'Last ${fmtDur(last.length)}',
    };
  }

  // Sends the current state to the tile. No-op where there is no tile
  // (tests, non-Android).
  static Future<void> push(SleepSession? active, SleepSession? last) async {
    try {
      await channel.invokeMethod('update', stateFor(active, last));
    } on MissingPluginException {
      // No tile on this platform.
    }
  }
}

// Entry point of the background engine Android starts for tile taps.
@pragma('vm:entry-point')
Future<void> quickTileMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sleep = SleepProvider();
  QuickTile.channel.setMethodCallHandler((call) async {
    if (call.method != 'tap') return null;
    // Re-read first: the app may have changed things since the last tap.
    await sleep.load();
    if (sleep.isSleeping) {
      await sleep.stopSleep();
    } else {
      await sleep.startSleep();
    }
    // load() inside start/stop already pushed the new tile state.
    return null;
  });
  await QuickTile.channel.invokeMethod('ready');
}
