/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 10:40 AM
 */
package com.korisnamedia.musicbox.ui {
import com.korisnamedia.IndexEvent;
import com.korisnamedia.ui.CircleMeter;
import com.korisnamedia.ui.MiniButton;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class BoxOfTracks extends Sprite {

    private var meterContainer:Sprite;
    private var trackButtons:Vector.<Sprite>;
    public var meters:Vector.<CircleMeter>;

    public function BoxOfTracks() {

        meterContainer = new Sprite();
        addChild(meterContainer);
        meterContainer.x = 30;
        meterContainer.y = 30;
        meters = new Vector.<CircleMeter>();
        trackButtons = new Vector.<Sprite>();
    }

    public function addTrack():void {
        var meter:CircleMeter = new CircleMeter();
        meterContainer.addChild(meter);
        meter.x = meters.length * 60;
        meters.push(meter);
        var miniButton:MiniButton = new MiniButton();
        meterContainer.addChild(miniButton);
        miniButton.x = meter.x - (miniButton.width * 0.5);
        miniButton.y = 30;
        miniButton.addEventListener(MouseEvent.CLICK, toggleTrack);
        trackButtons.push(miniButton);
    }

    private function toggleTrack(event:MouseEvent):void {
        var trackID:int = trackButtons.indexOf(event.target);
        dispatchEvent(new IndexEvent(trackID));
    }
}
}
