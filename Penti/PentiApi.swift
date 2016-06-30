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

class PentiApi {
  
  private static let instance = PentiApi()
  
  static func sharedInstance() -> PentiApi {
    return instance
  }
  
  let tuguaUrlFormat = "http://appb.dapenti.com/index.php?s=/home/api/tugua/p/1/limit/30"

  func getPage(page:Int, count:Int, completionHandler: ([FeedItem]?) -> Void) {
    let url = NSURL(string: tuguaUrlFormat)!
    Alamofire.request(.GET, url).validate().responseObject { (response: Response<Feeds, NSError>) in
//      print(response.response)
      let feeds = response.result.value
      completionHandler(feeds?.items?.filter { $0.author != nil} )
    }
    
  }
  
}
