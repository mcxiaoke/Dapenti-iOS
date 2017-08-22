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
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
    super.init(dateFormatter: formatter)
  }
}

class FeedItem: Mappable, CustomStringConvertible{
  
  static var visited = Set<Int>()
  
  static let baseURL = "http://www.dapenti.com/blog/"
  
  static let dateOnlyFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "YYYYMMdd"
    return formatter
  }()
  
  static let dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
  }()
  
  static func isVisited(_ id:Int) -> Bool {
    return visited.contains(id)
  }
  
  static func addVisitedId(_ id:Int){
    visited.insert(id)
  }
  
  static func loadVisitedIds(){
    visited = FeedsPreference.loadVisitedIds() 
  }
  
  var id:Int = 0
  var title:String?
  var url:URL?
  var author:String?
  var date:Date?
  
  var description: String {
    return "FeedItem(\(String(describing: title)) - \(String(describing: url)) (\(String(describing: date)), \(String(describing: author))) \(id))"
  }
  
  required init?(map: Map) {
  }
  
  init(title:String, url:String, author:String, date:String){
    self.id = Int(date) ?? 0
    let url = url.replacingOccurrences(of: "more.asp", with: "readapp2.asp")
    self.title = title.replacingOccurrences(of: "【", with: "").replacingOccurrences(of: "】", with: " - ")
    self.url = URL(string: FeedItem.baseURL + url)
    self.author = author
    self.date = FeedItem.dateOnlyFormatter.date(from: date)
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
  
  required init?(map: Map) {
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
    let defaults = UserDefaults.standard
    let launchedBefore = defaults.bool(forKey: PreferenceKeyLauchedBefore)
    if !launchedBefore {
      NSLog("handle first launch")
      mergeStoreVisitedIds()
      defaults.set(true, forKey: PreferenceKeyLauchedBefore)
    }
  }
  
  class func mergeStoreVisitedIds(){
    let store = NSUbiquitousKeyValueStore.default()
    guard let numbers = store.object(forKey: PreferenceKeyVisitedIds) as? [NSNumber] else { return }
    let ids = Set<Int>(numbers.map{$0.intValue})
    let localIds = loadVisitedIds() 
    let mergedIds = ids.union(localIds)
//    NSLog("merge storage visited ids = \(mergedIds)")
    saveVisitedIds(mergedIds)
  }
  

  class func saveVisitedIds(_ ids:Set<Int>){
//    NSLog("save visited ids = \(ids)")
    let numbers = ids.map{ NSNumber(value: $0 as Int) }
    UserDefaults.standard.set(numbers, forKey: PreferenceKeyVisitedIds)
    let store = NSUbiquitousKeyValueStore.default()
    store.set(numbers, forKey: PreferenceKeyVisitedIds)
    store.synchronize()
  }
  
  class func loadVisitedIds() -> Set<Int> {
    guard let numbers =  UserDefaults.standard.object(forKey: PreferenceKeyVisitedIds) as? [NSNumber] else { return Set<Int>() }
//    NSLog("load visited ids = \(numbers)")
    return Set<Int>(numbers.map{ $0.intValue })
  }
  
  
}
