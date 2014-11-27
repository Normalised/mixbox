/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 12:31 PM
 */
package com.korisnamedia.musicbox.audio {
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.MicRecorder;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.musicbox.ui.WaveformRenderer;

import flash.display.Sprite;

import flash.events.Event;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class MicTrack extends Sprite {

    private var _micRecorder:MicRecorder;
//    private var scope:Oscilloscope;
    private var renderer:WaveformRenderer;
    private var loop:AudioLoop;
    private var recorded:Boolean = false;

    private static const log:ILogger = getLogger(MicTrack);

    public function MicTrack(tempo:Tempo, numBars:int) {

//        scope = new Oscilloscope(600,80);
//        addChild(scope);
//        scope.y = 150;

        renderer = new WaveformRenderer(400, 60);
        renderer.sample = loop;

        addChild(renderer);


        renderer.endTime = tempo.samplesPerBar * numBars;

        addEventListener(Event.ADDED_TO_STAGE, doLayout);
//        addEventListener(Event.ENTER_FRAME, updateDisplay);
    }


    private function doLayout(event:Event):void {
        log.debug("Do Layout");
        renderer.visible = false;
    }

    public function recordingComplete(event:Event):void {
        log.debug("Recording complete");
        recorded = true;
        renderer.render();
        renderer.visible = true;
        dispatchEvent(event.clone());
    }

    public function set micRecorder(value:MicRecorder):void {
        _micRecorder = value;
        renderer.sample = _micRecorder.audioBuffer;
        _micRecorder.addEventListener(Event.COMPLETE, recordingComplete);
    }
}
}
