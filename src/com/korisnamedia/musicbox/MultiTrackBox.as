/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 10:46 AM
 */
package com.korisnamedia.musicbox {
import com.korisnamedia.IndexEvent;
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.AudioLoopEvent;
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
import com.korisnamedia.musicbox.starling.MixBoxUI;
import com.korisnamedia.musicbox.ui.BoxOfTracks;
import com.korisnamedia.musicbox.ui.TransportControls;
import com.korisnamedia.musicbox.ui.TransportEvent;
import com.korisnamedia.ui.CircleMeter;

import flash.events.Event;

import flash.events.EventDispatcher;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

public class MultiTrackBox extends EventDispatcher{

    private var _mp3SampleLoader:MP3SampleLoader;

    public var mixBoxUI:MixBoxUI;
    public var mixEngine:MixEngine;
    private var _samplesPerBeat:Number;

//    public var sequence:Sequence;
//    private var sequencePlayer:SequencePlayer;
//    private var _transport:TransportControls;
    public var playingSequence:Boolean = false;
    public var recording:Boolean = false;
    public var micTrack:MicTrack;
    private var micTrackID:int = -100;
    private var stopWhenComplete:Boolean = false;

    private static const log:ILogger = getLogger(MultiTrackBox);
    private var ui:MixBoxUI;

    public function MultiTrackBox(tempo:Tempo, ui:MixBoxUI) {

        this.ui = ui;

        mixEngine = new MixEngine();
        mixEngine.tempo = tempo;
        mixEngine.addEventListener(MixEngine.PLAY_STATE, enginePlayStateChanged);

        ui.init(mixEngine);
        ui.addEventListener(IndexEvent.TYPE, toggleTrackHandler);

        _mp3SampleLoader = new MP3SampleLoader(tempo);
        _mp3SampleLoader.addEventListener(SampleEvent.READY, sampleLoaded);
        _mp3SampleLoader.addEventListener(Event.COMPLETE, allLoaded);
        _mp3SampleLoader.addEventListener(LoadProgressEvent.PROGRESS, sampleLoadProgress);

//        sequence = new Sequence();
//        sequence.addEventListener(Event.CHANGE, sequenceChanged);
//        sequencePlayer = new SequencePlayer(mixEngine);
//        sequencePlayer.sequence = sequence;

        micTrack = new MicTrack(mixEngine, tempo, 4);
        micTrack.addEventListener(Event.COMPLETE, recordingComplete);
    }

    private function sequenceChanged(event:Event):void {
//        transport.sequenceAvailable = !sequence.isEmpty();
    }

    private function enginePlayStateChanged(event:BooleanEvent):void {
        log.debug("Engine play state changed " + event.value);
        dispatchEvent(event.clone());
//        transport.playState = event.value;
    }

    private function sampleLoadProgress(event:LoadProgressEvent):void {
        dispatchEvent(event.clone());
    }

    public function loadMP3s(mp3s:Array):void {
        _mp3SampleLoader.loadMP3s(mp3s);
    }

    private function sampleLoaded(event:SampleEvent):void {
        addTrack(event.sample);
    }

    private function allLoaded(event:Event):void {
        log.debug("All loaded");
        micTrackID = addTrack(micTrack.micRecorder.audioBuffer);
        dispatchEvent(new Event(Event.COMPLETE));
    }

    private function toggleTrackHandler(event:IndexEvent):void {
        log.debug("Toggle track handler " + event.index);
        var index:int = event.index;
        toggleTrack(index);
    }

    private function toggleTrack(index:int):void {
        if (index > -1) {
            // If no tracks are playing then also start the engine
            var startAfterToggle:Boolean = mixEngine.activeTrackCount == 0;
            var state:Boolean = mixEngine.toggleTrack(index);
            if(recording) {
                var t:Number = mixEngine.sequencePosition;
                // Quantise to next bar boundary
                t = Math.ceil(t);
//                sequence.tracks[index].addEvent(new SequenceEvent(t,{state:state}));
            } else if(startAfterToggle) {
                play(null);
            }
        }
    }

    public function get loopLength():int {
        return _samplesPerBeat * 4;
    }

    public function get latencyInSamples():int {
        return mixEngine.latencyInSamples;
    }

    public function addTrack(track:AudioLoop):int {
        log.debug("Add Track " + track);
        var trackID:int = mixEngine.addSample(track);
        ui.addTrack();
//        sequence.createTrack();
        track.addEventListener(AudioLoopEvent.STOPPED, trackStopped);
        return trackID;
    }

    private function trackStopped(event:AudioLoopEvent):void {
        if(mixEngine.activeTrackCount == 0) {
            log.debug("All tracks stopped");
            stop();
        }
    }

    private function startEngine():void {
        log.debug("Start Engine");
        mixEngine.start();
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            ui.resetCharacters();
//            boxOfTracks.meters[i].update(0, mixEngine.channels[i]);
        }
    }

//    public function get transport():TransportControls {
//        return _transport;
//    }
//
//    public function set transport(value:TransportControls):void {
//        _transport = value;
//        transport.addEventListener(TransportEvent.PLAY, play);
//        transport.addEventListener(TransportEvent.STOP, stop);
//        transport.addEventListener(TransportEvent.RECORD, recordMic);
////        transport.addEventListener(TransportEvent.PLAY_SEQUENCE, playSequence);
//    }

    public function play(event:TransportEvent = null):void {
        if(mixEngine.playing) return;
        playingSequence = false;
        recording = false;
        startEngine();
    }

    private function stop(event:TransportEvent = null):void {
        log.debug("STOP. Seq : " + playingSequence + ". Rec : " + recording);
//        if (playingSequence) {
//            sequencePlayer.stop();
//        }
        if (recording) {
            stopWhenComplete = true;
            micTrack.stopRecording();
            return;
        }
        stopEngine();
    }

    private function stopEngine():void {
        mixEngine.gain = 1.0;
        mixEngine.stop();
        ui.waitForCountIn = false;
        recording = false;
        playingSequence = false;
//        transport.sequenceAvailable = !sequence.isEmpty();
    }

    private function recordingComplete(event:Event):void {
        log.debug("Recording complete. Stop on complete : " + stopWhenComplete);
        recording = false;
        if(stopWhenComplete) {
            stopEngine();
        }
    }

    public function recordMic(event:Event):void {

        if(!micTrack.recording) {
            if(!mixEngine.playing) {
                mixEngine.preRoll();
            }
            ui.startCountDown();
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
            stopWhenComplete = false;
            micTrack.stopRecording();
        }
    }

//    public function recordSequence(event:TransportEvent):void {
//        if(mixEngine.playing || recording) return;
//
//        sequence.clear();
//
//        recording = true;
//        // Add start events for all tracks
//        for (var i:int = 0; i < mixEngine.channels.length; i++) {
//            sequence.tracks[i].addEvent(new SequenceEvent(0,{state:mixEngine.channels[i].active}));
//        }
//        startEngine();
//    }
//
//    private function playSequence(event:TransportEvent):void {
//        if(playingSequence || mixEngine.playing) return;
//        playingSequence = true;
//        recording = false;
//        sequencePlayer.play();
//        startEngine();
//    }

    public function hasRecording():Boolean {
        return micTrack.hasRecording();
    }

    public function getStateOfTracks():Object {
        var state:Object = {};

        for (var i:int = 0; i < mixEngine.channels.length - 1; i++) {
            state["track" + i] = {active:mixEngine.channels[i].active};
        }
        return state;
    }

    public function setStateOfTracks(tracks:Object, hasRecording:Boolean):void {
        for(var trackName:String in tracks) {
            log.debug("Track Name : " + trackName);
            var trackID:int = parseInt(trackName.substring(5));
            log.debug("Track ID " + trackID);
            if(tracks[trackName].active) {
                toggleTrack(trackID);
            }
        }
        if(hasRecording) {
            // Toggle the last track
            toggleTrack(mixEngine.channels.length - 1);
        }
    }
}
}
