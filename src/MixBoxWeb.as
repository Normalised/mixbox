/**
 * Created by Martin Wood-Mitrovski
 * Date: 16/11/2014
 * Time: 13:45
 */
package {
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;

import org.as3commons.logging.api.LOGGER_FACTORY;

import org.as3commons.logging.setup.SimpleTargetSetup;

import org.as3commons.logging.setup.target.TraceTarget;

import starling.core.Starling;

use namespace LOGGER_FACTORY;

public class MixBoxWeb extends Sprite {

    private var _starling:Starling;

    public function MixBoxWeb() {

        AppConfig.useNativeScreen = false;
        LOGGER_FACTORY.setup = new SimpleTargetSetup(new TraceTarget());

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        Starling.handleLostContext = true;
        addEventListener(Event.ADDED_TO_STAGE, start);
    }

    private function start(event:Event = null):void {
        _starling = new Starling(MixBox, stage);
        _starling.start();
    }
}
}
