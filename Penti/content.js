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

function removeElementById(eid){
    var element = document.getElementById(eid);
    if (element == null || element == undefined) {
        return;
    }
    element.parentNode.removeChild(element);
//    document.body.removeChild(element);
}

function removeComments(){
    removeElementById("SOHUCS");
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

function removeHRs(){
    var elements = document.getElementsByTagName("hr");
    if (elements == null || elements == undefined) {
        console.log("hr not found.");
        return;
    }
    Array.prototype.forEach.call(elements, function(element, index) {
                                 console.log("Removing hr "+index);
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
    removeElementById("aswift_1_expand");
    removeElementById("aswift_1_anchor");
}

function fixImages() {
    var images = document.getElementsByTagName("img");
    Array.prototype.forEach.call(images, function(img, index) {
                                 console.log("Fix image "+index);
                                 img.addEventListener("click", function(){
                                                      console.log("onImageClicked img="+img);
                                                      postMessage(img.src);
                                                      });
                                 });
}

adsbygoogle = undefined
window.adsbygoogle = undefined
removeScripts();
removeADs();
removeADFrames();
removeComments();
removeHRs();


