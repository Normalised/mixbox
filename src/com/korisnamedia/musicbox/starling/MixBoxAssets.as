/**
 * Created by Martin Wood-Mitrovski
 * Date: 22/11/2014
 * Time: 11:53
 */
package com.korisnamedia.musicbox.starling {
import com.greensock.events.LoaderEvent;
import com.greensock.loading.ImageLoader;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.MP3Loader;
import com.greensock.loading.XMLLoader;

import flash.display.Bitmap;
import flash.media.Sound;

import flash.utils.Dictionary;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

import starling.textures.Texture;

import starling.textures.TextureAtlas;

public class MixBoxAssets {

    [Embed(source="../../../../../gfx/FFF-loader.png")]
    public static const LoadingImage:Class;

    [Embed(source="../../../../../gfx/MOO-logo.png")]
    public static const MooLogo:Class;

    private static var _instance:MixBoxAssets;

    private static const log:ILogger = getLogger(MixBoxAssets);

    private var atlases:Dictionary;
    private var textures:Dictionary;
    private var _mp3s:Dictionary;
    private var _samples:Dictionary;

    private var graphicsLoader:LoaderMax;
    private var graphicsProgressHandler:Function;
    private var graphicsCompleteHandler:Function;

    private var audioLoader:LoaderMax;
    private var audioProgressHandler:Function;
    private var audioCompleteHandler:Function;

    public static function getInstance():MixBoxAssets {
        if(_instance == null) {
            _instance = new MixBoxAssets();
        }
        return _instance;
    }

    public function MixBoxAssets() {


        atlases = new Dictionary();
        textures = new Dictionary();
        _mp3s = new Dictionary();

        graphicsLoader = new LoaderMax({name:"GraphicsLoader",onProgress:onGraphicsProgress,onComplete:onGraphicsComplete, onError:onGraphicsError});
        audioLoader = new LoaderMax({name:"AudioLoader",onProgress:onAudioProgress,onComplete:onAudioComplete, onError:onAudioError});
    }

    public function loadGraphics(progressHandler:Function, completeHandler:Function):void {

        graphicsProgressHandler = progressHandler;
        graphicsCompleteHandler = completeHandler;

        addAtlas("controls");
        addAtlas("robots1");
        addAtlas("robots2");
        addAtlas("robots3");

        graphicsLoader.load();
    }


    public function loadAudio(progress:Function, complete:Function):void {
        audioProgressHandler = progress;
        audioCompleteHandler = complete;

        var audioFiles:Array = [
            "BASSGUITAR2",
            "DOGBELLS",
            "DRUMS2",
            "DUBSTEP",
            "ELECGUITAR",
            "HELDSTRINGS",
            "PIANO2",
            "808autotune",
            "Ladychristmas",
            "Choir",
            "Stuffyourturkey"];

        for (var i:int = 0; i < audioFiles.length; i++) {
            addTrack(audioFiles[i]);
        }
        addSample("MooMetro130");

        audioLoader.load();
    }

    public function get metronome():Sound {
        return audioLoader.getContent("MooMetro130") as Sound;
    }

    private function onGraphicsProgress(event:LoaderEvent):void {
        log.debug("Graphics Progress " + event.target.progress);
        graphicsProgressHandler(event.target.progress);
    }


    private function onAudioProgress(event:LoaderEvent):void {
        log.debug("Audio Progress " + event.target.progress);
        audioProgressHandler(event.target.progress);
    }

    private function onGraphicsComplete(event:LoaderEvent):void {
        log.debug("Graphics Complete");
        for (var name:String in atlases) {
            var xml:XML = graphicsLoader.getContent(name);
            var png:Bitmap = graphicsLoader.getContent("tex_" + name).rawContent;

            var ta:TextureAtlas = new TextureAtlas(Texture.fromBitmap(png),xml);
            atlases[name] = ta;
        }

        graphicsCompleteHandler();
    }

    private function onAudioComplete(event:LoaderEvent):void {
        log.debug("Audio Complete");
        for (var name:String in _mp3s) {
            var sound:Sound = audioLoader.getContent(name);
            _mp3s[name] = sound;
        }

        audioCompleteHandler();
    }

    private function onGraphicsError(event:LoaderEvent):void {
        log.debug("Error " + event.target + " : " + event.text);
    }

    private function onAudioError(event:LoaderEvent):void {
        log.debug("Error " + event.target + " : " + event.text);
    }

    public function addTrack(name:String):void {
        audioLoader.append(new MP3Loader("audio/" + name + ".mp3", {name:name, autoPlay:false}));
        _mp3s[name] = {};
    }

    public function addSample(name:String):void {
        audioLoader.append(new MP3Loader("audio/" + name + ".mp3", {name:name, autoPlay:false}));
    }

    public function addAtlas(name:String):void {
        graphicsLoader.append(new XMLLoader("gfx/" + name + ".xml", {name:name}));
        graphicsLoader.append(new ImageLoader("gfx/" + name + ".png", {name:"tex_" + name, estimatedBytes:1024}));
        atlases[name] = {};
    }

    public function getTextures(name:String):Vector.<Texture> {
        var t:Vector.<Texture> = null;
        for each (var atlas:TextureAtlas in atlases) {
            t = atlas.getTextures(name);
            if(t.length > 0) {
                return t;
            }
        }
        log.error("Texture " + name + " doesnt exist");
        throw new Error("Texture " + name + " doesnt exist");
    }

    public function get mp3s():Dictionary {
        return _mp3s;
    }
}
}
