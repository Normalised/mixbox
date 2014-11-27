/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/16/2014
 * Time: 9:45 PM
 */
package com.korisnamedia.musicbox.ui {
import flash.display.Sprite;

public class MiniButton extends Sprite {

    public function MiniButton() {

        graphics.moveTo(0,0);
        graphics.beginFill(0x777777);
        graphics.lineTo(16,0);
        graphics.lineTo(16,16);
        graphics.lineTo(0,16);
        graphics.lineTo(0,0);
        graphics.endFill();

    }
}
}
