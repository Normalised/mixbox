/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 12:31 PM
 */
package com.korisnamedia.musicbox {
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.MicRecorder;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.audio.Oscilloscope;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.ui.MiniButton;

import flash.display.Sprite;

import flash.events.Event;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class MicTrack extends Sprite {

    public var micRecorder:MicRecorder;
//    private var scope:Oscilloscope;
    private var mixEngine:MixEngine;
    private var renderer:WaveformRenderer;
    private var loop:AudioLoop;
    private var recorded:Boolean = false;

    private static const log:ILogger = getLogger(MicTrack);

    public function MicTrack(mixEngine:MixEngine, tempo:Tempo, numBars:int) {

        this.mixEngine = mixEngine;

//        scope = new Oscilloscope(600,80);
//        addChild(scope);
//        scope.y = 150;

        micRecorder = new MicRecorder(tempo);
        micRecorder.addEventListener(Event.COMPLETE, recordingComplete);

        loop = new AudioLoop(tempo);
        var recordOffset:int = 20000;
        loop.empty((4 * tempo.samplesPerBar) + recordOffset);
        loop.setLoopStart(recordOffset);
        micRecorder.audioBuffer = loop;

        renderer = new WaveformRenderer(400, 60);
        renderer.sample = loop;

        addChild(renderer);
        micRecorder.enable();

        renderer.endTime = tempo.samplesPerBar * numBars;

        addEventListener(Event.ADDED_TO_STAGE, doLayout);
//        addEventListener(Event.ENTER_FRAME, updateDisplay);
    }

    private function doLayout(event:Event):void {
        log.debug("Do Layout");
        renderer.x = 300;
        renderer.y = 300;
        renderer.visible = false;
    }

    public function startRecording(timeToSync:int):void {
        if(!micRecorder.recording) {
            log.debug("Start recording " + timeToSync);
            micRecorder.record(timeToSync);
        } else {
            log.debug("Already recording");
        }
    }

    public function stopRecording():void {
        log.debug("Stop");
        micRecorder.stop();
    }

    private function recordingComplete(event:Event):void {
        log.debug("Recording complete");
        recorded = true;
        renderer.render();
        renderer.visible = true;
        dispatchEvent(event.clone());
    }

    public function get recording():Boolean {
        return micRecorder.recording;
    }

    public function hasRecording():Boolean {
        return recorded;
    }

    public function getRecordedAudio():AudioLoop {
        log.debug("Get recorded audio : " + loop.leftChannel.length);
        return loop;
    }

    public function replaceAudio(audio:Vector.<Number>):void {
        loop.replace(audio);
        renderer.render();
    }
}
}
