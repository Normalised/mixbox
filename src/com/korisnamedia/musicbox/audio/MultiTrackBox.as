/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 10:46 AM
 */
package com.korisnamedia.musicbox.audio {
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.AudioLoopEvent;
import com.korisnamedia.audio.BooleanEvent;
import com.korisnamedia.audio.LoadProgressEvent;
import com.korisnamedia.audio.MP3SampleLoader;
import com.korisnamedia.audio.MicRecorder;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.audio.SampleEvent;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.musicbox.starling.ButtonBar;
import com.korisnamedia.musicbox.starling.ButtonEvent;
import com.korisnamedia.musicbox.starling.IndexEvent;
import com.korisnamedia.musicbox.starling.MixBoxUI;
import com.korisnamedia.musicbox.ui.TransportEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.media.Sound;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

public class MultiTrackBox extends EventDispatcher{

    public var mixEngine:MixEngine;
    public var micRecorder:MicRecorder;

    private var _samplesPerBeat:Number;

//    public var sequence:Sequence;
//    private var sequencePlayer:SequencePlayer;
//    private var _transport:TransportControls;
    public var playingSequence:Boolean = false;
    public var recording:Boolean = false;
    private var micTrackID:int = -100;
    private var stopWhenComplete:Boolean = false;

    private static const log:ILogger = getLogger(MultiTrackBox);
    private var ui:MixBoxUI;

    public static const MIC_TRACK_INDEX:int = 11;
    private var preRollWhenStopped:Boolean = false;
    private var tempo:Tempo;

    public function MultiTrackBox(tempo:Tempo, mbUI:MixBoxUI) {

        this.tempo = tempo;
        mixEngine = new MixEngine();
        mixEngine.tempo = tempo;
        mixEngine.addEventListener(MixEngine.PLAY_STATE, enginePlayStateChanged);

        micRecorder = new MicRecorder(tempo, mixEngine);
        micRecorder.addEventListener(Event.COMPLETE, recordingComplete);

        ui = mbUI;
        ui.init(mixEngine, micRecorder);
        ui.addEventListener(IndexEvent.TYPE, toggleTrackHandler);
        ui.addEventListener(ButtonEvent.TYPE, uiButtonClicked);
    }

    private function uiButtonClicked(event:ButtonEvent):void {
        if(event.button == ButtonBar.RECORD) {
            recordMic();
        } else if(event.button == ButtonBar.MUTE) {
            mixEngine.toggleMute();
            ui.muted = mixEngine.muted;
        } else if(event.button == ButtonBar.CANCEL) {
            // remove recorded audio
            if(mixEngine.channels[micTrackID].active) {
                mixEngine.toggleTrack(micTrackID);
            }
            if(micRecorder.hasRecording) {
                micRecorder.clearRecording();
                ui.showRecordingControls(false);
            }
        } else if(event.button == ButtonBar.RESET) {
            if(mixEngine.playing) {
                mixEngine.stop();
                mixEngine.turnOffAllTracks();
            }
        } else if(event.button == ButtonBar.PLAY) {
            log.debug("Switch record track : " + mixEngine.channels[micTrackID].active);
            toggleTrack(micTrackID);
        }
    }


    private function toggleTrackHandler(event:IndexEvent):void {
        log.debug("Toggle track handler " + event.index);
        var index:int = event.index;
        if(index == MIC_TRACK_INDEX) {
            log.debug("Toggle Mic Track. Has Recording : " + micRecorder.hasRecording);
            if(micRecorder.isAvailable) {
                ui.showRecordingControls(micRecorder.hasRecording);
            }
            if(micRecorder.hasRecording) {
                toggleTrack(index);
            }
        } else {
            ui.showMainControls();
            toggleTrack(index);
        }
    }

    private function sequenceChanged(event:Event):void {
//        transport.sequenceAvailable = !sequence.isEmpty();
    }

    private function enginePlayStateChanged(event:BooleanEvent):void {
        log.debug("Engine play state changed " + event.value);
        if(event.value == false && preRollWhenStopped) {
            log.debug("PreRoll when stopped");
            startRecording();
        }
//        dispatchEvent(event.clone());
//        transport.playState = event.value;
    }

    public function start():void {
        log.debug("START");

        ui.showContent();
        ui.recordingEnabled = micRecorder.isAvailable;
        if(micRecorder.isAvailable) {
            log.debug("Enable mic");
            micRecorder.enable();
        }
        dispatchEvent(new Event(Event.COMPLETE));
    }


    private function toggleTrack(index:int):void {
        if (index > -1) {
            // If no tracks are playing then also start the engine
            var startAfterToggle:Boolean = mixEngine.activeTrackCount == 0;
            log.debug("Active Track Count " + mixEngine.activeTrackCount);
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

    public function addMicTrack():void {
        AppConfig.micTrackID = micTrackID = addTrack(micRecorder.audioBuffer);
    }

    public function addTrack(track:AudioLoop):int {
        var trackID:int = mixEngine.addSample(track);
        log.debug("Add Track " + track + ". ID : " + trackID);
        ui.addTrack(track, trackID);
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
            micRecorder.stop();
            return;
        }
        stopEngine();
    }

    private function stopEngine():void {
        mixEngine.gain = 1.0;
        ui.waitForCountIn = false;
        recording = false;
        playingSequence = false;
        mixEngine.stop();
//        transport.sequenceAvailable = !sequence.isEmpty();
    }

    private function recordingComplete(event:Event):void {
        log.debug("Recording complete. Stop on complete : " + stopWhenComplete);
        recording = false;
        ui.recordComplete();

        if(stopWhenComplete) {
            stopEngine();
        }
    }

    public function recordMic(event:Object = null):void {

        if(!micRecorder.recording) {
            if(mixEngine.playing) {
                preRollWhenStopped = true;
                stopEngine();
            } else {
                preRollWhenStopped = false;
                startRecording();
            }
        } else {
            ui.recording = false;
            stopWhenComplete = false;
            micRecorder.stop();
        }
    }

    private function startRecording():void {
        log.debug("Start Recording");
        preRollWhenStopped = false;
        mixEngine.preRoll();
        var timeToSync:int = 0;
        if(mixEngine.globalPositionInSamples < 0) {
            log.debug("Position is before zero, set -ve sync");
            timeToSync = mixEngine.globalPositionInSamples;
        } else {
            // how many samples until next recording boundary
            var p:int = mixEngine.globalPositionInSamples % (mixEngine.tempo.samplesPerBar * 2);
            timeToSync = p - (mixEngine.tempo.samplesPerBar * 2);
        }
        micRecorder.record(timeToSync);
        ui.startCountDown();

        recording = true;
        ui.recording = true;
    }

    public function hasRecording():Boolean {
        return micRecorder.hasRecording;
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

    private function createSequence():void {
        //        sequence = new Sequence();
        //        sequence.addEventListener(Event.CHANGE, sequenceChanged);
        //        sequencePlayer = new SequencePlayer(mixEngine);
        //        sequencePlayer.sequence = sequence;
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

    public function addTrackFromMp3(sound:Sound):void {
        var encoderOffset:int = AppConfig.getEncoderOffset();
        var sample:AudioLoop = new AudioLoop(tempo);
        log.debug("Adding track from mp3 " + sound + " : " + sample);
        sample.fromMP3(sound, encoderOffset);
        addTrack(sample);
    }
}
}
