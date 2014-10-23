/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/16/2014
 * Time: 6:37 PM
 */
package {
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.MP3Loader;
import com.korisnamedia.audio.MicRecorder;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.audio.Oscilloscope;
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.audio.filters.IFilter;
import com.korisnamedia.audio.filters.StateVariableFilter;
import com.korisnamedia.musicbox.MicTrack;
import com.korisnamedia.musicbox.MultiTrackBox;
import com.korisnamedia.musicbox.ui.SequencerView;
import com.korisnamedia.musicbox.ui.TransportControls;
import com.korisnamedia.musicbox.ui.TransportEvent;
import com.korisnamedia.ui.MiniButton;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.system.Capabilities;
import flash.utils.Timer;

[SWF(width='800', height='600', frameRate='30')]
public class MixBox extends Sprite {

    private var multiTrackBox:MultiTrackBox;

    private var timer:Timer;
    private var filterControls:FilterControls;
    private var micTrack:MicTrack;
    private var transport:TransportControls;
    private var sequencerView:SequencerView;
    private var tempo:Tempo;

    public function MixBox() {

        tempo = new Tempo(120);
        multiTrackBox = new MultiTrackBox(tempo);
        addChild(multiTrackBox.boxOfTracks);

//        micTrack = new MicTrack(multiTrackBox.mixEngine);
//        addChild(micTrack);
//        multiTrackBox.addTrack(micTrack.audioData);

        transport = new TransportControls();
        addChild(transport);
        transport.x = 10;
        transport.y = 150;
        transport.addEventListener(TransportEvent.PLAY, playSequence);
        transport.addEventListener(TransportEvent.STOP, stopSequence);
        transport.addEventListener(TransportEvent.RECORD, recordSequence);


        sequencerView = new SequencerView();
        addChild(sequencerView);
        sequencerView.y = 250;
        var mp3s:Array = [];
        for(var i:int = 0;i<8;i++) {
            mp3s.push("../audio/MixBoxTestTrack 0" + (i + 1) + ".mp3");
        }

        multiTrackBox.addEventListener(Event.COMPLETE, allTracksLoaded);
        multiTrackBox.loadMP3s(mp3s);
    }

    private function recordSequence(event:TransportEvent):void {
        multiTrackBox.record();
    }

    private function stopSequence(event:TransportEvent):void {
        multiTrackBox.stop();
        transport.sequenceAvailable = !multiTrackBox.sequence.isEmpty();
    }

    private function playSequence(event:TransportEvent):void {
        multiTrackBox.start();
    }

    private function allTracksLoaded(event:Event = null):void {
        addEventListener(Event.ENTER_FRAME, updatePosition);
        sequencerView.sequence = multiTrackBox.sequence;
    }

    private function updatePosition(event:Event):void {
        var pos:Number = Math.floor(multiTrackBox.mixEngine.getLatencyAdjustedSequencePosition() * 100);
        transport.time = pos / 100;
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
