/*
* @Author: mcxiaoke
* @Date:   2016-07-04 14:53:51
* @Last Modified by:   mcxiaoke
* @Last Modified time: 2016-07-04 17:39:15
*/
// https://davidwalsh.name/add-rules-stylesheets

function postMessage(message){
    window.webkit.messageHandlers.bridge.postMessage(message);
}

function removeADs(){
    var ads = document.getElementsByClassName("adsbygoogle");
    if (ads == null || ads == undefined) {
        postMessage("ADs not found.");
        console.log("ADs not found");
        return;
    }
    Array.prototype.forEach.call(ads, function(ad, index) {
        postMessage("Removing AD "+index);
        console.log("Removing AD "+index);
        document.body.removeChild(ad);
    });
}

removeADs();

