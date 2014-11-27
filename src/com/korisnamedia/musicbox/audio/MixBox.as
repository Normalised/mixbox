/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/16/2014
 * Time: 6:37 PM
 */
package com.korisnamedia.musicbox.audio {
import com.codecatalyst.promise.Promise;
import com.greensock.events.LoaderEvent;
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.musicbox.data.AudioLoader;
import com.korisnamedia.musicbox.data.AudioUploader;
import com.korisnamedia.musicbox.data.JsonLoadEvent;
import com.korisnamedia.musicbox.data.JsonLoader;
import com.korisnamedia.musicbox.data.RemoteMixManager;
import com.korisnamedia.musicbox.starling.ButtonBar;
import com.korisnamedia.musicbox.starling.ButtonEvent;
import com.korisnamedia.musicbox.starling.MixBoxAssets;
import com.korisnamedia.musicbox.starling.MixBoxUI;
import com.korisnamedia.musicbox.ui.NativeUI;

import starling.events.Event;

//import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getDefinitionByName;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.LOGGER_FACTORY;
import org.as3commons.logging.api.getLogger;

import starling.core.Starling;
import starling.display.Sprite;

use namespace LOGGER_FACTORY;

public class MixBox extends Sprite {

    private var multiTrackBox:MultiTrackBox;

//    private var filterControls:FilterControls;
//    private var transport:TransportControls;
//    private var sequencerView:SequencerView;
    private var playingSequence:Boolean = false;

    private var jsonLoader:JsonLoader;
    private var audioUploader:AudioUploader;
    private var audioLoader:AudioLoader;
    private var mixManager:RemoteMixManager;

    private static const log:ILogger = getLogger(MixBox);
    private var ui:MixBoxUI;

    private var _starling:Starling;
    private var nativeUI:NativeUI;
    private var sounds:Vector.<Sound>;

    public function MixBox() {

        log.debug("New MixBox");

        _starling = Starling.current;
        ui = new MixBoxUI();
        ui.addEventListener(ButtonEvent.TYPE, buttonClicked);
        addChild(ui);

        MixBoxAssets.getInstance().loadGraphics(graphicsLoadProgress, graphicsLoaded);
    }

    private function graphicsLoadProgress(progress:Number):void {
        log.debug("Load Progress " + progress);
        ui.loadProgress = progress * 33;
    }

    private function graphicsLoaded():void {

        log.debug("Graphics Loaded");

//        for (var i:int = 0; i < 8; i++) {
//            mp3s.push("audio/MixBoxTestTrack0" + (i + 1) + ".mp3");
//        }
        audioLoader = new AudioLoader(AppConfig.serverUrl + AppConfig.endPoints.getAudio);
        mixManager = new RemoteMixManager(AppConfig.serverUrl, AppConfig.endPoints);
        jsonLoader = new JsonLoader();
        jsonLoader.addEventListener(JsonLoadEvent.DATA_LOADED, sequenceLoaded);


        log.debug("Added to stage");

        stage.addEventListener(Event.RESIZE, onResize);

//        multiTrackBox.sequence.barCount = tempo.secondsToBars(120);

        MixBoxAssets.getInstance().loadAudio(mp3LoadProgress, mp3sLoaded);
    }

    private function mp3LoadProgress(progress:Number):void {
        log.debug("MP3 Progress : " + progress);
        ui.loadProgress = 33 + (progress * 33);
    }

    private function mp3sLoaded():void {
        var mp3s:Dictionary = MixBoxAssets.getInstance().mp3s;
        sounds = new Vector.<Sound>();
        for (var name:String in mp3s) {
            var sound:Sound = mp3s[name];
            log.debug("Got Sound : " + name + " : " + sound);
            sounds.push(sound);
        }

        multiTrackBox = new MultiTrackBox(AppConfig.tempo, ui);
        addEventListener(Event.ENTER_FRAME, addSound);
    }

    private function addSound(event:Event):void {
        log.debug("Add Sound " + sounds.length);
        if(sounds.length > 0) {
            multiTrackBox.addTrackFromMp3(sounds.pop());
            ui.loadProgress = 66 + (34 / sounds.length);
        } else {
            log.debug("All sounds added");
            removeEventListener(Event.ENTER_FRAME, addSound);
            multiTrackBox.addMicTrack();
            nativeUI = new NativeUI(_starling.nativeOverlay);
            nativeUI.mixEngine = multiTrackBox.mixEngine;
            nativeUI.micTrack.micRecorder = multiTrackBox.micRecorder;
            ui.updateRobots();
            multiTrackBox.start();
        }
    }

    private function buttonClicked(event:ButtonEvent):void {
        if(event.button == ButtonBar.SHARE) {
            save();
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
        nativeUI.doLayout();
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
        audioUploader = new AudioUploader(AppConfig.serverUrl + AppConfig.endPoints.saveAudio);
        var recordedAudio:AudioLoop = multiTrackBox.micRecorder.audioBuffer;
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
        AppConfig.socialProvider.share('facebook', id);
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
        multiTrackBox.micRecorder.audioBuffer.replace(audio);
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
