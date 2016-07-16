//
//  PentiApi.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation
import CoreFoundation
import Alamofire
import AlamofireObjectMapper
import Kanna

enum PentiURL:String{
  case web = "http://www.dapenti.com/blog/blog.asp?subjectid=70&name=xilei&page=%d"
  case api = "http://appb.dapenti.com/index.php?s=/home/api/tugua/p/%d/limit/%d"
}

let StringEncodingGBK = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))

let kFeedCacheFileName = "FeedCache.dat"

class PentiApi {
  
  private static let instance = PentiApi()
  
  static func sharedInstance() -> PentiApi {
    return instance
  }
  
  private func getFeedCacheFile() -> NSURL?{
    let fm = NSFileManager.defaultManager()
    guard let cacheDir = fm.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first else {return nil}
    return cacheDir.URLByAppendingPathComponent(kFeedCacheFileName)
  }
  
  func writeFeedCache(data:NSData){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
      if let file = self.getFeedCacheFile() {
        let ret = data.writeToURL(file, atomically: true)
        NSLog("write feed cache to file, success = \(ret)")
      }
    }
  }
  
  func getFeedCache(completionHandler: ([FeedItem]?) -> Void){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {[unowned self] in
      if let file = self.getFeedCacheFile() {
        guard let data = NSData(contentsOfURL: file) else {
          dispatch_async(dispatch_get_main_queue(), {
            completionHandler(nil)
          })
          return
        }
        guard let html = String(data: data, encoding: StringEncodingGBK) else {
          dispatch_async(dispatch_get_main_queue(), {
            completionHandler(nil)
          })
          return
        }
        NSLog("read feed cache from file")
        let feeds = self.parseHTML(html)
        dispatch_async(dispatch_get_main_queue(), {
          completionHandler(feeds)
        })
      }else{
        dispatch_async(dispatch_get_main_queue(), {
          completionHandler(nil)
        })
      }
    }
  }
  
  func getPage(page:Int, completionHandler: ([FeedItem]?) -> Void){
    let url = NSURL(string: String(format: PentiURL.web.rawValue, page))!
    NSLog("getPage url=\(url)")
    Alamofire.request(.GET, url).validate().responseData {[unowned self]
      (response: Response<NSData, NSError>) in
      guard let data = response.result.value else { return }
      guard let html = String(data: data, encoding: StringEncodingGBK) else { return }
      if page == 1 {
        self.writeFeedCache(data)
      }
      let feeds = self.parseHTML(html)
      dispatch_async(dispatch_get_main_queue(), {
        completionHandler(feeds)
      })
    }
  }
  
  private func parseHTML(html: String) -> [FeedItem]? {
    guard let doc = Kanna.HTML(html: html, encoding: StringEncodingGBK) else { return nil }
    let pattern = "【(\\w+)(\\d{8})】(.*)"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
    var feeds:[FeedItem] = []
    for link in doc.css("td li a") {
      guard let href = link["href"] else { continue }
      guard let title = link.text else { continue }
      let textRange = NSRange(location: 0, length: title.characters.count)
      let result = regex.firstMatchInString(title, options: [], range: textRange)
      guard let authorRange = result?.rangeAtIndex(1) else { continue }
      guard let dateRange = result?.rangeAtIndex(2) else { continue }
      guard let titleRange = result?.rangeAtIndex(3) else { continue }
      let authorStr = (title as NSString).substringWithRange(authorRange)
      let dateStr = (title as NSString).substringWithRange(dateRange)
      let titleStr = (title as NSString).substringWithRange(titleRange)
      let item = FeedItem(title: titleStr, url:href, author:"\(authorStr) \(dateStr)", date:dateStr)
      feeds.append(item)
    }
    return feeds
  }
  
}
