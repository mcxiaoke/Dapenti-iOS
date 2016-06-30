//
//  PentiApi.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation

class PentiApi {
  
  private static let instance = PentiApi()
  
  static func sharedInstance() -> PentiApi {
    return instance
  }
  
  let tuguaUrlFormat = "http://appb.dapenti.com/index.php?s=/home/api/tugua/p/1/limit/30"
  
  let session = NSURLSession.sharedSession()

  func getPage(page:Int, count:Int, completionHandler: (Feeds) -> Void) {
    let url = NSURL(string: tuguaUrlFormat)!
    let task = session.dataTaskWithURL(url) { (data, response, error) in
      guard let data = data else { return }
      let json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    }
    task.resume()
  }
  
}
