//
//  Feeds.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation
import ObjectMapper

let PreferenceKeyVisitedIds = "visited_ids"
let PreferenceKeyLauchedBefore = "launch_before"

class FeedDateTransform: DateFormatterTransform {
  
  init() {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    super.init(dateFormatter: formatter)
  }
}

class FeedItem: Mappable, CustomStringConvertible{
  
  static var visited = Set<Int>()
  
  static let baseURL = "http://www.dapenti.com/blog/"
  
  static let dateOnlyFormatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US")
    formatter.dateFormat = "YYYYMMdd"
    return formatter
  }()
  
  static let dateFormatter:NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .NoStyle
    return formatter
  }()
  
  static func isVisited(id:Int) -> Bool {
    return visited.contains(id)
  }
  
  static func addVisitedId(id:Int){
    visited.insert(id)
  }
  
  static func loadVisitedIds(){
    visited = FeedsPreference.loadVisitedIds() ?? Set<Int>()
  }
  
  var id:Int = 0
  var title:String?
  var url:NSURL?
  var author:String?
  var date:NSDate?
  
  var description: String {
    return "FeedItem(\(title) - \(url) (\(date), \(author)) \(id))"
  }
  
  required init?(_ map: Map) {
  }
  
  init(title:String, url:String, author:String, date:String){
    self.id = Int(date) ?? 0
    let url = url.stringByReplacingOccurrencesOfString("more.asp", withString: "readapp2.asp")
    self.title = title.stringByReplacingOccurrencesOfString("【", withString: "").stringByReplacingOccurrencesOfString("】", withString: " - ")
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

class FeedsPreference{
  
  class func handleFirstLaunch(){
    let defaults = NSUserDefaults.standardUserDefaults()
    let launchedBefore = defaults.boolForKey(PreferenceKeyLauchedBefore)
    if !launchedBefore {
      NSLog("handle first launch")
      mergeStoreVisitedIds()
      defaults.setBool(true, forKey: PreferenceKeyLauchedBefore)
    }
  }
  
  class func mergeStoreVisitedIds(){
    let store = NSUbiquitousKeyValueStore.defaultStore()
    guard let numbers = store.objectForKey(PreferenceKeyVisitedIds) as? [NSNumber] else { return }
    let ids = Set<Int>(numbers.map{$0.longValue})
    let localIds = loadVisitedIds() ?? Set<Int>()
    let mergedIds = ids.union(localIds)
    NSLog("merge storage visited ids = \(mergedIds)")
    saveVisitedIds(mergedIds)
  }
  

  class func saveVisitedIds(ids:Set<Int>){
    NSLog("save visited ids = \(ids)")
    let numbers = ids.map{ NSNumber(long:$0) }
    NSUserDefaults.standardUserDefaults().setObject(numbers, forKey: PreferenceKeyVisitedIds)
    let store = NSUbiquitousKeyValueStore.defaultStore()
    store.setObject(numbers, forKey: PreferenceKeyVisitedIds)
    store.synchronize()
  }
  
  class func loadVisitedIds() -> Set<Int> {
    guard let numbers =  NSUserDefaults.standardUserDefaults().objectForKey(PreferenceKeyVisitedIds) as? [NSNumber] else { return Set<Int>() }
    NSLog("load visited ids = \(numbers)")
    return Set<Int>(numbers.map{ $0.longValue })
  }
  
  
}
