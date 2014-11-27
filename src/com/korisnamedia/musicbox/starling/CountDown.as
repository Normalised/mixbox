/**
 * Created by Martin Wood-Mitrovski
 * Date: 13/11/2014
 * Time: 19:24
 */
package com.korisnamedia.musicbox.starling {
import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

import starling.display.MovieClip;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class CountDown extends Sprite {

    private var countdown:MovieClip;

    private static const log:ILogger = getLogger(CountDown);
    public function CountDown() {

        countdown = new MovieClip(MixBoxAssets.getInstance().getTextures("Countdown"));
        addChild(countdown);
    }

    public function show(beatsToStartPoint:Number):void {
        log.debug("Show beats to start point " + beatsToStartPoint);
        countdown.currentFrame = beatsToStartPoint;
    }
}
}
