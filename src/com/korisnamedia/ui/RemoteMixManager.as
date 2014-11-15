/**
 * Created by Martin Wood-Mitrovski
 * Date: 11/11/2014
 * Time: 15:46
 */
package com.korisnamedia.ui {
import com.codecatalyst.promise.Deferred;
import com.codecatalyst.promise.Promise;

import flash.events.Event;
import flash.events.HTTPStatusEvent;

import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

public class RemoteMixManager {

    private var url:String;
    private var loader:URLLoader;
    private var currentRequest:Deferred;
    private var endPoints:Object;

    private static const log:ILogger = getLogger(RemoteMixManager);
    public function RemoteMixManager(url:String, endPoints:Object) {

        this.url = url;
        this.endPoints = endPoints;

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
        log.debug("Complete : " + loader.data);
        currentRequest.resolve(loader.data);
    }

    public function load(mixId:String):Promise {
        currentRequest = new Deferred();

        log.debug("Load mix " + mixId + " from " + (url + endPoints.getMix));
        var request:URLRequest = new URLRequest (url + endPoints.getMix);
        var vars:URLVariables = new URLVariables();
        vars.id = mixId;
        request.method = URLRequestMethod.GET;
        request.data = vars;
        loader.load(request);
        return currentRequest.promise;
    }

    public function save(mix:Object):Promise {

        log.debug("Save Mix " + mix.toString());
        currentRequest = new Deferred();

        var request:URLRequest = new URLRequest (url + endPoints.saveMix);
        request.method = URLRequestMethod.POST;
        var vars:URLVariables = new URLVariables();
        vars.json = JSON.stringify(mix);
        request.data = vars;
        loader.load(request);
        return currentRequest.promise;
    }
}
}
