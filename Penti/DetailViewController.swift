//
//  DetailViewController.swift
//  Penti
//
//  Created by mcxiaoke on 16/6/30.
//  Copyright © 2016年 mcxiaoke. All rights reserved.
//

import UIKit
import WebKit
import PureLayout

class DetailViewController: UIViewController {

  var item:FeedItem?
  var webView:WKWebView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView = WKWebView(frame: CGRect.zero)
    self.view.addSubview(webView!)
    webView?.autoPinEdgesToSuperviewEdges()
    self.title = item?.title ?? ""
    if let url = item?.link {
        print("viewDidLoad", url)
      webView?.loadRequest(NSURLRequest(URL: url))
    }
  }

}
