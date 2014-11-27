/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/18/2014
 * Time: 11:01 AM
 */
package com.korisnamedia.musicbox.starling {
import starling.events.Event;

public class IndexEvent extends Event {
    public static const TYPE:String = "indexEvent";

    public var index:Number;

    public function IndexEvent(id:Number) {
        super(TYPE);
        index = id;
    }

    public function clone():Event {
        var ie:IndexEvent = new IndexEvent(index);
        return ie;
    }
}
}
