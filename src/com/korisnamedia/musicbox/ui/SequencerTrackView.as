/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/22/2014
 * Time: 10:51 AM
 */
package com.korisnamedia.musicbox.ui {
import com.korisnamedia.audio.sequence.SequenceEvent;
import com.korisnamedia.audio.sequence.SequenceTrack;

import flash.display.Sprite;
import flash.events.Event;

public class SequencerTrackView extends Sprite {

    private var _sequencerTrack:SequenceTrack;

    private var timeScale:Number = 20;
    private var size:Number = 9;

    public function SequencerTrackView() {
    }

    public function get sequencerTrack():SequenceTrack {
        return _sequencerTrack;
    }

    public function set sequencerTrack(value:SequenceTrack):void {
        _sequencerTrack = value;
        _sequencerTrack.addEventListener(Event.CHANGE, trackChanged);
    }

    // not really changed, but event added
    private function trackChanged(event:Event):void {
        render();
    }

    private function render():void {

        graphics.clear();
        graphics.lineStyle(1,0);
        graphics.moveTo(0,0);
        for (var i:int = 0; i < _sequencerTrack.events.length; i++) {
            var event:SequenceEvent = _sequencerTrack.events[i];
            var t:Number = event.time;
            if(event.data.state) {
                graphics.beginFill(0x00FF00);
            } else {
                graphics.beginFill(0xFF0000);
            }
            graphics.moveTo(t, 0);
            graphics.drawRect(t * timeScale, 0, size,size);
            graphics.endFill();
        }

    }
}
}
