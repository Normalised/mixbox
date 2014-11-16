/**
 * Created by Martin Wood-Mitrovski
 * Date: 13/11/2014
 * Time: 10:43
 */
package com.korisnamedia.musicbox.starling {
import com.korisnamedia.IndexEvent;
import com.korisnamedia.audio.AudioLoop;

import flash.events.MouseEvent;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

public class AnimatedCharacters extends Sprite {

    // Embed the Atlas XML
    [Embed(source="../../../../../gfx/testanim.xml", mimeType="application/octet-stream")]
    public static const AtlasXml:Class;

    // Embed the Atlas Texture:
    [Embed(source="../../../../../gfx/testanim.png")]
    public static const AtlasTexture:Class;

    private var atlas:TextureAtlas;

    private var characters:Vector.<MovieClip>;

    private static const log:ILogger = getLogger(AnimatedCharacters);
    private var charactersPerRow:uint = 3;
    private var characterWidth:Number = 110;
    private var characterHeight:Number = 90;

    public function AnimatedCharacters() {
        // create atlas
        var texture:Texture = Texture.fromBitmap(new AtlasTexture());
        var xml:XML = XML(new AtlasXml());
        atlas = new TextureAtlas(texture, xml);
        characters = new Vector.<MovieClip>();
        addEventListener(TouchEvent.TOUCH, onTouch);
    }

    public function addCharacter():MovieClip {
        var char:MovieClip = new MovieClip(atlas.getTextures("anim"), 30);
        addChild(char);
        var x:int = characters.length % charactersPerRow;
        char.x = x * characterWidth;
        char.y = Math.floor(characters.length / charactersPerRow) * characterHeight;
        characters.push(char);
        return char;
    }

    public function update(index:int, position:int, sample:AudioLoop):void {
        var mc:MovieClip = characters[index];

        var p2:Number = Math.round(position * sample.loopLengthInMsInverse * 400) % 100 ;
        mc.currentFrame = p2;
        // mc.currentFrame =
    }

    public function enabled(index:int, active:Boolean):void {

    }

    public function reset():void {
        for (var i:int = 0; i < characters.length; i++) {
            var clip:MovieClip = characters[i];
            clip.currentFrame = 1;
        }
    }

    private function onTouch(event:TouchEvent):void {
        var touches:Vector.<Touch> = event.getTouches(this,TouchPhase.ENDED);
        for (var i:int = 0; i < touches.length; i++) {
            var touch:Touch = touches[i];
            var id:int = characters.indexOf(touch.target as MovieClip);
            if(id > -1) {
                dispatchEvent(new IndexEvent(id));
            }
        }
    }
}
}
