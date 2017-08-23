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

internal let NSStringEncodingGBK = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
internal let StringEncodingGBK = String.Encoding(rawValue: NSStringEncodingGBK)
internal let Headers: HTTPHeaders = [
    "UserAgent": UserAgent.defaultUA
]

internal let kFeedCacheFileName = "FeedCache.dat"

class PentiApi {
  
  fileprivate static let instance = PentiApi()
  
  static func sharedInstance() -> PentiApi {
    return instance
  }
  
  fileprivate func getFeedCacheFile() -> URL?{
    let fm = FileManager.default
    guard let cacheDir = fm.urls(for: .cachesDirectory, in: .userDomainMask).first else {return nil}
    return cacheDir.appendingPathComponent(kFeedCacheFileName)
  }
  
  func writeFeedCache(_ data:Data){
    DispatchQueue.global().async {
      if let file = self.getFeedCacheFile() {
        let ret = (try? data.write(to: file, options: [.atomic])) != nil
        NSLog("write feed cache to file, success = \(ret)")
      }
    }
  }
  
  func getFeedCache(_ completionHandler: @escaping ([FeedItem]?) -> Void){
    DispatchQueue.global().async {[unowned self] in
      if let file = self.getFeedCacheFile() {
        guard let data = try? Data(contentsOf: file) else {
          DispatchQueue.main.async(execute: {
            completionHandler(nil)
          })
          return
        }
        guard let html = String(data: data, encoding: StringEncodingGBK) else {
          DispatchQueue.main.async(execute: {
            completionHandler(nil)
          })
          return
        }
        NSLog("read feed cache from file")
        let feeds = self.parseHTML(html)
        DispatchQueue.main.async(execute: {
          completionHandler(feeds)
        })
      }else{
        DispatchQueue.main.async(execute: {
          completionHandler(nil)
        })
      }
    }
  }
  
  func getPage(_ page:Int, completionHandler: @escaping ([FeedItem]?) -> Void){
    let url = URL(string: String(format: PentiURL.web.rawValue, page))!
    NSLog("getPage url=\(url)")
    Alamofire.request(url, headers: Headers).validate().responseData { response in
      guard response.result.isSuccess else { return }
      guard let data = response.result.value else { return }
      guard let html = String(data: data, encoding: StringEncodingGBK) else { return }
      if page == 1 {
        self.writeFeedCache(data)
      }
      let feeds = self.parseHTML(html)
      DispatchQueue.main.async(execute: {
        completionHandler(feeds)
      })
    }
  }
  
  fileprivate func parseHTML(_ html: String) -> [FeedItem]? {
    guard let doc = HTML(html: html, encoding: .utf8) else { return nil }
    let pattern = "【(\\w+)(\\d{8})】(.*)"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
    var feeds:[FeedItem] = []
    for link in doc.css("td li a") {
      guard let href = link["href"] else { continue }
      guard let title = link.text else { continue }
      let textRange = NSRange(location: 0, length: title.characters.count)
      let result = regex.firstMatch(in: title, options: [], range: textRange)
      guard let authorRange = result?.rangeAt(1) else { continue }
      guard let dateRange = result?.rangeAt(2) else { continue }
      guard let titleRange = result?.rangeAt(3) else { continue }
      let authorStr = (title as NSString).substring(with: authorRange)
      let dateStr = (title as NSString).substring(with: dateRange)
      let titleStr = (title as NSString).substring(with: titleRange)
      let item = FeedItem(title: titleStr, url:href, author:"\(authorStr) \(dateStr)", date:dateStr)
      feeds.append(item)
    }
    return feeds
  }
  
}
