//
//  Feeds.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation
import ObjectMapper

private let dateFormatter:NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.locale = NSLocale(localeIdentifier: "en_US")
  formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
  return formatter
}()

class FeedDateTransform: DateFormatterTransform {
  
  init() {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    super.init(dateFormatter: formatter)
  }
  
}

class FeedItem: Mappable{
  var title:String?
  var link:NSURL?
  var author:String?
  var pubDate:NSDate?
  var description:String?
  var thumbUrl:String?
  
  required init?(_ map: Map) {
//    if map["author"].value() == nil {
//      return nil
//    }
//    if map["pubDate"].value() == nil {
//      return nil
//    }
  }
  
  func mapping(map: Map) {
    title <- map["title"]
    link <- (map["link"], URLTransform())
    author <- map["author"]
    pubDate <- (map["pubDate"], FeedDateTransform())
    description <- map["description"]
    thumbUrl <- map["imgurl"]
  }
  
}

class Feeds: Mappable {
  var message:String?
  var code:Int?
  var items:[FeedItem]?
  
  required init?(_ map: Map) {
    //
  }
  
  func mapping(map: Map) {
    message <- map["msg"]
    code <- map["error"]
    items <- map["data"]
  }
}
