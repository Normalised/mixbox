/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 10:46 AM
 */
package com.korisnamedia.musicbox {
import com.korisnamedia.IndexEvent;
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.BooleanEvent;
import com.korisnamedia.audio.LoadProgressEvent;
import com.korisnamedia.audio.MP3SampleLoader;
import com.korisnamedia.audio.MicRecorder;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.audio.SampleEvent;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.audio.sequence.Sequence;
import com.korisnamedia.audio.sequence.SequenceEvent;
import com.korisnamedia.audio.sequence.SequencePlayer;
import com.korisnamedia.musicbox.ui.BoxOfTracks;
import com.korisnamedia.musicbox.ui.TransportControls;
import com.korisnamedia.musicbox.ui.TransportEvent;
import com.korisnamedia.ui.CircleMeter;

import flash.events.Event;

import flash.events.EventDispatcher;

public class MultiTrackBox extends EventDispatcher{

    private var _mp3SampleLoader:MP3SampleLoader;

    public var boxOfTracks:BoxOfTracks;
    public var mixEngine:MixEngine;
    private var _samplesPerBeat:Number;

    public var sequence:Sequence;
    private var sequencePlayer:SequencePlayer;
    private var _transport:TransportControls;
    public var playingSequence:Boolean = false;
    public var recording:Boolean = false;
    public var micTrack:MicTrack;

    public function MultiTrackBox(tempo:Tempo) {

        mixEngine = new MixEngine();
        mixEngine.tempo = tempo;
        mixEngine.addEventListener(MixEngine.PLAY_STATE, enginePlayStateChanged);
        _mp3SampleLoader = new MP3SampleLoader(tempo);
        _mp3SampleLoader.addEventListener(SampleEvent.READY, sampleLoaded);
        _mp3SampleLoader.addEventListener(Event.COMPLETE, allLoaded);
        _mp3SampleLoader.addEventListener(LoadProgressEvent.PROGRESS, sampleLoadProgress);
        boxOfTracks = new BoxOfTracks(mixEngine);
        boxOfTracks.addEventListener(IndexEvent.TYPE, toggleTrack);
        sequence = new Sequence();
        sequence.addEventListener(Event.CHANGE, sequenceChanged);
        sequencePlayer = new SequencePlayer(mixEngine);
        sequencePlayer.sequence = sequence;

        micTrack = new MicTrack(mixEngine, tempo, 4);
    }

    private function sequenceChanged(event:Event):void {
        transport.sequenceAvailable = !sequence.isEmpty();
    }

    private function enginePlayStateChanged(event:BooleanEvent):void {
        trace("Engine play state changed " + event.value);
        transport.playState = event.value;
    }

    private function sampleLoadProgress(event:LoadProgressEvent):void {
        dispatchEvent(event.clone());
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
        addTrack(micTrack.micRecorder.audioBuffer);
        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function toggleTrack(event:IndexEvent):void {
        if (event.index > -1) {
            var state:Boolean = mixEngine.toggleTrack(event.index);
            if(recording) {
                var t:Number = mixEngine.sequencePosition;
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

    private function startEngine():void {
        trace("Start Engine");
        mixEngine.start();
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            boxOfTracks.meters[i].update(0, mixEngine.channels[i]);
        }
    }

    public function get transport():TransportControls {
        return _transport;
    }

    public function set transport(value:TransportControls):void {
        _transport = value;
        transport.addEventListener(TransportEvent.PLAY, play);
        transport.addEventListener(TransportEvent.STOP, stop);
        transport.addEventListener(TransportEvent.RECORD, recordMic);
        transport.addEventListener(TransportEvent.PLAY_SEQUENCE, playSequence);
    }

    private function play(event:TransportEvent):void {
        if(mixEngine.playing) return;
        playingSequence = false;
        recording = false;
        startEngine();
    }

    private function stop(event:TransportEvent):void {
        if(playingSequence) {
            sequencePlayer.stop();
        }
        if(recording) {
            micTrack.stopRecording();
        }
        mixEngine.gain = 1.0;
        mixEngine.stop();
        boxOfTracks.waitForCountIn = false;
        recording = false;
        playingSequence = false;
        transport.sequenceAvailable = !sequence.isEmpty();
    }

    public function recordMic(event:Event):void {

        if(!micTrack.recording) {
            if(!mixEngine.playing) {
                mixEngine.preRoll();
            }
            boxOfTracks.startCountDown();
            var timeToSync:int = 0;
            if(mixEngine.position < 0) {
                timeToSync = mixEngine.position;
            } else {
                // how many samples until next recording boundary
                var p:int = mixEngine.position % (mixEngine.tempo.samplesPerBar * 2);
                timeToSync = p - (mixEngine.tempo.samplesPerBar * 2);
            }
            micTrack.startRecording(timeToSync);
            recording = true;
        } else {
            micTrack.stopRecording();
        }

    }

    public function recordSequence(event:TransportEvent):void {
        if(mixEngine.playing || recording) return;

        sequence.clear();

        recording = true;
        // Add start events for all tracks
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            sequence.tracks[i].addEvent(new SequenceEvent(0,{state:mixEngine.channels[i].active}));
        }
        startEngine();
    }

    private function playSequence(event:TransportEvent):void {
        if(playingSequence || mixEngine.playing) return;
        playingSequence = true;
        recording = false;
        sequencePlayer.play();
        startEngine();
    }

}
}
