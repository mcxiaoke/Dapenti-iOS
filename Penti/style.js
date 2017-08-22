/*
* @Author: mcxiaoke
* @Date:   2016-07-04 17:17:43
* @Last Modified by:   mcxiaoke
* @Last Modified time: 2016-07-05 13:06:40
*/
function postMessage(message){
    window.webkit.messageHandlers.bridge.postMessage(message);
}

function addCSSRule(sheet, selector, rules, index) {
    if("insertRule" in sheet) {
        sheet.insertRule(selector + "{" + rules + "}", index);
    }
    else if("addRule" in sheet) {
        sheet.addRule(selector, rules, index);
    }
}

function createStyleSheet(){
    // Create the <style> tag
    var style = document.createElement("style");

    // Add a media (and/or media query) here if you'd like!
    // style.setAttribute("media", "screen")
    // style.setAttribute("media", "only screen and (max-width : 1024px)")

    // WebKit hack :(
    style.appendChild(document.createTextNode(""));

    // Add the <style> element to the page
    document.head.appendChild(style);
    return style.sheet;
}

function loadFile(fileName, fileType){
    console.log("loadFile "+fileName);
    if (fileType=="js"){ //if filename is a external JavaScript file
        var fileRef=document.createElement('script');
        fileRef.setAttribute("type","text/javascript");
        fileRef.setAttribute("src", fileName);
    }
    else if (fileType=="css"){ //if filename is an external CSS file
        var fileRef=document.createElement("link");
        fileRef.setAttribute("rel", "stylesheet");
        fileRef.setAttribute("type", "text/css");
        fileRef.setAttribute("href", fileName);
    }
    console.log(fileRef.innerHTML);
    if (typeof fileRef!="undefined")
        document.head.appendChild(fileRef);
}

function removeOldStyles(){
    var styles = document.body.getElementsByTagName("style");
    if (styles == null || styles == undefined) {
        console.log("style not found.");
        return;
    }
    Array.prototype.forEach.call(styles, function(style, index) {
        console.log("Removing Style "+index);
        document.body.removeChild(style);
    });
}

function changeStyle(){
    var bodyStyle = "background: #f7f8f4;\n"
        + "font-size: 16px;\n"
        + "font-family: \"Hiragino Sans GB\", \"PingFang SC\", \"Heiti SC\", sans-serif;\n"
        + "text-align:left;\n"
        + "text-color: #5b5c5b;\n"
        + "line-height: 1.5;\n"
        + "margin: 10px;\n"
        //+ "-webkit-text-size-adjust:100% !important;\n"
    var imageStyle = "display:block;\n"
        + "max-width: 100%;\n"
        + "margin: 0 auto;\n"
        + "padding-top:5px;\n"
        + "padding-bottom:5px;\n"
    var linkStyle = "text-decoration: none;"
    var sheet = createStyleSheet()
    addCSSRule(sheet, "body", bodyStyle);
    addCSSRule(sheet, "img", imageStyle);
    addCSSRule(sheet, "a", linkStyle);
}

function fixMeta() {
    var meta = document.createElement('meta');
    meta.setAttribute('name', 'viewport');
    meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0');
    document.getElementsByTagName('head')[0].appendChild(meta);
}

document.addEventListener("load", function(event) {
    postMessage("All resources finished loading!");
  });

fixMeta();
removeOldStyles();
changeStyle();

