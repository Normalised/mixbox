/**
 * Created by Martin Wood-Mitrovski
 * Date: 15/11/2014
 * Time: 17:57
 */
package com.korisnamedia.musicbox.starling {
import starling.events.Event;

public class ButtonEvent extends Event {
    public static const TYPE:String = "buttonEvent";

    public var button:String;

    public function ButtonEvent(button:String) {
        super(TYPE);
        this.button = button;
    }

    public function clone():Event {
        var be:ButtonEvent = new ButtonEvent(button);
        return be;
    }
}
}
