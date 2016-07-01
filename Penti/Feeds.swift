//
//  Feeds.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation
import ObjectMapper

class FeedDateTransform: DateFormatterTransform {
  
  init() {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    super.init(dateFormatter: formatter)
  }
}

class FeedItem: Mappable, CustomStringConvertible{
  
  static let baseURL = "http://www.dapenti.com/blog/"
  
  static let dateOnlyFormatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "YYYYMMdd"
    return formatter
  }()
  
  static let dateFormatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .FullStyle
    formatter.timeStyle = .NoStyle
    return formatter
  }()
  
  var title:String?
  var url:NSURL?
  var author:String?
  var date:NSDate?
  
  var description: String {
    return "FeedItem(\(title) - \(url) (\(date), \(author)))"
  }
  
  required init?(_ map: Map) {
  }
  
  init(title:String, url:String, author:String, date:String){
    let url = url.stringByReplacingOccurrencesOfString("more.asp", withString: "readapp2.asp")
    self.title = title
    self.url = NSURL(string: FeedItem.baseURL + url)
    self.author = author
    self.date = FeedItem.dateOnlyFormatter.dateFromString(date)
  }
  
  func mapping(map: Map) {
    title <- map["title"]
    url <- (map["link"], URLTransform())
    author <- map["author"]
    date <- (map["pubDate"], FeedDateTransform())
//    description <- map["description"]
//    thumbUrl <- map["imgurl"]
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
