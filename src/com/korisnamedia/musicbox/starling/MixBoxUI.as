/**
 * Created by Martin Wood-Mitrovski
 * Date: 13/11/2014
 * Time: 10:32
 */
package com.korisnamedia.musicbox.starling {
import com.korisnamedia.audio.AudioLoop;
import com.korisnamedia.audio.MicRecorder;
import com.korisnamedia.audio.MixEngine;

import flash.media.Sound;

import org.as3commons.logging.api.ILogger;
import org.as3commons.logging.api.getLogger;

import starling.display.Image;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

public class MixBoxUI extends Sprite {

    private static const log:ILogger = getLogger(MixBoxUI);

    private var robotsContainer:RobotsContainer;
    private var robots:Vector.<Robot>;
    private var mixEngine:MixEngine;
    public var countInStartBeat:Number;
    public var waitForCountIn:Boolean = false;
    private var playingMetronome:Boolean = false;
    private var countDownAnim:CountDown;

    private var buttonBar:ButtonBar;
    private var divider:Quad;
    private var countdownCover:Quad;
    private var recordProgressBar:Quad;
    private var preloader:Preloader;
    private var content:Sprite;
    private var layoutWidth:int;
    private var layoutHeight:int;
    private var _recording:Boolean = false;
    private var micRecorder:MicRecorder;
    private var _recordingEnabled:Boolean = false;
    private var beatsToStartPoint:Number = 128;
    private var metroSound:Sound;
    private var logo:Image;

    public function MixBoxUI() {

        robots = new Vector.<Robot>();
        addEventListener(Event.ADDED_TO_STAGE, addedToStage);
    }

    private function addedToStage(event:Event):void {

        log.debug("UI Added to stage : " + stage.stageWidth + ", " + stage.stageHeight);
        preloader = new Preloader();
        addChild(preloader);
        content = new Sprite();
        addChild(content);
        content.visible = false;
        preloader.doLayout(stage.stageWidth,stage.stageHeight);
    }

    public function init(mixEngine:MixEngine, micRecorder:MicRecorder):void {
        this.mixEngine = mixEngine;
        this.micRecorder = micRecorder;

        robotsContainer = new RobotsContainer();
        robotsContainer.addEventListener(IndexEvent.TYPE, robotClicked);

        divider = new Quad(256,1,0x333333);

        buttonBar = new ButtonBar();
        buttonBar.addEventListener(ButtonEvent.TYPE, buttonTouched);

        countDownAnim = new CountDown();
        recordProgressBar = new Quad(256,5,0xFF0000);
        countdownCover = new Quad(256,256,0x777777,true);
        countdownCover.alpha = 0.5;

        logo = new Image(Texture.fromBitmap(new MixBoxAssets.MooLogo()));
        logo.x = 16;
        logo.y = 16;
        logo.scaleX = logo.scaleY = 0.5;
        addChild(logo);

        content.addChild(robotsContainer);
        content.addChild(buttonBar);
        content.addChild(divider);
        content.addChild(recordProgressBar);
        content.addChild(countdownCover);
        content.addChild(countDownAnim);
        content.addChild(logo);

        recordProgressBar.visible = false;
        countDownAnim.visible = false;
        countdownCover.visible = false;

        doLayout(stage.stageWidth, stage.stageHeight);
    }

    public function doLayout(w:int,h:int):void {
        log.debug("Do Layout " + w + ", " + h);

        layoutWidth = w;
        layoutHeight = h;

        buttonBar.y = h - 60;
        buttonBar.doLayout(w);
        countDownAnim.x = (w - countDownAnim.width) / 2;
        countDownAnim.y = (buttonBar.y - countDownAnim.height) / 2;
        divider.y = buttonBar.y - 4;
        divider.width = w;
        countdownCover.width = w;
        countdownCover.height = divider.y;
        recordProgressBar.y = divider.y - 5;

        robotsContainer.doLayout(w, divider.y);
        preloader.doLayout(w,h);
    }

    private function buttonTouched(event:ButtonEvent):void {
        log.debug("Button Touched : " + event.button);
//        if(event.button == ButtonBar.ACCEPT) {
//            buttonBar.showMainControls();
//        }

        dispatchEvent(event.clone());
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
            var p:Number = barPos - countInStartBeat;
            log.debug("Wait for countIn Bar Pos : " + barPos + ". P: " + p);
            if (p >= 5) {
                log.debug("Count In finished");
                waitForCountIn = false;
                endCountDown();
            } else if (p >= 1) {
                if (!playingMetronome && (p == 1)) {
                    playMetronome();
                }
                if(beatsToStartPoint != (5 - p)) {
                    log.debug("Beats to start point changed " + (5 - p));
                    beatsToStartPoint = (5 - p);
//                    mixEngine.gain = (beatsToStartPoint / 6) + 0.33;
                    countDownAnim.show(p - 1);
                }
            }
        }
        if(micRecorder.recording) {
            if(!micRecorder.waitForSync) {
                recordingProgress = mixEngine.latencyAdjustSequencePosition / MicRecorder.BARS_TO_RECORD;
            }
        }
        for (var i:int = 0; i < mixEngine.channels.length; i++) {
            sample = mixEngine.channels[i];
            if (!sample.active || !mixEngine.playing) {
                robots[i].update(0);
                continue;
            }

            var sp:Number = sample.position;
            if (sp < mixEngine.latency) {
                sp += sample.loopLengthInMilliseconds;
            }
            sp -= mixEngine.latency;

            robots[i].update(mixEngine.sequencePosition);
        }
    }

    private function playMetronome():void {
        log.debug("Play Metronome");
        playingMetronome = true;
        // TODO : Dispatch event, don't play sounds here
        if(!metroSound) {
            metroSound = MixBoxAssets.getInstance().metronome;
        }
        metroSound.play();
    }

    public function startCountDown():void {
        log.debug("Start Countdown");
        var currentPos:Number = mixEngine.sequencePosition;
        var nextBoundary:Number = (Math.ceil(currentPos / 2)) * 2;
        var barsToBoundary:Number = nextBoundary - currentPos;
        log.debug("Current Pos : " + currentPos + ". Next Boundary : " + nextBoundary + ". Bars to boundary : " + barsToBoundary);
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
        log.debug("CountIn Start Beat " + countInStartBeat);
        countDownAnim.show(4);
        countdownCover.visible = true;
        countDownAnim.visible = true;
        recordProgressBar.visible = true;
        recordProgressBar.width = 1;
        _recording = true;
    }

    public function endCountDown():void {
        playingMetronome = false;
        countDownAnim.visible = false;
        countdownCover.visible = false;
    }

    public function addTrack(loop:AudioLoop, index:int):void {
        var robot:Robot = new Robot(robotsContainer.addCharacter(index), loop);
        robots.push(robot);
    }

    private function robotClicked(event:IndexEvent):void {
        dispatchEvent(event.clone());
    }

    public function resetCharacters():void {
        robotsContainer.reset();
    }

    public function showRecordingControls(hasRecording:Boolean):void {
        buttonBar.showRecordingControls(hasRecording);
    }

    public function showMainControls():void {
        buttonBar.showMainControls();
    }

    public function set muted(m:Boolean):void {
        buttonBar.muted = m;
    }

    public function recordComplete():void {
        buttonBar.recordComplete();
        recordProgressBar.width = 1;
        recordProgressBar.visible = false;
    }

    public function set recording(recording:Boolean):void {
        log.debug("Set Recording : " + recording);
        buttonBar.recording = recording;
        recordProgressBar.visible = recording;
        _recording = recording;
    }

    public function set recordingProgress(p:Number):void {
        recordProgressBar.width = p * layoutWidth;
    }

    public function set loadProgress(progress:Number):void {
        preloader.progress = progress;
    }

    public function showContent():void {
        preloader.visible = false;
        content.visible = true;
        addEventListener(Event.ENTER_FRAME, frameUpdate);
    }

    public function set recordingEnabled(recordingEnabled:Boolean):void {
        _recordingEnabled = recordingEnabled;
        if(!recordingEnabled) {
            robotsContainer.disableMicChannel();
        }
    }

    public function updateRobots():void {
        robotsContainer.updateLayout();
    }
}
}
