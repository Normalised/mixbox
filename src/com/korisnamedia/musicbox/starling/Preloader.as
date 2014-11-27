/**
 * Created by Martin Wood-Mitrovski
 * Date: 16/11/2014
 * Time: 13:59
 */
package com.korisnamedia.musicbox.starling {
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;

public class Preloader extends Sprite {
    private var bar:Quad;
    private var img:Image;
    public function Preloader() {

        img = new Image(Texture.fromBitmap(new MixBoxAssets.LoadingImage()));
        addChild(img);
        bar = new Quad(100,10,0x777777);
        addChild(bar);
        bar.width = 1;
        bar.y = img.height + 10;
        bar.x = (img.width - 100) / 2;
    }


    public function set progress(p:Number):void {
        bar.width = p;
    }

    public function doLayout(w:int, h:int):void {
        x = (w - img.width) / 2;
        y = (h - img.height) / 2;
    }
}
}
