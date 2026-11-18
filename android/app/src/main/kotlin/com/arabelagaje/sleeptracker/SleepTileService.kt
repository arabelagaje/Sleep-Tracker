package com.arabelagaje.sleeptracker

import android.os.Build
import android.os.Handler
import android.os.Looper
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

// Draws the state Dart last pushed; taps go to Dart via QuickTileBridge.
class SleepTileService : TileService() {
    companion object {
        // The tile currently shown in an open shade, if any.
        var listening: SleepTileService? = null
    }

    private val handler = Handler(Looper.getMainLooper())
    private val tick = Runnable { refresh() }

    override fun onStartListening() {
        super.onStartListening()
        listening = this
        refresh()
    }

    override fun onStopListening() {
        handler.removeCallbacks(tick)
        if (listening === this) listening = null
        super.onStopListening()
    }

    // Redraws, and while sleeping schedules the next redraw for when the
    // elapsed minute changes. Only runs while the shade is open.
    fun refresh() {
        handler.removeCallbacks(tick)
        val state = QuickTileBridge.load(this)
            ?: QuickTileBridge.TileState(false, getString(R.string.tile_start_sleep), null, null)
        val since = state.since
        var subtitle = state.subtitle
        if (since != null) {
            val ms = System.currentTimeMillis() - since
            subtitle = subtitle?.replace("{elapsed}", elapsed(ms, state))
            handler.postDelayed(tick, 60_000 - Math.floorMod(ms, 60_000L))
        }
        render(state.active, state.label, subtitle)
    }

    // Same rules as fmtDur in lib/utils/formatters.dart ("6h 12m", "8h", "40m"),
    // with the patterns Dart sent for the app's language.
    private fun elapsed(ms: Long, s: QuickTileBridge.TileState): String {
        val m = maxOf(ms / 60_000, 0)
        if (m < 60) return (s.elapsedM ?: "{m}m").replace("{m}", "$m")
        val h = m / 60
        val r = m % 60
        return if (r == 0L) {
            (s.elapsedH ?: "{h}h").replace("{h}", "$h")
        } else {
            (s.elapsedHm ?: "{h}h {m}m").replace("{h}", "$h").replace("{m}", "$r")
        }
    }

    override fun onClick() {
        super.onClick()
        val current = QuickTileBridge.load(this)
        render(current?.active ?: false, current?.label ?: getString(R.string.tile_start_sleep), "…")
        QuickTileBridge.tap(this)
    }

    private fun render(active: Boolean, label: String, subtitle: String?) {
        val tile = qsTile ?: return
        tile.state = if (active) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = label
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) tile.subtitle = subtitle
        tile.updateTile()
    }
}
