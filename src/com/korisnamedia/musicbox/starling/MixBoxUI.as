/**
 * Created by Martin Wood-Mitrovski
 * Date: 13/11/2014
 * Time: 10:32
 */
package com.korisnamedia.musicbox.starling {
import com.korisnamedia.IndexEvent;
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.MixEngine;

import flash.events.MouseEvent;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

import starling.display.MovieClip;

import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class MixBoxUI extends Sprite {

    private static const log:ILogger = getLogger(MixBoxUI);

    private var robots:AnimatedCharacters;
    private var mixEngine:MixEngine;
    public var countInStartBeat:Number;
    public var waitForCountIn:Boolean = false;
    private var playingMetronome:Boolean = false;
    private var metroSound:MooMetronome;
    private var countDownAnim:CountDown;

    [Embed(source="../../../../../gfx/controls.xml", mimeType="application/octet-stream")]
    public static const ControlsAtlasXml:Class;
    [Embed(source="../../../../../gfx/controls.png")]
    public static const ControlsTexture:Class;

    private var controlsAtlas:TextureAtlas;
    private var buttonBar:ButtonBar;

    public function MixBoxUI() {
        var texture:Texture = Texture.fromBitmap(new ControlsTexture());
        var xml:XML = XML(new ControlsAtlasXml());
        controlsAtlas = new TextureAtlas(texture, xml);
    }

    public function init(mixEngine:MixEngine):void {

        this.mixEngine = mixEngine;

        metroSound = new MooMetronome();
        robots = new AnimatedCharacters();
        countDownAnim = new CountDown(controlsAtlas);
        buttonBar = new ButtonBar(controlsAtlas);
        buttonBar.addEventListener(ButtonEvent.TYPE, buttonTouched);

        addChild(robots);
        addChild(countDownAnim);
        addChild(buttonBar);

        robots.addEventListener(IndexEvent.TYPE, robotClicked);

        countDownAnim.visible = false;
        addEventListener(Event.ENTER_FRAME, frameUpdate);

        doLayout();
    }

    public function doLayout():void {
        buttonBar.y = stage.stageHeight - 60;
        buttonBar.doLayout(stage.stageWidth);
        robots.x = (stage.stageWidth - robots.width) / 2;
        robots.y = 10;
        countDownAnim.x = (stage.stageWidth - countDownAnim.width) / 2;
    }

    private function buttonTouched(event:ButtonEvent):void {
        log.debug("Button Touched : " + event.button);
    }

    private function frameUpdate(event:Event):void {
        var sample:AudioLoop;
        // NOTE : Not using sequence yet
//        var et:Number = mixEngine.getSequencePosition();
//        if((playingSequence || recording) && (et >= sequence.barCount)) {
//            trace("Sequence pos is past end time. " + et + " : " + sequence.barCount);
//            stop(null);
//        }
        if (waitForCountIn) {
            var barPos:Number = Math.round((mixEngine.sequencePosition * 4));
//            trace("Bar Pos : " + barPos);
            var p:Number = barPos - countInStartBeat;
            if (p >= 5) {
                log.debug("Count In finished");
                waitForCountIn = false;
                endCountDown();
            } else if (p >= 1) {
                if (!playingMetronome && (p == 1)) {
                    playMetronome();
                }
                var beatsToStartPoint:Number = (5 - p);
                mixEngine.gain = (beatsToStartPoint / 6) + 0.33;
                countDownAnim.show(p - 1);
            }
        }
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            sample = mixEngine.channels[i];
            if (!sample.active || !mixEngine.playing) {
                robots.update(i, 0, sample);
                robots.enabled(i, sample.active);
                continue;
            }

            var sp:Number = sample.position;
            if (sp < mixEngine.latency) {
                sp += sample.loopLengthInMilliseconds;
            }
            sp -= mixEngine.latency;

            robots.enabled(i, true);
            robots.update(i, sp, sample);
        }
    }

    private function playMetronome():void {
        playingMetronome = true;
        // TODO : Dispatch event, don't play sounds here
        metroSound.play();
    }

    public function startCountDown():void {
        var currentPos:Number = mixEngine.sequencePosition;
        var nextBoundary:Number = (Math.ceil(currentPos / 2)) * 2;
        var barsToBoundary:Number = nextBoundary - currentPos;
        log.debug("Bars to boundary : " + barsToBoundary);
        waitForCountIn = true;
        if(barsToBoundary >= 1) {
            // Start count-in at the next boundary
            log.debug("Starting countin at " + (nextBoundary - 1));
            countInStartBeat = (nextBoundary - 1) * 4;
        } else {
            // Start count-in at the next + 1 boundary
            log.debug("Wait to start countin at " + (nextBoundary + 1));
            countInStartBeat = (nextBoundary + 1) * 4;
        }
        countDownAnim.show(4);
        countDownAnim.visible = true;
    }

    public function endCountDown():void {
        playingMetronome = false;
        countDownAnim.visible = false;
    }

    public function addTrack():void {
        var robot:MovieClip = robots.addCharacter();
        robot.addEventListener(IndexEvent.TYPE, robotClicked);
        robots.x = (stage.stageWidth - robots.width) / 2;
        countDownAnim.y = robots.y + robots.height + 10;
    }

    private function robotClicked(event:IndexEvent):void {
        dispatchEvent(event.clone());
    }

    public function resetCharacters():void {
        robots.reset();
    }
}
}
