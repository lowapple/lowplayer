package io.lowapple.lowplayer;

/**
 * Created by lowapple on 23/03/2018.
 */

public class NDK {
    static {
        System.loadLibrary("sample_ffmpeg");
    }

    public native int scanning(String filepath);
}
