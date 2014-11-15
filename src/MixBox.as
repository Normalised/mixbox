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
import com.korisnamedia.musicbox.ui.SequencerView;
import com.korisnamedia.musicbox.ui.TransportControls;
import com.korisnamedia.ui.RemoteMixManager;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Timer;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.LOGGER_FACTORY;
import org.as3commons.logging.api.getLogger;

import org.as3commons.logging.setup.SimpleTargetSetup;

import org.as3commons.logging.setup.target.TraceTarget;

import starling.core.Starling;

use namespace LOGGER_FACTORY;

[SWF(width='1000', height='600', frameRate='25')]
public class MixBox extends Sprite {

    private var multiTrackBox:MultiTrackBox;

    private var timer:Timer;
    private var filterControls:FilterControls;
//    private var transport:TransportControls;
//    private var sequencerView:SequencerView;
    private var tempo:Tempo;
    private var playingSequence:Boolean = false;

    private var progressMeter:Sprite;
    private var saveButton:SaveButton;
    private var loadButton:LoadButton;
    private var jsonLoader:JsonLoader;
    private var engineInfo:EngineInfo;
    private var bufferFillTimeLimit:Number;
    private var audioUploader:AudioUploader;
    private var audioLoader:AudioLoader;
    private var mixManager:RemoteMixManager;

    private var server:String = "http://localhost/MooMixPhp/";
    private var endPoints:Object = {saveAudio:"saveAudio.php",getAudio:"getAudio.php",saveMix:"saveMix.php", getMix:"getMix.php"};
    private var _starling:Starling;

    private static const log:ILogger = getLogger(MixBox);
    private var mp3s:Array;
    public function MixBox() {

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        LOGGER_FACTORY.setup = new SimpleTargetSetup( new TraceTarget() );
        addEventListener(Event.ADDED_TO_STAGE, addedToStage);
    }

    private function addedToStage(event:Event = null):void {

        _starling = new Starling(MixBoxUI, stage);
        _starling.addEventListener("rootCreated", rootCreated);
        _starling.start();
//        transport = new TransportControls();
//        addChild(transport);

//        sequencerView = new SequencerView();
////        addChild(sequencerView);
//        sequencerView.x = 10;
//        sequencerView.y = 150;
        mp3s = [];
        for(var i:int = 0;i<8;i++) {
            mp3s.push("../audio/MixBoxTestTrack 0" + (i + 1) + ".mp3");
        }

        tempo = new Tempo(120);

        progressMeter = new Sprite();
        addChild(progressMeter);

        saveButton = new SaveButton();
        saveButton.addEventListener(MouseEvent.CLICK, save);
        saveButton.useHandCursor = true;
        saveButton.buttonMode = true;
        addChild(saveButton);
        loadButton = new LoadButton();
        loadButton.addEventListener(MouseEvent.CLICK, load);
        loadButton.useHandCursor = true;
        loadButton.buttonMode = true;
        addChild(loadButton);

        engineInfo = new EngineInfo();
        addChild(engineInfo);

        bufferFillTimeLimit = (4096 * 1000) / 44100;
        trace("BFTL : " + bufferFillTimeLimit);
        jsonLoader = new JsonLoader();
        jsonLoader.addEventListener(JsonLoadEvent.DATA_LOADED, sequenceLoaded);

        audioLoader = new AudioLoader(server + endPoints.getAudio);
        mixManager = new RemoteMixManager(server, endPoints);

        doLayout();
    }

    private function doLayout():void {

//        transport.x = (stage.stageWidth / 2) - (transport.width / 2);
//        transport.y = stage.stageHeight - transport.height - 4;
//
//        progressMeter.x = (stage.stageWidth / 2) - 50;
//        progressMeter.y = (stage.stageHeight / 2) - 5;
//
//        saveButton.x = transport.x + transport.width + 10;
//        saveButton.y = transport.y;
//        loadButton.x = saveButton.x + saveButton.width + 4;
//        loadButton.y = transport.y;

        engineInfo.x = (stage.stageWidth / 2) - (engineInfo.width / 2);
        engineInfo.y = stage.stageHeight - 200;

        if(multiTrackBox) {
            multiTrackBox.micTrack.x = 10;
            multiTrackBox.micTrack.y = 180;
        }
    }

    private function rootCreated(event:Object):void {
        log.debug('Root Created');
        multiTrackBox = new MultiTrackBox(tempo, _starling.root as MixBoxUI);
//        multiTrackBox.sequence.barCount = tempo.secondsToBars(120);
//        multiTrackBox.transport = transport;
        multiTrackBox.addEventListener(Event.COMPLETE, allTracksLoaded);
        multiTrackBox.addEventListener(LoadProgressEvent.PROGRESS, loadProgress);
        multiTrackBox.loadMP3s(mp3s);

        addEventListener(Event.ENTER_FRAME, update);
        addChild(multiTrackBox.micTrack);
    }

    private function sequenceLoaded(event:JsonLoadEvent):void {
        trace("Sequence Loaded : " + event.data);
//        multiTrackBox.sequence.deserialize(event.data);

    }

    private function loadProgress(event:LoadProgressEvent):void {
        progressMeter.graphics.clear();
        progressMeter.graphics.moveTo(0,0);
        progressMeter.graphics.lineStyle(1,0);
        progressMeter.graphics.beginFill(0x888888);
        progressMeter.graphics.drawRect(0,0,event.progress, 10);
    }

    private function update(event:Event):void {
        var mixEngine:MixEngine = multiTrackBox.mixEngine;
        var pos:Number = Math.floor(mixEngine.latencyAdjustSequencePosition * 100);
//        transport.time = pos / 100;
        engineInfo.latency.text = mixEngine.latency.toString();
        engineInfo.mixTime.text = mixEngine.writeTime.toString();
        engineInfo.writeTime.text = mixEngine.mixTime.toString();
        engineInfo.loadMeter.scaleX = (mixEngine.mixTime + mixEngine.writeTime) / bufferFillTimeLimit;
//        if(multiTrackBox.playingSequence || multiTrackBox.recording) {
//            sequencerView.time = pos / 100;
//        }
    }

    private function allTracksLoaded(event:Event = null):void {
        progressMeter.visible = false;
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
