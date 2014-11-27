/**
 * Created by Martin Wood-Mitrovski
 * Date: 22/11/2014
 * Time: 15:01
 */
package com.korisnamedia.musicbox.assets {
public class EmbeddedControls {

    [Embed(source="../../../../../gfx/controls.xml", mimeType="application/octet-stream")]
    public static const ControlsAtlasXml:Class;
    [Embed(source="../../../../../gfx/controls.png")]
    public static const ControlsTexture:Class;

    public function EmbeddedControls() {
    }
}
}
