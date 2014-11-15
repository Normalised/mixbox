/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 10:40 AM
 */
package com.korisnamedia.musicbox.ui {
import com.korisnamedia.IndexEvent;
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.MixEngine;
import com.korisnamedia.ui.CircleMeter;
import com.korisnamedia.ui.MiniButton;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.Sound;

public class BoxOfTracks extends Sprite {

    private var meterContainer:Sprite;
    public var meters:Vector.<CircleMeter>;
    private var mixEngine:MixEngine;
    private var countIn:CountIn;
    public var countInStartBeat:Number;
    public var waitForCountIn:Boolean = false;
    private var playingMetronome:Boolean = false;

    private var metroSound:Sound;

    public function BoxOfTracks(mixEngine:MixEngine) {

        this.mixEngine = mixEngine;
        meterContainer = new Sprite();
        addChild(meterContainer);
        meterContainer.x = 30;
        meterContainer.y = 30;
        meters = new Vector.<CircleMeter>();

        countIn = new CountIn();
        addChild(countIn);
        countIn.x = 480;
        countIn.y = 200;
        countIn.visible = false;

        addEventListener(Event.ENTER_FRAME, frameUpdate);

        metroSound = new MooMetronome();
    }

    private function frameUpdate(event:Event):void {
        var sample:AudioLoop;
        var cm:CircleMeter;
        // NOTE : Not using sequence yet
//        var et:Number = mixEngine.getSequencePosition();
//        if((playingSequence || recording) && (et >= sequence.barCount)) {
//            trace("Sequence pos is past end time. " + et + " : " + sequence.barCount);
//            stop(null);
//        }
        if(waitForCountIn) {
            var barPos:Number = Math.round((mixEngine.sequencePosition * 4));
//            trace("Bar Pos : " + barPos);
            var p:Number = barPos - countInStartBeat;
            if(p >= 5) {
                trace("Count In finished");
                waitForCountIn = false;
                endCountDown();
            } else if(p >= 1) {
                if(!playingMetronome && (p == 1)) {
                    playMetronome();
                }
                var beatsToStartPoint:Number = (5 - p);
                mixEngine.gain = (beatsToStartPoint / 6) + 0.33;
                countDown = beatsToStartPoint.toString();
            }
        }
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            sample = mixEngine.channels[i];
            cm = meters[i];
            if(!sample.active || !mixEngine.playing) {
                cm.update(0, sample);
                cm.enabled = sample.active;
                continue;
            }

            var sp:Number = sample.position;
            if(sp < mixEngine.latency) {
                sp += sample.loopLengthInMilliseconds;
            }
            sp -= mixEngine.latency;

            cm.enabled = true;
            cm.update(sp, sample);
        }
    }

    private function playMetronome():void {
        playingMetronome = true;
        metroSound.play();
    }

    public function startCountDown():void {
        var currentPos:Number = mixEngine.sequencePosition;
        var nextBoundary:Number = (Math.ceil(currentPos / 2)) * 2;
        var barsToBoundary:Number = nextBoundary - currentPos;
        trace("Bars to boundary : " + barsToBoundary);
        waitForCountIn = true;
        if(barsToBoundary >= 1) {
            // Start count-in at the next boundary
            trace("Starting countin at " + (nextBoundary - 1));
            countInStartBeat = (nextBoundary - 1) * 4;
        } else {
            // Start count-in at the next + 1 boundary
            trace("Wait to start countin at " + (nextBoundary + 1));
            countInStartBeat = (nextBoundary + 1) * 4;
        }
        countDown = "!";
        countIn.visible = true;
    }

    public function endCountDown():void {
        playingMetronome = false;
        countIn.visible = false;
    }

    public function set countDown(countDown:String):void {
        countIn.countText.text = countDown;
    }
}
}
