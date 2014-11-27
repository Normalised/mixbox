/**
 */
package com.korisnamedia.social {
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class SocialWeb implements ISocial {

    private static const twitter:String = "https://twitter.com/intent/tweet";
    private static const facebook:String = "https://www.facebook.com/sharer/sharer.php";
    private static const google:String = "https://plus.google.com/share";

    private static const shareText:String = "Moo Merry Music";
    private static const shareUrl:String = "http://moo.com/merrymusic?mixId=";

    public function SocialWeb() {
    }

    public function share(provider:String, mixId:String):void {
        if(provider == 'twitter') {
            shareOnTwitter(mixId);
        } else if(provider == 'facebook') {
            shareOnFacebook(mixId);
        } else if(provider == 'google') {
            shareOnGoogle(mixId);
        }
    }

    private function shareOnGoogle(mixId:String):void {
        var url:String = google + "?url=" + shareUrl + mixId;
        navigateToURL(new URLRequest(url), "_blank");
    }

    private function shareOnFacebook(mixId:String):void {
        var url:String = facebook + "?u=" + shareUrl + mixId + "&t=" + shareText;
        navigateToURL(new URLRequest(url), "_blank");
    }

    private function shareOnTwitter(mixId:String):void {
        var url:String = twitter + "&url=" + shareUrl + mixId + "?text=" + shareText;
        navigateToURL(new URLRequest(url), "_blank");
    }
}
}
