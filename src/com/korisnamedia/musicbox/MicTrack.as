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

public class MicTrack extends Sprite {

    public var micRecorder:MicRecorder;
    private var scope:Oscilloscope;
    private var mixEngine:MixEngine;
    private var renderer:WaveformRenderer;
    private var loop:AudioLoop;

    public function MicTrack(mixEngine:MixEngine, tempo:Tempo, numBars:int) {

        this.mixEngine = mixEngine;

        scope = new Oscilloscope(600,80);
        addChild(scope);
        scope.y = 150;

        micRecorder = new MicRecorder();
        micRecorder.addEventListener(Event.COMPLETE, recordingComplete);

        loop = new AudioLoop(tempo);
        loop.empty(4);
        micRecorder.audioBuffer = loop;

        renderer = new WaveformRenderer(600, 80);
        renderer.sample = loop;

        addChild(renderer);
        micRecorder.enable();

        renderer.endTime = tempo.samplesPerBar * numBars;

        addEventListener(Event.ENTER_FRAME, updateDisplay);
    }

    private function updateDisplay(event:Event):void {
        scope.render(loop, micRecorder.writePos, 4096);
    }

    public function startRecording(timeToSync:int):void {
        if(!micRecorder.recording) {
            trace("Start recording " + timeToSync);
            micRecorder.record(timeToSync);
        } else {
            trace("Already recording");
        }
    }

    public function stopRecording():void {
        if(micRecorder.recording) {
            trace("Stop Recording");
            micRecorder.stop();
        }
    }

    private function recordingComplete(event:Event):void {
        trace("Recording complete");
        renderer.render();
    }

    public function get recording():Boolean {
        return micRecorder.recording;
    }
}
}
