/**
 * Created by Martin Wood-Mitrovski
 * Date: 22/11/2014
 * Time: 12:44
 */
package com.korisnamedia.musicbox.starling {
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Expo;
import com.greensock.easing.Sine;
import com.korisnamedia.audio.AudioLoop;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

import starling.display.MovieClip;

public class Robot {

    private var sample:AudioLoop;
    private var clip:MovieClip;

    private static const log:ILogger = getLogger(Robot);
    private var startAnim:TweenLite;

    public function Robot(movieClip:MovieClip, loop:AudioLoop) {
        clip = movieClip;
        sample = loop;
        sample.stateChangeHandler = stateChanged;
    }

    public function stateChanged(newState:uint, oldState:uint):void {


        log.debug("State Changed " + oldState + " -> " + newState);
        if(newState == AudioLoop.STARTING) {
            // Show pending animation
            startAnim = TweenMax.to(clip,0.1,{repeat:100, y:clip.y+(3), x:clip.x+(3), delay:0, ease:Sine.easeOut});

        } else if(newState == AudioLoop.STOPPING) {
            // Nothing?
        } else {
            // cancel any pending animations
            if(startAnim) {
                startAnim.pause(0);
            }
        }
    }

    public function update(sequencePosition:Number):void {
        if(!sample.waitForQuantizedSync && sequencePosition >= 0) {
            clip.currentFrame = (sequencePosition % 1.0) * clip.numFrames;
        }
    }

    public function reset():void {
        clip.currentFrame = 0;
    }
}
}
