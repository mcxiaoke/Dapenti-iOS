//
//  Browser.swift
//  Penti
//
//  Created by Xiaoke Zhang on 2017/8/22.
//  Copyright © 2017年 mcxiaoke. All rights reserved.
//

import Foundation
import SafariServices

extension UIViewController: SFSafariViewControllerDelegate {
    
    func safariOpen(_ url:URL) {
        let svc = SFSafariViewController(url: url)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    public func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        let act = UIActivity()
        return [act]
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
