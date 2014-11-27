/**
 * Created by Martin Wood-Mitrovski
 * Date: 22/11/2014
 * Time: 15:03
 */
package com.korisnamedia.musicbox.assets {
public class EmbeddedRobots {


    [Embed(source="../../../../../gfx/robot1.xml", mimeType="application/octet-stream")]
    public static const RobotsXml:Class;
    [Embed(source="../../../../../gfx/robot1.png")]
    public static const RobotsTexture:Class;

    public function EmbeddedRobots() {
    }
}
}
