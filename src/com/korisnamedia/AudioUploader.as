/**
 * Created by Martin Wood-Mitrovski
 * Date: 10/11/2014
 * Time: 16:28
 */
package com.korisnamedia {
import com.codecatalyst.promise.Deferred;
import com.codecatalyst.promise.Promise;
import com.korisnamedia.audio.AudioLoop;

import flash.events.Event;

import flash.events.HTTPStatusEvent;
import flash.events.IEventDispatcher;

import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;

import flash.net.URLRequest;
import flash.net.URLRequestHeader;

import flash.net.URLRequestMethod;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;

public class AudioUploader {
    private var url:String;
    private var loader:URLLoader;
    private var currentRequest:Deferred;

    public function AudioUploader(url:String) {
        this.url = url;
        loader = new URLLoader();
        configureListeners(loader);
    }

    private function configureListeners(dispatcher:IEventDispatcher):void {
        dispatcher.addEventListener(Event.COMPLETE, completeHandler);
        dispatcher.addEventListener(Event.OPEN, openHandler);
        dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
        dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
    }

    private function ioErrorHandler(event:IOErrorEvent):void {
        currentRequest.reject("IO Error " + event.errorID);
    }

    private function httpStatusHandler(event:HTTPStatusEvent):void {

    }

    private function securityErrorHandler(event:SecurityErrorEvent):void {
        currentRequest.reject("Security Error");
    }

    private function progressHandler(event:ProgressEvent):void {

    }

    private function openHandler(event:Event):void {

    }

    private function completeHandler(event:Event):void {
        trace("Complete : " + loader.data);
        currentRequest.resolve(loader.data);
    }

    public function upload(audio:AudioLoop):Promise {

        var leftChannel:Vector.<Number> = audio.leftChannel;
        trace("AudioUploader uploading " + (audio.loopEnd - audio.loopStart) + " samples");
        var bytes:ByteArray = new ByteArray();
        for (var i:int = audio.loopStart; i < audio.loopEnd; i++) {
            var val:Number = leftChannel[i];
            var truncated:int = (val * 32767);
            bytes.writeShort(truncated);
        }
        trace("Converted bytes " + bytes.length);
        bytes.compress(CompressionAlgorithm.LZMA);
        trace("Compressed bytes " + bytes.length);

        currentRequest = new Deferred();
        // Convert audio to something
        // For now just send raw bytes

//        bytes.writeObject(audio);

        var request:URLRequest = new URLRequest (url);
        request.contentType = "application/octet-stream";
        request.method = URLRequestMethod.POST;
        request.data = bytes;
        request.requestHeaders.push(new URLRequestHeader('Cache-Control', 'no-cache'));
        loader.dataFormat = URLLoaderDataFormat.BINARY;
        loader.load(request);
        return currentRequest.promise;
    }

}
}
