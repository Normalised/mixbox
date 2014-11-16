/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/16/2014
 * Time: 6:37 PM
 */
package {
import com.codecatalyst.promise.Deferred;
import com.codecatalyst.promise.Promise;
import com.korisnamedia.AudioLoader;
import com.korisnamedia.AudioUploader;
import com.korisnamedia.JsonLoadEvent;
import com.korisnamedia.JsonLoader;
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.LoadProgressEvent;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.musicbox.MicTrack;
import com.korisnamedia.musicbox.MultiTrackBox;
import com.korisnamedia.musicbox.starling.MixBoxUI;
import com.korisnamedia.musicbox.ui.NativeUI;
import com.korisnamedia.musicbox.ui.SequencerView;
import com.korisnamedia.musicbox.ui.TransportControls;
import com.korisnamedia.ui.RemoteMixManager;

import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.LOGGER_FACTORY;
import org.as3commons.logging.api.getLogger;

import org.as3commons.logging.setup.SimpleTargetSetup;

import org.as3commons.logging.setup.target.TraceTarget;

import starling.core.Starling;
import starling.display.Sprite;
import starling.events.ResizeEvent;

use namespace LOGGER_FACTORY;

public class MixBox extends Sprite {

    public static const DEBUG:Boolean = true;

    private var multiTrackBox:MultiTrackBox;

    private var timer:Timer;
    private var filterControls:FilterControls;
//    private var transport:TransportControls;
//    private var sequencerView:SequencerView;
    private var tempo:Tempo;
    private var playingSequence:Boolean = false;

    private var jsonLoader:JsonLoader;
    private var audioUploader:AudioUploader;
    private var audioLoader:AudioLoader;
    private var mixManager:RemoteMixManager;

    private var server:String = "http://localhost/MooMixPhp/";
    private var endPoints:Object = {saveAudio:"saveAudio.php",getAudio:"getAudio.php",saveMix:"saveMix.php", getMix:"getMix.php"};

    private static const log:ILogger = getLogger(MixBox);
    private var mp3s:Array;
    private var ui:MixBoxUI;

    private var _starling:Starling;
    private var nativeUI:NativeUI;

    public function MixBox() {

        log.debug("New MixBox");

        tempo = new Tempo(120);
        mp3s = [];
        for (var i:int = 0; i < 8; i++) {
            mp3s.push("audio/MixBoxTestTrack0" + (i + 1) + ".mp3");
        }
        audioLoader = new AudioLoader(server + endPoints.getAudio);
        mixManager = new RemoteMixManager(server, endPoints);
        jsonLoader = new JsonLoader();
        jsonLoader.addEventListener(JsonLoadEvent.DATA_LOADED, sequenceLoaded);

        _starling = Starling.current;
        addEventListener(Event.ADDED_TO_STAGE, addedToStage);

    }

    private function addedToStage(event:Object):void {
        log.debug("Added to stage");

        stage.addEventListener(Event.RESIZE, onResize);

        ui = new MixBoxUI();
        addChild(ui);

        multiTrackBox = new MultiTrackBox(tempo);
        multiTrackBox.mixBoxUI = ui;
//        multiTrackBox.sequence.barCount = tempo.secondsToBars(120);
        multiTrackBox.addEventListener(Event.COMPLETE, allTracksLoaded);
        multiTrackBox.loadMP3s(mp3s);

//        nativeUI = new NativeUI(_starling.nativeOverlay);
//        nativeUI.mixEngine = multiTrackBox.mixEngine;

        if(DEBUG) {
//            nativeUI.addMicTrack(multiTrackBox.micTrack);
        }

    }

    private function onResize(event:Object):void {
        if(AppConfig.useNativeScreen) {
            log.debug("Resize : " + _starling.nativeStage.fullScreenWidth + ", " + _starling.nativeStage.fullScreenHeight);
            updateDimensions(_starling.nativeStage.fullScreenWidth, _starling.nativeStage.fullScreenHeight);
        } else {
            log.debug("Size : " + stage.width + ", " + stage.height);
            updateDimensions(_starling.nativeStage.stageWidth, _starling.nativeStage.stageHeight);
        }

    }

    private function updateDimensions(width:int, height:int):void {
        log.debug("Update Starling Viewport " + width + ", " + height);

        var scale:Number = Starling.current.contentScaleFactor;
        var viewPort:Rectangle = new Rectangle(0, 0, width, height);

        Starling.current.viewPort = viewPort;
        stage.stageWidth  = viewPort.width  / scale;
        stage.stageHeight = viewPort.height / scale;
        ui.doLayout(stage.stageWidth, stage.stageHeight);
    }

    private function sequenceLoaded(event:JsonLoadEvent):void {
        trace("Sequence Loaded : " + event.data);
//        multiTrackBox.sequence.deserialize(event.data);

    }

    private function allTracksLoaded(event:Event = null):void {
//        sequencerView.sequence = multiTrackBox.sequence;
    }

    private function save(event:MouseEvent = null):void {
        // If there is a mic recording, upload it first
        // then save current active track state
        if(multiTrackBox.hasRecording()) {
            saveRecording().then(saveTrackState, saveRecordingError);
        } else {
            // Any point saving the state?
            saveTrackState("0");
        }
    }

    private function saveRecordingError(error:Object):void {
        trace("Save Recording Error : " + error);
    }

    private function saveRecording():Promise {
        trace("Save recording");
        audioUploader = new AudioUploader(server + endPoints.saveAudio);
        var recordedAudio:AudioLoop = multiTrackBox.micTrack.getRecordedAudio();
        return audioUploader.upload(recordedAudio);
    }

    private function saveTrackState(recordingID:String):void {
        if(recordingID) {
            trace("Save state and recording. Recording ID : " + recordingID);
        }
        var trackState:Object = multiTrackBox.getStateOfTracks();

        var mix:Object = {
            audioId:recordingID,
            tracks:trackState
        };

        mixManager.save(mix).then(mixSaved, mixSaveError);
    }

    private function mixSaved(id:String):void {
        trace("Mix Saved with id : " + id);
    }

    private function mixSaveError(error:Object):void {
        trace("Mix save error : " + error);
    }

//    private function saveSequence():void {
//        if(multiTrackBox.sequence && !multiTrackBox.sequence.isEmpty()) {
//            var serialized:Object = multiTrackBox.sequence.serialize();
//            trace("Serialized : " + serialized);
//            trace(JSON.stringify(serialized));
//        }
//    }

    private function load(event:Event = null):void {
        trace("Load");
        mixManager.load("1415796960").then(mixLoaded, mixLoadError);
    }

    private function mixLoaded(mixJson:String):void {
        var mix:Object = JSON.parse(mixJson);
        trace("Mix Loaded " + mix);
        if(mix.audioId) {
            trace("Loading audio from id : " + mix.audioId);
            restoreTrackState(mix.tracks, true);
            loadRecording(mix.audioId);
        } else {
            trace("Start audio");
            restoreTrackState(mix.tracks, false);
            mixReady();
        }
    }

    private function mixLoadError(error:Object):void {
        trace("Mix Load Error " + error.toString());
    }

    private function mixReady():void {
        trace("MIX READY");
        multiTrackBox.play();
    }

    private function restoreTrackState(tracks:Object, hasRecording:Boolean):void {
        trace("Restore track state : " + tracks);
        multiTrackBox.setStateOfTracks(tracks, hasRecording);
    }

    private function loadRecording(audioId:String):void {
        trace("Load Recording : " + audioId);
        audioLoader.load(audioId).then(audioLoaded,audioLoadError);
    }

    private function audioLoaded(audio:Vector.<Number>):void {
        trace("Audio Loaded " + audio.length);
        multiTrackBox.micTrack.replaceAudio(audio);
        mixReady();
    }

    private function audioLoadError(errorID:*):void {
        trace("Audio load error : " + errorID);
    }

    private function loadSequence():void {
        jsonLoader.load("../savedata/mdk1.json");
    }
//    private function createFilter():void {
//        var filterL:StateVariableFilter = new StateVariableFilter();
//        var filterR:StateVariableFilter = new StateVariableFilter();
//
//        multiTrackBox.getTrack(9).filters = Vector.<IFilter>([filterL, filterR]);
//        filterControls = new FilterControls();
//        filterControls.modules = [filterL,filterR];
//        addChild(filterControls);
//        filterControls.x = 850;
//        filterControls.y = 20;
//    }

}
}
