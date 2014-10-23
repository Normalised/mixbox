/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/15/2014
 * Time: 6:14 PM
 */
package {
import com.korisnamedia.audio.AudioLoop;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.ByteArray;

public class WaveformRenderer extends Sprite {
    private var waveformLeft:Sprite;
    private var waveformRight:Sprite;
    private var cursor:Sprite;
    private var resolution:int;
    private var totalWidth:uint;

    private var yRatio:Number = 25;
    private var loopEndMarker:Sprite;
    private var loopStartMarker:Sprite;
    private var _sample:AudioLoop;

    public function WaveformRenderer() {

        waveformLeft = new Sprite();
        waveformRight = new Sprite();

        cursor = new Sprite();
        loopEndMarker = new Sprite();
        loopStartMarker = new Sprite();

        // Samples per pixel
        resolution = 250;

        // We set a basic line style and reset the drawing position for each Sprite
        waveformLeft.y = yRatio;
        waveformRight.y = (yRatio * 3) + 10;

        cursor.graphics.lineStyle(1, 0x000000);
        cursor.graphics.moveTo(0,0);
        cursor.graphics.lineTo(0,100);

        loopStartMarker.graphics.lineStyle(1, 0x00FF00);
        loopStartMarker.graphics.moveTo(0,0);
        loopStartMarker.graphics.lineTo(0,100);

        loopEndMarker.graphics.lineStyle(1, 0x00FF00);
        loopEndMarker.graphics.moveTo(0,0);
        loopEndMarker.graphics.lineTo(0,100);

        addChild(waveformLeft);
        addChild(waveformRight);
        addChild(cursor);
        addChild(loopEndMarker);
        addChild(loopStartMarker);

        if(!stage) {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        } else {
            addedToStage(null);
        }
    }

    public function verticalScale(i:int):void {
        yRatio = i;
        waveformLeft.y = yRatio;
        waveformRight.y = (yRatio * 3) + 10;
        cursor.scaleY = yRatio / 25;
        loopEndMarker.scaleY = yRatio / 25;
        loopStartMarker.scaleY = yRatio / 25;
        if(_sample != null) {
            render();
        }
    }

    private function addedToStage(event:Event):void {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
    }

    private function keyPressed(event:KeyboardEvent):void {
        if(event.keyCode == 65) {
            resolution -= 40;
        } else if (event.keyCode == 83) {
            resolution += 40;
        }

        if(resolution < 1) {
            resolution = 1;
        }
        render();
    }

    public function set sample(s:AudioLoop):void {
        _sample = s;
    }

    public function render():void {
        if(!_sample) return;

        var xPos:uint = 0;
        var xStep:uint = 1;
        var left:Number;
        var right:Number;

        waveformLeft.graphics.clear();
        waveformRight.graphics.clear();
        waveformLeft.graphics.lineStyle(0, 0xff0000);
        waveformRight.graphics.lineStyle(0, 0xff0000);

        waveformLeft.graphics.moveTo(0,0);
        waveformRight.graphics.moveTo(0,0);

        var leftTotal:int = _sample.leftChannel.length;

        var sectionSteps:int = resolution;
        for (var i:int = 0; i < leftTotal; i+=resolution) {

            if(i + resolution < leftTotal) {
                sectionSteps = resolution
            } else {
                sectionSteps = leftTotal - i;
            }
            var leftMin:Number = Number.MAX_VALUE;
            var rightMin:Number = Number.MAX_VALUE;
            var leftMax:Number = Number.MIN_VALUE;
            var rightMax:Number = Number.MIN_VALUE;

            for (var j:int = 0; j < sectionSteps; j++) {
                left = _sample.leftChannel[i + j];
                right = _sample.rightChannel[i + j];
                if (left < leftMin) leftMin = left;
                if (left > leftMax) leftMax = left;
                if (right < rightMin) rightMin = right;
                if (right > rightMax) rightMax = right;
            }
            waveformLeft.graphics.lineTo(xPos, leftMin * yRatio);
            waveformRight.graphics.lineTo(xPos, rightMin * yRatio);
            xPos += xStep;
            waveformLeft.graphics.lineTo(xPos, leftMax * yRatio);
            waveformRight.graphics.lineTo(xPos, rightMax * yRatio);
            xPos += xStep;

        }

        loopStartMarker.x = _sample.getLoopPoints().start * xPos;
        loopEndMarker.x = _sample.getLoopPoints().end * xPos;
        totalWidth = xPos;
    }

    public function showCursor(position:Number):void {
        cursor.x = position * totalWidth;
    }
}
}
