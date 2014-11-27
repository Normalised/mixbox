/**
 * Created by Martin Wood-Mitrovski
 * Date: 16/11/2014
 * Time: 16:24
 */
package {
import com.korisnamedia.audio.Tempo;
import com.korisnamedia.social.ISocial;

import flash.system.Capabilities;

public class AppConfig {

    public static const tempo:Tempo = new Tempo(130);
    public static const FB_APP_ID:String = "538947589541117";
    public static const serverUrl:String = "http://localhost/MooMixPhp/endpoint.php";
    public static const endPoints:Object = {saveAudio:"?type=audio",getAudio:"?type=audio",saveMix:"?type=mix", getMix:"?type=mix"};

    public static var useNativeScreen:Boolean = false;
    public static var socialProvider:ISocial;
    public static var micTrackID:int;
//    public static var serverUrl:String = "http://www.moo.com/merrymusic/endpoint.php";

    public static const offsets:Object = {"android":1050,"windows":400,"ios":1050};

    public static function getEncoderOffset():int {

        var platform:String = Capabilities.manufacturer;
        for(var s:String in offsets) {
            if(platform.toLowerCase().indexOf(s) > -1) {
                return offsets[s];
                break;
            }
        }
        return offsets.windows;
    }
}
}
