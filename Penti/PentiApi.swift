//
//  PentiApi.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class PentiURL{
  static let tugua = "http://appb.dapenti.com/index.php?s=/home/api/tugua/p/%d/limit/%d"
}

class PentiApi {
  
  private static let instance = PentiApi()
  
  static func sharedInstance() -> PentiApi {
    return instance
  }

  func getPage(page:Int, count:Int = 30, completionHandler: ([FeedItem]?) -> Void) {
    let url = NSURL(string: String(format: PentiURL.tugua, page, count))!
    print("getPage url=\(url)")
    Alamofire.request(.GET, url).validate().responseObject { (response: Response<Feeds, NSError>) in
//      print(response.response)
      let feeds = response.result.value
      completionHandler(feeds?.items?.filter { $0.author != nil} )
    }
    
  }
  
}
