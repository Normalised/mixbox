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
    private var acceptRecordingButton:MovieClip;

    private var basicButtonContainer:DisplayObjectContainer;
    private var recordingButtonContainer:DisplayObjectContainer;

    public static const MUTE:String = "muteEvent";
    public static const SHARE:String = "shareEvent";
    public static const RESET:String = "resetEvent";
    public static const CANCEL:String = "cancelEvent";
    public static const ACCEPT:String = "acceptEvent";
    public static const RECORD:String = "recordEvent";

    private var buttonEventMap:Object;
    private static const border:int = 8;

    public function ButtonBar(controlsAtlas:TextureAtlas) {

        // or do the same in one line:
        muteButton = new MovieClip(controlsAtlas.getTextures("MuteButton"));
        shareButton = new MovieClip(controlsAtlas.getTextures("ShareButton"));
        resetButton = new MovieClip(controlsAtlas.getTextures("ResetButton"));

        recordButton = new MovieClip(controlsAtlas.getTextures("RecordButton"));

        acceptRecordingButton = new MovieClip(controlsAtlas.getTextures("OkButton"));
        cancelRecordingButton = new MovieClip(controlsAtlas.getTextures("CancelButton"));

        basicButtonContainer = new Sprite();
        recordingButtonContainer = new Sprite();

        basicButtonContainer.addChild(muteButton);
        basicButtonContainer.addChild(shareButton);
        basicButtonContainer.addChild(resetButton);

        recordingButtonContainer.addChild(recordButton);
        recordingButtonContainer.addChild(acceptRecordingButton);
        recordingButtonContainer.addChild(cancelRecordingButton);

        addChild(basicButtonContainer);
        addChild(recordingButtonContainer);

        recordingButtonContainer.visible = false;

        buttonEventMap = new Dictionary();
        buttonEventMap[muteButton] = MUTE;
        buttonEventMap[shareButton] = SHARE;
        buttonEventMap[resetButton] = RESET;
        buttonEventMap[recordButton] = RECORD;
        buttonEventMap[acceptRecordingButton] = ACCEPT;
        buttonEventMap[cancelRecordingButton] = CANCEL;

        addEventListener(TouchEvent.TOUCH, buttonTouched);
    }

    public function doLayout(width:Number):void {

        shareButton.x = (width - shareButton.width) / 2;
        muteButton.x = shareButton.x - 150;
        resetButton.x = shareButton.x + 150;
    }

    private function buttonTouched(event:TouchEvent):void {
        var touches:Vector.<Touch> = event.getTouches(this,TouchPhase.ENDED);

        if(touches.length == 0) return;
        var firstTouch:Touch = touches[0];
        if(buttonEventMap[firstTouch.target]) {
            dispatchEvent(new ButtonEvent(buttonEventMap[firstTouch.target]));
        }
    }
}
}