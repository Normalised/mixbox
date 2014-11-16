/**
 * Created by Martin Wood-Mitrovski
 * Date: 16/11/2014
 * Time: 13:59
 */
package com.korisnamedia.musicbox.starling {
import starling.display.Quad;
import starling.display.Sprite;

public class Preloader extends Sprite {
    private var bar:Quad;
    public function Preloader() {

        bar = new Quad(100,10,0x777777);
        addChild(bar);
    }


    public function set progress(p:Number):void {
        bar.width = p;
    }
}
}
