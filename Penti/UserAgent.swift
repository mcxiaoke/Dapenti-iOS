//
//  UserAgent.swift
//  Penti
//
//  Created by Xiaoke Zhang on 2017/8/23.
//  Copyright © 2017年 mcxiaoke. All rights reserved.
//

import Foundation
import WebKit

internal let kUserAgent = "kUserAgent"

class UserAgent: AnyObject {
    static let defaultUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_3 like Mac OS X) AppleWebKit/603.3.8 (KHTML, like Gecko) Mobile/14G60"
    
    static let shared = UserAgent()
    
    init() {
        let webView = UIWebView(frame: CGRect.zero)
        webView.loadHTMLString("<html></html>", baseURL: nil)
        let userAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent")
        NSLog("userAgent = \(String(describing: userAgent))")
        save(userAgent)
    }
    
    func save(_ userAgent: String?) {
        UserDefaults.standard.setValue(userAgent, forKey: kUserAgent)
    }
    
    func load() -> String {
        return UserDefaults.standard.string(forKey: kUserAgent) ?? ""
    }
    
    
}
