/*
* @Author: mcxiaoke
* @Date:   2016-07-04 14:53:51
* @Last Modified by:   mcxiaoke
* @Last Modified time: 2016-07-05 13:08:32
*/
// https://davidwalsh.name/add-rules-stylesheets

function postMessage(message){
    window.webkit.messageHandlers.bridge.postMessage(message);
}


function removeADFrames(){
    var iframes = document.querySelectorAll('iframe');
    if (iframes == null || iframes == undefined) {
        console.log("No AD iframes.");
        return;
    }
    for (var i = 0; i < iframes.length; i++) {
        iframes[i].parentNode.removeChild(iframes[i]);
    }
    console.log("Removing AD iframes.");
}

function removeComments(){
    var comments = document.getElementById("SOHUCS");
    if (comments == null || comments == undefined) {
        console.log("comments not found.");
        return;
    }
    console.log("Removing comments.");
    document.body.removeChild(comments);
}

function removeScripts(){
    var elements = document.getElementsByTagName("script");
    if (elements == null || elements == undefined) {
        console.log("scripts not found.");
        return;
    }
    Array.prototype.forEach.call(elements, function(element, index) {
        console.log("Removing script "+index);
        element.parentNode.removeChild(element);
    });
}

function removeADs(){
    var ads = document.getElementsByClassName("adsbygoogle");
    if (ads == null || ads == undefined) {
        console.log("ADs not found");
        return;
    }
    Array.prototype.forEach.call(ads, function(ad, index) {
        console.log("Removing AD "+index);
        document.body.removeChild(ad);
    });
}

adsbygoogle = undefined
window.adsbygoogle = undefined
removeScripts();
removeADs();
removeADFrames();
removeComments();

