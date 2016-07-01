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

class PentiURL{
  static let page = "http://www.dapenti.com/blog/blog.asp?subjectid=70&name=xilei&page=%d"
  static let api = "http://appb.dapenti.com/index.php?s=/home/api/tugua/p/%d/limit/%d"
}

let StringEncodingGBK = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))

class PentiApi {
  
  private static let instance = PentiApi()
  
  static func sharedInstance() -> PentiApi {
    return instance
  }

  func getPageByApi(page:Int, count:Int = 30, completionHandler: ([FeedItem]?) -> Void) {
    let url = NSURL(string: String(format: PentiURL.api, page, count))!
    print("getPage url=\(url)")
    Alamofire.request(.GET, url).validate().responseObject { (response: Response<Feeds, NSError>) in
//      print(response.response)
      let feeds = response.result.value
      completionHandler(feeds?.items?.filter { $0.author != nil} )
    }
  }
  
  func getPage(page:Int, completionHandler: ([FeedItem]?) -> Void){
    let url = NSURL(string: String(format: PentiURL.page, page))!
    print("getPage url=\(url)")
    Alamofire.request(.GET, url).validate().responseData { (response: Response<NSData, NSError>) in
      guard let data = response.result.value else { return }
      guard let html = String(data: data, encoding: StringEncodingGBK) else { return }
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        let feeds = self.parseHTML(html)
        dispatch_async(dispatch_get_main_queue(), { 
          completionHandler(feeds)
        })
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
