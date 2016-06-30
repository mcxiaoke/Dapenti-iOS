//
//  Feeds.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import Foundation

struct FeedItem {
  let title:String
  let link:String
  let author:String
  let pubDate:String
  let description:String
  let thumbUrl:String
}

struct Feeds {
  let msg:String
  let error:Int
  let data:[FeedItem]?
}
