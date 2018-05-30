package io.lowapple.lowplayer

import android.content.Context
import android.graphics.PixelFormat
import android.view.SurfaceHolder
import android.view.SurfaceView

/**
 * Created by lowapple on 25/03/2018.
 */

open class LowPlayerView(context: Context) : SurfaceView(context), SurfaceHolder.Callback {

    private val surfaceHolder: SurfaceHolder
    private lateinit var lowPlayer: LowPlayer

    init {
        this.surfaceHolder = holder
        this.surfaceHolder.setFormat(PixelFormat.RGBA_8888)
        this.surfaceHolder.addCallback(this)
    }

    override fun surfaceCreated(holder: SurfaceHolder) {

    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {

    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {

    }

    fun setPlayer(player: LowPlayer) {
        this.lowPlayer = player
    }

    fun getPlayer() = lowPlayer
}
