package com.arabelagaje.sleeptracker

import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

// Draws the state Dart last pushed; taps go to Dart via QuickTileBridge.
class SleepTileService : TileService() {
    companion object {
        // The tile currently shown in an open shade, if any.
        var listening: SleepTileService? = null
    }

    override fun onStartListening() {
        super.onStartListening()
        listening = this
        refresh()
    }

    override fun onStopListening() {
        if (listening === this) listening = null
        super.onStopListening()
    }

    fun refresh() {
        val state = QuickTileBridge.load(this)
            ?: QuickTileBridge.TileState(false, "Start sleep", null)
        render(state.active, state.label, state.subtitle)
    }

    override fun onClick() {
        super.onClick()
        val current = QuickTileBridge.load(this)
        render(current?.active ?: false, current?.label ?: "Start sleep", "…")
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
