/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/22/2014
 * Time: 8:27 AM
 */
package com.korisnamedia.musicbox.ui {
import flash.display.Sprite;
import flash.events.MouseEvent;

public class TransportControls extends Sprite {

    private var playButton:PlayButton;
    private var stopButton:StopButton;
    private var recordButton:RecordButton;
    private var playSequenceButton:PlaySequenceButton;

    private var position:TransportPosition;

    public function TransportControls() {
        playButton = new PlayButton();
        stopButton = new StopButton();
        recordButton = new RecordButton();

        playSequenceButton = new PlaySequenceButton();

        position = new TransportPosition();

        addChild(playButton);
        addChild(stopButton);
        addChild(recordButton);
//        addChild(playSequenceButton);

        addChild(position);

        stopButton.x = 24;
        recordButton.x = 48;
        playSequenceButton.x = 80;
        playSequenceButton.center.visible = false;
        playSequenceButton.alpha = 0.3;
        position.y = 24;

        playButton.addEventListener(MouseEvent.CLICK, playClicked);
        playSequenceButton.addEventListener(MouseEvent.CLICK, playSequenceClicked);
        stopButton.addEventListener(MouseEvent.CLICK, stopClicked);
        recordButton.addEventListener(MouseEvent.CLICK, recordClicked);
    }

    public function set sequenceAvailable(s:Boolean):void {
        playSequenceButton.alpha = 1;
        playSequenceButton.center.visible = s;
    }

    private function recordClicked(event:MouseEvent):void {
        dispatchEvent(new TransportEvent(TransportEvent.RECORD));
    }

    private function stopClicked(event:MouseEvent):void {
        dispatchEvent(new TransportEvent(TransportEvent.STOP));
    }

    private function playClicked(event:MouseEvent):void {
        dispatchEvent(new TransportEvent(TransportEvent.PLAY));
    }

    private function playSequenceClicked(event:MouseEvent):void {
        trace("Play sequence clicked");
        dispatchEvent(new TransportEvent(TransportEvent.PLAY_SEQUENCE));
    }

    public function set time(pos:Number):void {
        position.position.text = pos.toString();
    }

    public function set playState(playState:Boolean):void {
        if(playState) {
//            recordButton.alpha = 0.3;
            playButton.alpha = 0.3;
            playSequenceButton.alpha = 0.3;
        } else {
            recordButton.alpha = 1;
            playButton.alpha = 1;
            playSequenceButton.alpha = 1;
        }
    }
}
}
