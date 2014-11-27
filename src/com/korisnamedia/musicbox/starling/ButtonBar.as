/**
 * Created by Martin Wood-Mitrovski
 * Date: 15/11/2014
 * Time: 15:45
 */
package com.korisnamedia.musicbox.starling {

import flash.utils.Dictionary;

import starling.display.DisplayObjectContainer;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.TextureAtlas;

public class ButtonBar extends Sprite {

    private var muteButton:MovieClip;
    private var shareButton:MovieClip;
    private var resetButton:MovieClip;

    private var cancelRecordingButton:MovieClip;
    private var recordButton:MovieClip;
//    private var acceptRecordingButton:MovieClip;

    private var basicButtonContainer:DisplayObjectContainer;
    private var recordingButtonContainer:DisplayObjectContainer;

    public static const MUTE:String = "muteEvent";
    public static const SHARE:String = "shareEvent";
    public static const RESET:String = "resetEvent";
    public static const CANCEL:String = "cancelEvent";
//    public static const ACCEPT:String = "acceptEvent";
    public static const RECORD:String = "recordEvent";
    public static const PLAY:String = "playEvent";

    private var buttonEventMap:Object;
    private const BUTTON_SPACING:Number = 64;
//    private var playButton:MovieClip;

    public function ButtonBar() {

        var assets:MixBoxAssets = MixBoxAssets.getInstance();
        muteButton = new MovieClip(assets.getTextures("MuteButton"));
        shareButton = new MovieClip(assets.getTextures("ShareButton"));
        resetButton = new MovieClip(assets.getTextures("ResetButton"));
        recordButton = new MovieClip(assets.getTextures("RecordButton"));
//        playButton = new MovieClip(controlsAtlas.getTextures("PlayButton"));

//        acceptRecordingButton = new MovieClip(controlsAtlas.getTextures("OkButton"));
        cancelRecordingButton = new MovieClip(assets.getTextures("CancelButton"));

        basicButtonContainer = new Sprite();
        recordingButtonContainer = new Sprite();

        basicButtonContainer.addChild(muteButton);
        basicButtonContainer.addChild(shareButton);
        basicButtonContainer.addChild(resetButton);

        recordingButtonContainer.addChild(recordButton);
//        recordingButtonContainer.addChild(acceptRecordingButton);
        recordingButtonContainer.addChild(cancelRecordingButton);
//        recordingButtonContainer.addChild(playButton);

//        playButton.visible = false;

        basicButtonContainer.height = 48;
        basicButtonContainer.scaleX = basicButtonContainer.scaleY;
        recordingButtonContainer.height = 48;
        recordingButtonContainer.scaleX = recordingButtonContainer.scaleY;

        addChild(basicButtonContainer);
        addChild(recordingButtonContainer);

        recordingButtonContainer.visible = false;

        buttonEventMap = new Dictionary();
        buttonEventMap[muteButton] = MUTE;
        buttonEventMap[shareButton] = SHARE;
        buttonEventMap[resetButton] = RESET;
        buttonEventMap[recordButton] = RECORD;
//        buttonEventMap[acceptRecordingButton] = ACCEPT;
        buttonEventMap[cancelRecordingButton] = CANCEL;
//        buttonEventMap[playButton] = PLAY;

        addEventListener(TouchEvent.TOUCH, buttonTouched);
    }

    public function doLayout(width:Number):void {

        shareButton.x = muteButton.width + BUTTON_SPACING;
        resetButton.x = shareButton.x + shareButton.width + BUTTON_SPACING;
        recordButton.x = cancelRecordingButton.width + BUTTON_SPACING;

        recordingButtonContainer.y = basicButtonContainer.y = 4;
        recordingButtonContainer.x = (width / 2) - (recordButton.x * recordingButtonContainer.scaleX);
        basicButtonContainer.x = (width - basicButtonContainer.width) / 2;
    }

    private function buttonTouched(event:TouchEvent):void {
        var touches:Vector.<Touch> = event.getTouches(this,TouchPhase.ENDED);

        if(touches.length == 0) return;
        var firstTouch:Touch = touches[0];
        if(buttonEventMap[firstTouch.target]) {
            dispatchEvent(new ButtonEvent(buttonEventMap[firstTouch.target]));
        }
    }

    public function showRecordingControls(hasRecording:Boolean):void {
        recordingButtonContainer.visible = true;
        basicButtonContainer.visible = false;
        if(hasRecording) {
            cancelRecordingButton.visible = true;
//            recordButton.visible = false;
//            playButton.visible = true;
//            playButton.currentFrame = isPlaying ? 1 : 0;
        } else {
            cancelRecordingButton.visible = false;
        }
    }

    public function showMainControls():void {
        recordingButtonContainer.visible = false;
        basicButtonContainer.visible = true;
    }

    public function set muted(m:Boolean):void {
        muteButton.currentFrame = m ? 1 : 0;
    }

    public function recordComplete():void {
//        recordButton.visible = false;
        cancelRecordingButton.visible = true;
        recordButton.currentFrame = 0;
//        playButton.visible = true;
    }

    public function set recording(recording:Boolean):void {
        recordButton.currentFrame = recording ? 1 : 0;
    }
}
}
