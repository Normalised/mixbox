/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/17/2014
 * Time: 5:16 PM
 */
package com.korisnamedia.musicbox.ui {
import com.korisnamedia.ui.*;
import com.korisnamedia.audio.filters.StateVariableFilter;
import com.korisnamedia.ui.Knob;

import flash.display.Sprite;
import flash.events.Event;

public class FilterControls extends Sprite {
    private var cutoffKnob:Knob;
    private var qKnob:Knob;
    private var _filter:StateVariableFilter;
    public var modules:Array;

    public function FilterControls() {

        modules = [];

        cutoffKnob = new Knob("Cutoff", 60, 5000,2000);
        qKnob = new Knob("Q", 80, 300, 100);

        cutoffKnob.addEventListener(Event.CHANGE, cutoffChanged);
        qKnob.addEventListener(Event.CHANGE, qChanged);

        addChild(cutoffKnob);
        addChild(qKnob);
        qKnob.x = 35;
    }

    public function set filter(f:StateVariableFilter):void {
        _filter = f;
    }

    private function qChanged(event:Event):void {
        if(modules.length) {
            modules[0].q = qKnob.value * 0.01;
            modules[1].q = qKnob.value * 0.01;
        }
    }

    private function cutoffChanged(event:Event):void {
        if(modules.length) {
            modules[0].cutoff = cutoffKnob.value;
            modules[1].cutoff = cutoffKnob.value;
        }

    }
}
}
