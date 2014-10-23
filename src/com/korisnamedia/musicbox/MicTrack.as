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
import com.korisnamedia.ui.MiniButton;

import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

public class MicTrack extends Sprite {

    private var micRecorder:MicRecorder;
    public var audioData:AudioLoop;
    private var startRecordingButton:MiniButton;
    private var scope:Oscilloscope;
    private var _recordTime:int;
    private var mixEngine:MixEngine;
    private var _loopLength:int;
    private var renderer:WaveformRenderer;

    public function MicTrack(mixEngine:MixEngine) {

        this.mixEngine = mixEngine;

        scope = new Oscilloscope(800,200);
        addChild(scope);
        scope.y = 400;

        micRecorder = new MicRecorder();
        micRecorder.scope = scope;
        micRecorder.addEventListener(Event.COMPLETE, recordingComplete);
        startRecordingButton = new MiniButton();
        startRecordingButton.addEventListener(MouseEvent.CLICK, startRecording);
        startRecordingButton.x = 10;
        startRecordingButton.y = 125;
        addChild(startRecordingButton);

        renderer = new WaveformRenderer();
        renderer.y = 250;
        addChild(renderer);

        audioData = new AudioLoop();
        micRecorder.enable();
    }

    public function set loopLength(time:int):void {
        _loopLength = time;
        _recordTime = time + mixEngine.latencyInSamples;
    }

    private function startRecording(event:MouseEvent):void {
        trace("Start recording");
        micRecorder.recordTimeInSamples = _recordTime;
        micRecorder.record();
    }

    private function recordingComplete(event:Event):void {
        trace("Recording complete");
        // Copy mic data to mic track
        //(mixEngine.latencyInSamples * 2)
        var offset:int = 0;
        if(micRecorder.sampleData.length > _loopLength) {
            offset = micRecorder.sampleData.length - _loopLength;
            trace("Record Offset : " + offset);
        }
        audioData.copy(micRecorder.sampleData, null, offset);
        audioData.bars = 4;
        renderer.sample = audioData;
        renderer.render();
    }

}
}
