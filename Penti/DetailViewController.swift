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
import MBProgressHUD
import TUSafariActivity

class DetailViewController: UIViewController {

  var item:FeedItem?
  var webView:WKWebView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpWebView()
    self.title = "\(item?.id ?? 0)"
    if let url = item?.url {
        NSLog("webView url = \(url)")
      webView?.load(URLRequest(url: url as URL))
    }
    
    let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                 target: self, action: #selector(showActions(_:)))
    self.navigationItem.rightBarButtonItem = rightBarButtonItem
    self.navigationController?.hidesBarsOnSwipe = true
    
    let hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
    hud.bezelView.color = UIColor.lightGray
    hud.animationType = .fade
  }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.hidesBarsOnSwipe = false
    }
  
  func setUpWebView(){
    let ucc = WKUserContentController()
    ucc.addJavaScript("style")
    ucc.addJavaScript("content")
    ucc.add(self, name: "bridge")
    let configuration = WKWebViewConfiguration()
    configuration.userContentController = ucc
    configuration.preferences.javaScriptEnabled = false
    let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
    webView.isHidden = true
    webView.navigationDelegate = self
    webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    self.view.addSubview(webView)
    webView.autoPinEdgesToSuperviewEdges()
    self.webView = webView
  }
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    guard let object = object as? WKWebView else { return }
    guard let keyPath = keyPath else { return }
    if keyPath == "estimatedProgress" && object == webView {
      if webView?.estimatedProgress == 1.0 {
        NSLog("estimatedProgress = 100%")
      }
    }
  }
  
  func showActions(_ sender:AnyObject){
    if let url = self.item?.url {
      let activityItems = [url]
      let activities = [TUSafariActivity()]
      OperationQueue.main.addOperation({
        let ac = UIActivityViewController(activityItems: activityItems,
          applicationActivities: activities)
        ac.excludedActivityTypes = [UIActivityType.airDrop]
        self.present(ac, animated: true, completion: nil)
      })
    }
  }

}

extension WKUserContentController {
  func addJavaScript(_ fileName: String, injectionTime: WKUserScriptInjectionTime = .atDocumentEnd){
    let jsPath = Bundle.main.path(forResource: fileName, ofType: "js")
    let jsSource = try! String(contentsOfFile: jsPath!, encoding: String.Encoding.utf8)
    let userScript = WKUserScript(source: jsSource, injectionTime: injectionTime, forMainFrameOnly: false)
    addUserScript(userScript)
  }
}

extension DetailViewController: WKNavigationDelegate {
    
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    NSLog("didFinishNavigation")
    MBProgressHUD.hide(for: self.view, animated: true)
    self.webView?.isHidden = false
  }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        NSLog("decidePolicyFor \(navigationAction.request)")
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                safariOpen(url)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
}

extension DetailViewController: WKScriptMessageHandler {
    
  func userContentController(_ userContentController: WKUserContentController,
                             didReceive message: WKScriptMessage) {
    print(message.body)
  }
    
}
