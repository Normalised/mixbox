/**
 * Created by Martin Wood-Mitrovski
 * Date: 16/11/2014
 * Time: 13:52
 */
package com.korisnamedia.musicbox.ui {
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.musicbox.audio.MicTrack;

import flash.display.Sprite;
import flash.events.Event;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

public class NativeUI {

    private static const log:ILogger = getLogger(NativeUI);
    private var saveButton:SaveButton;
    private var loadButton:LoadButton;
    private var engineInfo:EngineInfo;
    private var bufferFillTimeLimit:Number;
    private var container:Sprite;
    public var micTrack:MicTrack;
    private var _mixEngine:MixEngine;

    public function NativeUI(container:Sprite) {

        this.container = container;
        log.debug("Native UI : " + container.stage.stageWidth + ", " + container.stage.stageHeight);
        //        sequencerView = new SequencerView();
        ////        addChild(sequencerView);
        //        sequencerView.x = 10;
        //        sequencerView.y = 150;

//        saveButton = new SaveButton();
//        saveButton.addEventListener(MouseEvent.CLICK, save);
//        saveButton.useHandCursor = true;
//        saveButton.buttonMode = true;
//        container.addChild(saveButton);
//        loadButton = new LoadButton();
//        loadButton.addEventListener(MouseEvent.CLICK, load);
//        loadButton.useHandCursor = true;
//        loadButton.buttonMode = true;
//        container.addChild(loadButton);

        micTrack = new MicTrack(AppConfig.tempo, 4);

        engineInfo = new EngineInfo();
        container.addChild(engineInfo);
        container.addChild(micTrack);

        bufferFillTimeLimit = (4096 * 1000) / 44100;
        trace("BFTL : " + bufferFillTimeLimit);

        container.addEventListener(Event.ENTER_FRAME, update);
        doLayout();
    }

    public function doLayout():void {

        engineInfo.x = (container.stage.stageWidth / 2) - (engineInfo.width / 2);
        engineInfo.y = container.stage.stageHeight - 200;

        if(micTrack) {
            micTrack.x = 10;
            micTrack.y = engineInfo.y;
        }
    }

    public function set mixEngine(engine:MixEngine):void {
        _mixEngine = engine;
    }

    private function update(event:Event):void {
        if(!_mixEngine) return;
        var pos:Number = Math.floor(_mixEngine.latencyAdjustSequencePosition * 100);
//        transport.time = pos / 100;
        engineInfo.latency.text = _mixEngine.latency.toString();
        engineInfo.mixTime.text = _mixEngine.writeTime.toString();
        engineInfo.writeTime.text = _mixEngine.mixTime.toString();
        engineInfo.loadMeter.scaleX = (_mixEngine.mixTime + _mixEngine.writeTime) / bufferFillTimeLimit;
//        if(multiTrackBox.playingSequence || multiTrackBox.recording) {
//            sequencerView.time = pos / 100;
//        }
    }

}
}
