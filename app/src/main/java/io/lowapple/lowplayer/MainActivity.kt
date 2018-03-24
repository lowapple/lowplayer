package io.lowapple.lowplayer

import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.os.Environment
import android.util.Log
import java.io.File
import java.io.IOException

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        var filePath: String
        val ext = Environment.getExternalStorageState()
        if (ext == Environment.MEDIA_MOUNTED) {
            filePath = Environment.getExternalStorageDirectory().absolutePath
        } else {
            filePath = Environment.MEDIA_UNMOUNTED
        }

        try {
            filePath = filePath + "/sample-video.mp4"
            Log.d("FilePath", filePath)
            NDK().scanning(filePath)
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }
}
