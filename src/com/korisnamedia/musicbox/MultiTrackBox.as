/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 10:46 AM
 */
package com.korisnamedia.musicbox {
import com.korisnamedia.IndexEvent;
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.MP3SampleLoader;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.audio.SampleEvent;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.audio.sequence.Sequence;
import com.korisnamedia.audio.sequence.SequenceEvent;
import com.korisnamedia.musicbox.ui.BoxOfTracks;

import flash.events.Event;

import flash.events.EventDispatcher;

public class MultiTrackBox extends EventDispatcher{

    private var _mp3SampleLoader:MP3SampleLoader;

    public var boxOfTracks:BoxOfTracks;
    public var mixEngine:MixEngine;
    private var _samplesPerBeat:Number;

    public var sequence:Sequence;
    private var recording:Boolean;

    public function MultiTrackBox(tempo:Tempo) {

        mixEngine = new MixEngine();
        mixEngine.tempo = tempo;
        _mp3SampleLoader = new MP3SampleLoader(tempo);
        _mp3SampleLoader.addEventListener(SampleEvent.READY, sampleLoaded);
        _mp3SampleLoader.addEventListener(Event.COMPLETE, allLoaded);

        boxOfTracks = new BoxOfTracks();
        boxOfTracks.addEventListener(IndexEvent.TYPE, toggleTrack);
        boxOfTracks.addEventListener(Event.ENTER_FRAME, frameUpdate);
        sequence = new Sequence();
    }

    private function frameUpdate(event:Event):void {
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            if(!mixEngine.enabled[i] || !mixEngine.playing) {
                boxOfTracks.meters[i].update(0, false);
                boxOfTracks.meters[i].enabled = mixEngine.enabled[i];
                continue;
            }
            var sample:AudioLoop = mixEngine.channels[i];
            var p:Number = sample.position;
            if(p < mixEngine.latency) {
                p += sample.loopLengthInMilliseconds;
            }
            p -= mixEngine.latency;

            boxOfTracks.meters[i].enabled = true;
            boxOfTracks.meters[i].update(p / sample.loopLengthInMilliseconds, sample.waitForQuantizedSync);
        }
    }

    public function loadMP3s(mp3s:Array):void {
        _mp3SampleLoader.loadMP3s(mp3s);
    }

    private function sampleLoaded(event:SampleEvent):void {
        boxOfTracks.addTrack();
        sequence.createTrack();
        mixEngine.addSample(event.sample);
    }

    private function allLoaded(event:Event):void {
        trace("All loaded");
        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function toggleTrack(event:IndexEvent):void {
        if (event.index > -1) {
            var state:Boolean = mixEngine.toggleTrack(event.index);
            if(recording) {
                var t:Number = mixEngine.getSequencePosition();
                // Quantise to next bar boundary
                t = Math.ceil(t);
                sequence.tracks[event.index].addEvent(new SequenceEvent(t,{state:state}));
            }
        }
    }

    public function get loopLength():int {
        return _samplesPerBeat * 4;
    }

    public function get latencyInSamples():int {
        return mixEngine.latencyInSamples;
    }

    public function addTrack(track:AudioLoop):void {
        trace("Add Track " + track);
        mixEngine.addSample(track);
        boxOfTracks.addTrack();
        sequence.createTrack();
    }

    public function start():void {
        if(!mixEngine.playing) {
            recording = false;
            startEngine();
        }
    }

    private function startEngine():void {
        trace("Start Engine");
        mixEngine.start();
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            boxOfTracks.meters[i].update(0, false);
        }
    }

    public function stop():void {
        mixEngine.stop();
        recording = false;
    }

    public function record():void {
        sequence.clear();
        recording = true;
        // Add start events for all tracks
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            sequence.tracks[i].addEvent(new SequenceEvent(0,{state:mixEngine.enabled[i]}));
        }
        startEngine();
    }
}
}
