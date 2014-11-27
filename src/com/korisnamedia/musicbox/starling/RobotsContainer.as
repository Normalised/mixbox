/**
 * Created by Martin Wood-Mitrovski
 * Date: 13/11/2014
 * Time: 10:43
 */
package com.korisnamedia.musicbox.starling {
import com.korisnamedia.audio.AudioLoop;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class RobotsContainer extends Sprite {

    private var characters:Vector.<MovieClip>;

    private static const log:ILogger = getLogger(RobotsContainer);
    private var charactersPerRow:uint = 4;
    private var dontTriggerMic:Boolean = false;
    private var layoutWidth:int;
    private var layoutHeight:Number;
    private var positions:Array;

    public function RobotsContainer() {

        positions = [];
        characters = new Vector.<MovieClip>();
        addEventListener(TouchEvent.TOUCH, onTouch);
    }

    public function addCharacter(index:int):MovieClip {
        var letter:String = String.fromCharCode(65 + index);
        var char:MovieClip = new MovieClip(MixBoxAssets.getInstance().getTextures("robot" + letter));
//        char.alignPivot();
        addChild(char);
        characters.push(char);
        return char;
    }

    public function enabled(index:int, active:Boolean):void {

    }

    public function reset():void {
        for (var i:int = 0; i < characters.length; i++) {
            var clip:MovieClip = characters[i];
            clip.currentFrame = 0;
        }
    }

    private function onTouch(event:TouchEvent):void {
        var touches:Vector.<Touch> = event.getTouches(this,TouchPhase.ENDED);
        for (var i:int = 0; i < touches.length; i++) {
            var touch:Touch = touches[i];
            var id:int = characters.indexOf(touch.target as MovieClip);
            if(id > -1) {
                if(dontTriggerMic && id == AppConfig.micTrackID) {
                    log.warn("Mic is disabled")
                } else {
                    dispatchEvent(new IndexEvent(id));
                }
            }
        }
    }

    public function disableMicChannel():void {
        characters[AppConfig.micTrackID].alpha = 0.5;
        dontTriggerMic = true;
    }

    public function doLayout(w:int, h:Number):void {
        layoutWidth = w;
        layoutHeight = h;

        if(characters.length == 0) {
            log.debug("No characters, saving layout info " + w + ", " + h);
            return;
        }
        updateLayout();
    }

    public function updateLayout():void {
        log.debug("Update layout : " + layoutWidth + ", " + layoutHeight);
        var w:Number = layoutWidth - 16;
        var h:Number = layoutHeight - 16;
        var wPerBot:Number = w / charactersPerRow;
        var hPerBot:Number = h / charactersPerRow;
        var size:Number = Math.min(wPerBot, hPerBot);

        x = (layoutWidth - (size * charactersPerRow)) / 2;
        y = (layoutHeight - (size * Math.ceil(characters.length / charactersPerRow))) / 2;

        log.debug("Char Size " + size);
        for (var i:int = 0; i < characters.length; i++) {
            var char:MovieClip = characters[i];
            var x:int = i % charactersPerRow;

            char.x = (x * size) + 8;
            char.y = (Math.floor(i / charactersPerRow) * size) + 8;
            char.width = size;
            char.scaleY = char.scaleX;
            positions[i] = {x:char.x,y:char.y,w:char.width,h:char.height};
        }
    }
}
}
