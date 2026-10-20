package com.arabelagaje.sleeptracker

import android.content.ComponentName
import android.content.Context
import android.service.quicksettings.TileService
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// Android half of the quick tile. It holds no sleep logic: Dart
// (lib/services/quick_tile.dart) decides what a tap does and what the
// tile shows; this only stores and forwards.
object QuickTileBridge {
    private const val CHANNEL = "sleep_tracker/quick_tile"
    private const val PREFS = "quick_tile"

    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null
    private var ready = false
    private var pendingTaps = 0

    data class TileState(val active: Boolean, val label: String, val subtitle: String?)

    // Registers the Dart → Android calls on any engine (app or background).
    fun attach(context: Context, messenger: BinaryMessenger): MethodChannel {
        val app = context.applicationContext
        val ch = MethodChannel(messenger, CHANNEL)
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    save(app, call.arguments as? Map<*, *> ?: emptyMap<Any, Any>())
                    SleepTileService.listening?.refresh()
                        ?: TileService.requestListeningState(app, ComponentName(app, SleepTileService::class.java))
                    result.success(null)
                }
                "ready" -> {
                    ready = true
                    repeat(pendingTaps) { ch.invokeMethod("tap", null) }
                    pendingTaps = 0
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        return ch
    }

    // Forwards a tile tap to Dart, starting the background engine if needed.
    fun tap(context: Context) {
        if (engine == null) start(context.applicationContext)
        if (ready) channel?.invokeMethod("tap", null) else pendingTaps++
    }

    private fun start(app: Context) {
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationComplete(app, null)
        val e = FlutterEngine(app)
        channel = attach(app, e.dartExecutor.binaryMessenger)
        e.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(),
                "package:sleep_tracker/services/quick_tile.dart",
                "quickTileMain",
            ),
        )
        engine = e
    }

    private fun save(context: Context, state: Map<*, *>) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
            .putBoolean("active", state["active"] as? Boolean ?: false)
            .putString("label", state["label"] as? String)
            .putString("subtitle", state["subtitle"] as? String)
            .apply()
    }

    fun load(context: Context): TileState? {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val label = p.getString("label", null) ?: return null
        return TileState(p.getBoolean("active", false), label, p.getString("subtitle", null))
    }
}
