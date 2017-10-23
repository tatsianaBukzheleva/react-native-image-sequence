package dk.madslee.imageSequence;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;

/**
 * reference: https://stackoverflow.com/a/41630234
 */

public abstract class CustomAnimationDrawable extends AnimationDrawable {

    private int current;
    private int totalTime;
    private Boolean stopped = false;

    public CustomAnimationDrawable() {
        this.current = 0;
        this.totalTime = 0;
    }

    @Override
    public void addFrame(Drawable frame, int duration) {
        super.addFrame(frame, duration);
        totalTime += duration;
    }

    @Override
    public void start() {
        super.start();
        stopped = false;
        new Handler().postDelayed(new Runnable() {

            public void run() {
                onAnimationFinish();
            }
        }, totalTime);
    }

    @Override
    public void stop() {
        super.stop();
        stopped = true;
    }

    @Override
    public boolean selectDrawable(int idx) {
        current = idx;
        return super.selectDrawable(current);
    }

    @Override
    public void draw(Canvas canvas) {
        if (current < this.getNumberOfFrames() && !stopped) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) this.getFrame(current);
            Bitmap bmp = bitmapDrawable.getBitmap();
            //Painting Bitmap in canvas
            canvas.drawBitmap(bmp, 0, 0, null);
            //Jump to next item
            current++;
        } else if (!this.isOneShot()) {
            current = 0;
        }
    }

    abstract void onAnimationFinish();

}
