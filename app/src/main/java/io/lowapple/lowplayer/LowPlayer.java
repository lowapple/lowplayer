package io.lowapple.lowplayer;

import android.view.Surface;

/**
 * Created by lowapple on 25/03/2018.
 */

public class LowPlayer {
    private LowDataSource lowDataSource = null;
    private LowPlayerView lowPlayerView = null;

    public LowPlayer(LowPlayerView playerView) {
        playerView.setPlayer(this);
        this.lowPlayerView = playerView;
    }

    public void setDataSource(String url) {
        lowDataSource = new LowDataSource(url);
    }

    public void play() {
        render(lowPlayerView.getHolder().getSurface());
    }

    public void resume() {

    }

    public void stop() {

    }

    public void pause() {

    }

    public int render(Surface surface) {
        return render(lowDataSource.getUrl(), surface);
    }

    public native int render(String url, Surface surface);

    static {
        System.loadLibrary("player");
    }
}
