/**
 * Created by Martin Wood-Mitrovski
 * Date: 17/11/2014
 * Time: 19:21
 */
package com.korisnamedia.social {
import com.milkmangames.nativeextensions.GoViral;
import com.milkmangames.nativeextensions.events.GVFacebookEvent;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

public class SocialMobile implements ISocial {

    private static const log:ILogger = getLogger(SocialMobile);

    public function SocialMobile() {

        if(GoViral.goViral.isFacebookSupported()) {
            GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
            GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);
            GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
            GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
            GoViral.goViral.initFacebook(AppConfig.FB_APP_ID,"");
        }
    }

    private function onFacebookEvent(event:GVFacebookEvent):void {
        log.debug("Facebook Event : " + event.data);
    }

    public function share(provider:String, mixId:String):void {
        if(provider == 'facebook') {
            shareOnFacebook(mixId);
        }
    }

    private function shareOnFacebook(mixId:String):void {
        var dispatcher = GoViral.goViral.showFacebookShareDialog("Test Post", "Moo Mix", "Make your own xmas mix", "http://www.moo.com", "http://www.moo.com/moobeats.jpg");
        dispatcher.addDialogListener(function(e:GVFacebookEvent) {
            switch(e.type) {
                case GVFacebookEvent.FB_DIALOG_CANCELED:
                    log.debug("The Share Dialog was canceled.");
                    break;
                case GVFacebookEvent.FB_DIALOG_FAILED:
                    log.debug("The Share Dialog has failed:"+e.errorMessage);
                    break;
                case GVFacebookEvent.FB_DIALOG_FINISHED:
                    log.debug("Successfully posted to share dialog:"+e.jsonData);
                    break;
            }
        });
    }
}
}
