/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/22/2014
 * Time: 8:29 AM
 */
package com.korisnamedia.musicbox.ui {
import flash.events.Event;

public class TransportEvent extends Event {

    public static const PLAY:String = "playEvent";
    public static const STOP:String = "stopEvent";
    public static const RECORD:String = "recordEvent";
    public static const PLAY_SEQUENCE:String = "playSequenceEvent";

    public function TransportEvent(type:String) {
        super(type);
    }
}
}
