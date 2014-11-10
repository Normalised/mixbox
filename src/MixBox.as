/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/16/2014
 * Time: 6:37 PM
 */
package {
import com.korisnamedia.JsonLoadEvent;
import com.korisnamedia.JsonLoader;
import com.korisnamedia.audio.LoadProgressEvent;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.musicbox.MicTrack;
import com.korisnamedia.musicbox.MultiTrackBox;
import com.korisnamedia.musicbox.ui.SequencerView;
import com.korisnamedia.musicbox.ui.TransportControls;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Timer;

[SWF(width='1000', height='600', frameRate='30')]
public class MixBox extends Sprite {

    private var multiTrackBox:MultiTrackBox;

    private var timer:Timer;
    private var filterControls:FilterControls;
    private var micTrack:MicTrack;
    private var transport:TransportControls;
    private var sequencerView:SequencerView;
    private var tempo:Tempo;
    private var playingSequence:Boolean = false;

    private var progressMeter:Sprite;
    private var saveButton:SaveButton;
    private var loadButton:LoadButton;
    private var jsonLoader:JsonLoader;
    private var engineInfo:EngineInfo;
    private var bufferFillTimeLimit:Number;

    public function MixBox() {

        addEventListener(Event.ADDED_TO_STAGE, addedToStage);
    }

    private function addedToStage(event:Event = null):void {

        transport = new TransportControls();
        addChild(transport);
        transport.x = 10;
        transport.y = 70;

        sequencerView = new SequencerView();
//        addChild(sequencerView);
        sequencerView.x = 10;
        sequencerView.y = 150;
        var mp3s:Array = [];
        for(var i:int = 0;i<8;i++) {
            mp3s.push("../audio/MixBoxTestTrack 0" + (i + 1) + ".mp3");
        }

        tempo = new Tempo(120);
        multiTrackBox = new MultiTrackBox(tempo);
        multiTrackBox.sequence.barCount = tempo.secondsToBars(120);

        multiTrackBox.transport = transport;
        addChild(multiTrackBox.boxOfTracks);

        progressMeter = new Sprite();
        addChild(progressMeter);
        progressMeter.x = (stage.stageWidth / 2) - 50;
        progressMeter.y = (stage.stageHeight / 2) - 5;

        multiTrackBox.addEventListener(Event.COMPLETE, allTracksLoaded);
        multiTrackBox.addEventListener(LoadProgressEvent.PROGRESS, loadProgress);
        multiTrackBox.loadMP3s(mp3s);

        addEventListener(Event.ENTER_FRAME, update);

        saveButton = new SaveButton();
        saveButton.addEventListener(MouseEvent.CLICK, save);
        saveButton.x = 10;
        saveButton.y = 400;
        saveButton.useHandCursor = true;
        saveButton.buttonMode = true;
        addChild(saveButton);
        loadButton = new LoadButton();
        loadButton.addEventListener(MouseEvent.CLICK, load);
        loadButton.x = 120;
        loadButton.y = 400;
        loadButton.useHandCursor = true;
        loadButton.buttonMode = true;
        addChild(loadButton);

        multiTrackBox.micTrack.x = 10;
        multiTrackBox.micTrack.y = 180;

        addChild(multiTrackBox.micTrack);

        engineInfo = new EngineInfo();
        addChild(engineInfo);
        engineInfo.x = 650;

        bufferFillTimeLimit = (4096 * 1000) / 44100;
        trace("BFTL : " + bufferFillTimeLimit);
        jsonLoader = new JsonLoader();
        jsonLoader.addEventListener(JsonLoadEvent.DATA_LOADED, sequenceLoaded);
    }

    private function sequenceLoaded(event:JsonLoadEvent):void {
        trace("Sequence Loaded : " + event.data);
        multiTrackBox.sequence.deserialize(event.data);

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
        transport.time = pos / 100;
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
        sequencerView.sequence = multiTrackBox.sequence;
    }

    private function save(event:MouseEvent = null):void {
        if(multiTrackBox.sequence && !multiTrackBox.sequence.isEmpty()) {
            var serialized:Object = multiTrackBox.sequence.serialize();
            trace("Serialized : " + serialized);
            trace(JSON.stringify(serialized));
        }
    }

    private function load(event:Event = null):void {
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
