/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/22/2014
 * Time: 10:46 AM
 */
package com.korisnamedia.musicbox.ui {
import com.korisnamedia.audio.sequence.Sequence;
import com.korisnamedia.audio.sequence.SequenceTrack;

import flash.display.Graphics;

import flash.display.Sprite;

public class SequencerView extends Sprite {
    private var _sequence:Sequence;

    private var tracks:Vector.<Sprite>;
    private var cursor:Sprite;
    private var trackHeight:Number;
    private var timescale:int;
    private var totalWidth:Number;
    private var border:Sprite;

    public function SequencerView() {
        trackHeight = 8;
        timescale = 8;
        tracks = new Vector.<Sprite>();
        border = new Sprite();
        cursor = new Sprite();
    }

    public function set sequence(sq:Sequence):void {
        _sequence = sq;
        totalWidth = _sequence.barCount * timescale;
        createTracks();
        createBorder();
        createCursor();
    }

    private function createBorder():void {
        var g:Graphics = border.graphics;
        g.lineStyle(0,0xDDDDDD);
        for(var j:int = 1;j<_sequence.tracks.length;j++) {
            g.moveTo(0,j * trackHeight);
            g.lineTo(totalWidth, j * trackHeight);
        }
        g.lineStyle(0,0x888888);
        for(var i:int = 1;i<_sequence.barCount;i++) {
            if(i % 4 == 0) {
                g.lineStyle(0,0x888888);
            } else {
                g.lineStyle(0,0xDDDDDD);
            }
            g.moveTo(i * timescale,0);
            g.lineTo(i * timescale,_sequence.tracks.length * trackHeight);
        }
        g.moveTo(0,0);
        g.lineStyle(0,0x333333);
        g.drawRect(0,0,totalWidth,_sequence.tracks.length * trackHeight);

        addChild(border);
    }

    private function createCursor():void {
        cursor.graphics.moveTo(0,0);
        cursor.graphics.lineStyle(1,0x000000);
        cursor.graphics.lineTo(0,_sequence.tracks.length * trackHeight);
        addChild(cursor);
    }

    private function createTracks():void {
        for (var i:int = 0; i < _sequence.tracks.length; i++) {
            var st:SequenceTrack = _sequence.tracks[i];
            createTrackUI(st);
        }
    }

    private function createTrackUI(st:SequenceTrack):void {
        trace("Create trackUI");
        var trackUI:SequencerTrackView = new SequencerTrackView(trackHeight);
        trackUI.timeScale = timescale;
        trackUI.sequencerTrack = st;
        trackUI.y = tracks.length * trackHeight;
        tracks.push(trackUI);
        addChild(trackUI);
    }

    public function set time(time:Number):void {
        cursor.x = time * timescale;
    }
}
}
