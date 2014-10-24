/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/17/2014
 * Time: 11:03 AM
 */
package com.korisnamedia.ui {
import flash.display.Sprite;

public class CircleMeter extends Sprite {
    private var line:Sprite;
    private var syncIndicator:Sprite;
    public function CircleMeter() {

        graphics.moveTo(0,0);
        graphics.lineStyle(1,0x777777);
        graphics.beginFill(0xAAAAAA,0.5);
        graphics.drawCircle(0,0,25);
        graphics.endFill();

        syncIndicator = new Sprite();
        syncIndicator.graphics.moveTo(0,0);
        syncIndicator.graphics.lineStyle(1,0xFF0000);
        syncIndicator.graphics.drawCircle(0,0,26);

        addChild(syncIndicator);
        syncIndicator.visible = false;

        line = new Sprite();
        line.graphics.moveTo(0,0);
        line.graphics.lineStyle(1,0x777777);
        line.graphics.lineTo(0,-25);
        addChild(line);
    }

    public function set enabled(e:Boolean):void {
        alpha = e ? 1.0 : 0.4;
    }

    public function update(position:Number, waitForQuantizedSync:Boolean):void {
        line.rotation = position * 360;
        syncIndicator.visible = waitForQuantizedSync;
    }
}
}
