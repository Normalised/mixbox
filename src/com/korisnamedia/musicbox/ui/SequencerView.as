/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/22/2014
 * Time: 10:46 AM
 */
package com.korisnamedia.musicbox.ui {
import com.korisnamedia.audio.sequence.Sequence;
import com.korisnamedia.audio.sequence.SequenceTrack;

import flash.display.Sprite;

public class SequencerView extends Sprite {
    private var _sequence:Sequence;

    private var tracks:Vector.<Sprite>;

    public function SequencerView() {
        tracks = new Vector.<Sprite>();
    }

    public function set sequence(sq:Sequence):void {
        _sequence = sq;
        createTracks();
    }

    private function createTracks():void {
        for (var i:int = 0; i < _sequence.tracks.length; i++) {
            var st:SequenceTrack = _sequence.tracks[i];
            createTrackUI(st);
        }
    }

    private function createTrackUI(st:SequenceTrack):void {
        trace("Create trackUI");
        var trackUI:SequencerTrackView = new SequencerTrackView();
        trackUI.sequencerTrack = st;
        trackUI.y = tracks.length * 12;
        tracks.push(trackUI);
        addChild(trackUI);
    }
}
}
