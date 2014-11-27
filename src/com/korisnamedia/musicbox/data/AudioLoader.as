/**
 * Created by Martin Wood-Mitrovski
 * Date: 11/11/2014
 * Time: 13:48
 */
package com.korisnamedia.musicbox.data {
import com.codecatalyst.promise.Deferred;
import com.codecatalyst.promise.Promise;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

public class AudioLoader {
    private var loader:URLLoader;
    private var defer:Deferred;
    private var url:String;

    private static const log:ILogger = getLogger(AudioLoader);
    public function AudioLoader(url:String) {
        this.url = url;
    }

    public function load(id:String):Promise {
        defer = new Deferred();
        var request:URLRequest = new URLRequest(url);
        var vars:URLVariables = new URLVariables();
        vars.id = id;
        request.data = vars;
        loader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.addEventListener(Event.COMPLETE, audioLoaded);
        loader.addEventListener(IOErrorEvent.IO_ERROR, loadError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
        loader.load(request);
        return defer.promise;
    }

    private function securityError(event:SecurityErrorEvent):void {
        defer.reject(event.errorID);
        log.debug("Security error " + event.errorID);
    }

    private function loadError(event:IOErrorEvent):void {
        defer.reject(event.errorID);
        log.debug("Load error " + event.errorID);
    }

    private function audioLoaded(event:Event):void {
        log.debug("Audio Loaded : " + loader.data.length);
        var bytes:ByteArray = loader.data;
        bytes.uncompress(CompressionAlgorithm.LZMA);
        bytes.position = 0;
        var audio:Vector.<Number> = new Vector.<Number>();
        var pos:int = 0;
        while(bytes.bytesAvailable) {
            var shortVal:int = bytes.readShort();
            var floatVal:Number = shortVal / 32767;
            audio[pos++] = floatVal;
        }
        log.debug("Audio : " + audio.length);
        defer.resolve(audio);
    }
}
}
