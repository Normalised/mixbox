/**
 * Created by Martin Wood-Mitrovski
 * Date: 05/11/2014
 * Time: 09:44
 */
package com.korisnamedia.musicbox.data {
import flash.events.Event;

public class JsonLoadEvent extends Event {
    public static const DATA_LOADED:String = "jsonDataLoaded";
    public var data:Object;

    public function JsonLoadEvent(data:Object) {
        super(DATA_LOADED);
        this.data = data;
    }
}
}
